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

case ARGV[0]
when "home" then check_home
else abort "usage: ruby test/site_checks.rb <home|post-urls|lang-links|sitemap> [SITE_DIR]"
end
exit($failed ? 1 : 0)
