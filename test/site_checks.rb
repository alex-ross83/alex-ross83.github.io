#!/usr/bin/env ruby
# Content-independent site checks, called from test/check-site.sh.
# Usage: ruby test/site_checks.rb <home|post-urls|lang-links|sitemap> [SITE_DIR]
# Expected values come from _posts/ front matter and _data/, so publishing a post never
# breaks the suite. Prints "  ok    …" / "  FAIL  …" lines; exits 1 if any check failed.
require "yaml"
require "date"
require "time"

ROOT = File.expand_path("..", __dir__)
SITE = File.expand_path(ARGV[1] || "_site", Dir.pwd)
LANGS = %w[en es].freeze
DEFAULT_LANG = "en"
SITE_URL = "https://blog.ross-lopez.rocks"
ROOT_WORD = { "en" => "entries", "es" => "entradas" }.freeze
$failed = false

def ok(msg) = puts("  ok    #{msg}")
def bad(msg)
  puts("  FAIL  #{msg}")
  $failed = true
end
def check(cond, msg) = cond ? ok(msg) : bad(msg)

def load_yaml(path) = YAML.safe_load(File.read(path), permitted_classes: [Date, Time]) || {}

SECTIONS = load_yaml(File.join(ROOT, "_data/sections.yml"))
SERIES   = load_yaml(File.join(ROOT, "_data/series.yml"))
STRINGS  = LANGS.to_h { |l| [l, load_yaml(File.join(ROOT, "_data/#{l}/strings.yml"))] }

def unescape(s) = s.gsub("&quot;", '"').gsub("&#39;", "'").gsub("&lt;", "<").gsub("&gt;", ">").gsub("&amp;", "&")

# Every published post: { file: "_posts/…", data: { front matter } }
def posts
  @posts ||= Dir[File.join(ROOT, "_posts/**/*.{md,markdown}")].sort.filter_map do |f|
    text = File.read(f)
    next unless text.start_with?("---")
    data = YAML.safe_load(text.split(/^---\s*$/, 3)[1], permitted_classes: [Date, Time]) || {}
    next if data["published"] == false
    { file: f.delete_prefix("#{ROOT}/"), data: data }
  end
end

def post_lang(p) = p[:data]["lang"] || DEFAULT_LANG

def post_time(p)
  d = p[:data]["date"]
  return d.to_time if d.respond_to?(:to_time)
  Time.parse(d.to_s)
rescue ArgumentError
  Time.parse(File.basename(p[:file])[0, 10])
end

# Posts Jekyll + polyglot show in LANG's build: one per page_id (the LANG version, else the
# default-language version, else any), no future dates, newest first.
def visible_posts(lang)
  now = Time.now
  groups = posts.reject { |p| post_time(p) > now }.group_by { |p| p[:data]["page_id"] || p[:file] }
  groups.values
        .map { |g| g.find { |p| post_lang(p) == lang } || g.find { |p| post_lang(p) == DEFAULT_LANG } || g.first }
        .sort_by { |p| -post_time(p).to_f }
end

def home_file(lang) = lang == DEFAULT_LANG ? "index.html" : "#{lang}/index.html"

def check_home
  LANGS.each do |lang|
    file = home_file(lang)
    html = File.read(File.join(SITE, file))
    s = STRINGS[lang]
    vis = visible_posts(lang)

    feed = html.scan(%r{<span class="feed-kicker">(.*?)</span>\s*<h2 class="feed-title"><a href="([^"]+)">(.*?)</a>}m)
    want = [vis.size, 5].min
    check(feed.size == want, "#{file}: Latest shows #{want} posts (got #{feed.size})")
    cta = html[/class="btn btn-cta" href="([^"]+)"/, 1]
    check(!cta.nil? && feed.first && cta == feed.first[1], "#{file}: hero CTA links to the newest post (#{cta.inspect})")

    feed.zip(vis).each do |(kicker, _href, title), post|
      next unless post
      check(unescape(title) == post[:data]["title"].to_s, "#{file}: Latest item '#{unescape(title)}' is in date order")
      sec = SECTIONS[post[:data]["section"]]
      next unless sec
      expected = sec["title"][lang] || sec["title"]["en"]
      series = SERIES[post[:data]["series"]]
      expected += " · #{series["title"]}" if series
      check(unescape(kicker.strip) == expected, "#{file}: kicker of '#{post[:data]["title"]}' is '#{expected}'")
    end

    SECTIONS.each_key do |key|
      card = html[%r{<article class="section-card" data-section="#{Regexp.escape(key)}">(.*?)</article>}m, 1]
      next bad("#{file}: card #{key} is missing") unless card
      in_sec = vis.select { |p| p[:data]["section"] == key }
      if in_sec.empty?
        check(card.include?(s["coming_soon"]) && !card.include?('class="section-count"'),
              "#{file}: card #{key} says '#{s["coming_soon"]}'")
      else
        n = in_sec.size
        count = n == 1 ? s["post_count_one"] : s["post_count"].sub("%n", n.to_s)
        check(card.include?(">#{count}<") && !card.include?(s["coming_soon"]), "#{file}: card #{key} shows '#{count}'")
        titles = card.scan(%r{<li><a href="[^"]+">(.*?)</a></li>}m).flatten.map { |t| unescape(t) }
        expected = in_sec.first(3).map { |p| p[:data]["title"].to_s }
        check(titles == expected, "#{file}: card #{key} lists its #{expected.size} newest posts")
      end
    end
  end
end

# New-style posts (those with permalink:) must use their section's localized path, carry a
# description, and have a twin in the other language with the same page_id.
def check_post_urls
  styled = posts.select { |p| p[:data]["permalink"] }
  return ok("no posts with a custom permalink yet") if styled.empty?

  styled.each do |p|
    d = p[:data]
    lang = post_lang(p)
    path = SECTIONS.dig(d["section"].to_s, "path", lang)
    unless path
      bad("#{p[:file]}: section '#{d["section"]}' has no #{lang} path in _data/sections.yml")
      next
    end
    re = %r{\A/#{ROOT_WORD[lang]}/#{Regexp.escape(path)}/[a-z0-9]+(?:-[a-z0-9]+)*/\z}
    check(re.match?(d["permalink"].to_s), "#{p[:file]}: permalink #{d["permalink"]} matches /#{ROOT_WORD[lang]}/#{path}/<slug>/")
    check(!d["description"].to_s.strip.empty?, "#{p[:file]}: has a description")
    twin = styled.find { |q| q != p && q[:data]["page_id"] == d["page_id"] && post_lang(q) != lang }
    check(!d["page_id"].to_s.empty? && !twin.nil?, "#{p[:file]}: has a twin in the other language (page_id '#{d["page_id"]}')")
  end
end

def url_for(rel) = "/" + rel.delete_suffix("index.html")

def file_for(url)
  path = url.to_s.split(/[?#]/).first.to_s
  return nil unless path.start_with?("/")
  [path.end_with?("/") ? "#{path}index.html" : path, "#{path}/index.html", "#{path}.html"]
    .map { |c| File.join(SITE, c) }.find { |f| File.file?(f) }
end

def switcher_href(html) = html[/class="page-link" lang="[^"]*" hreflang="[^"]*" href="([^"]+)"/, 1]

# On every page with a language switcher: the switcher link and every hreflang link resolve
# to a built page, the switcher round-trips, and the hreflang list includes the page itself.
def check_lang_links
  pages = Dir[File.join(SITE, "**/*.html")].map { |f| f.delete_prefix("#{SITE}/") }
                                            .select { |rel| File.read(File.join(SITE, rel)).include?('class="site-nav lang-switch"') }
  return bad("no pages with a language switcher found in #{SITE}") if pages.empty?

  broken = []
  pages.each do |rel|
    html = File.read(File.join(SITE, rel))
    me = url_for(rel)
    target = switcher_href(html)
    tfile = file_for(target)
    if tfile
      back = switcher_href(File.read(tfile))
      broken << "#{me}: switcher → #{target}, which links back to #{back.inspect}" unless back == me
    else
      broken << "#{me}: switcher → #{target.inspect} (no such page)"
    end
    alts = html.scan(/<link rel="alternate" hreflang="[^"]+" href="#{Regexp.escape(SITE_URL)}([^"]*)"/).flatten
    alts.each { |h| broken << "#{me}: hreflang → #{h} (no such page)" unless file_for(h) }
    broken << "#{me}: hreflang list is missing the page itself" unless alts.include?(me)
  end
  check(broken.empty?, "switcher and hreflang resolve and round-trip on #{pages.size} pages" +
                       (broken.empty? ? "" : ":\n        " + broken.first(10).join("\n        ")))
end

case ARGV[0]
when "home"       then check_home
when "post-urls"  then check_post_urls
when "lang-links" then check_lang_links
else abort "usage: ruby test/site_checks.rb <home|post-urls|lang-links|sitemap> [SITE_DIR]"
end
exit($failed ? 1 : 0)
