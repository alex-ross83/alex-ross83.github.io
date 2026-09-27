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

ES_MONTHS = load_yaml(File.join(ROOT, "_data/es/months.yml"))

# Mirrors _includes/i18n_date.html (site timezone is Etc/UTC).
def display_date(post, lang)
  t = post_time(post).getutc
  lang == "es" ? "#{t.day} #{ES_MONTHS[t.month.to_s]} #{t.year}" : t.strftime("%b %-d, %Y")
end

# A home-page link must resolve to a built page and, on a non-default home, stay in that language.
def link_ok?(href, lang)
  return false unless href && file_for(href)
  lang == DEFAULT_LANG || href.start_with?("/#{lang}/")
end

def home_file(lang) = lang == DEFAULT_LANG ? "index.html" : "#{lang}/index.html"

def check_home
  LANGS.each do |lang|
    file = home_file(lang)
    html = File.read(File.join(SITE, file))
    s = STRINGS[lang]
    vis = visible_posts(lang)

    feed = html.scan(%r{<li class="feed-post">(.*?)</li>}m).flatten.map do |li|
      [li[%r{<span class="feed-kicker">(.*?)</span>}m, 1].to_s,
       li[/<h3 class="feed-title"><a href="([^"]+)"/, 1],
       li[%r{<h3 class="feed-title"><a href="[^"]+">(.*?)</a>}m, 1].to_s,
       li[%r{<span class="feed-meta">(.*?)</span>}m, 1].to_s.strip]
    end
    want = [vis.size, 5].min
    check(feed.size == want, "#{file}: Latest shows #{want} posts (got #{feed.size})")
    cta = html[/class="btn btn-cta" href="([^"]+)"/, 1]
    check(!cta.nil? && feed.first && cta == feed.first[1], "#{file}: hero CTA links to the newest post (#{cta.inspect})")

    feed.zip(vis).each do |(kicker, href, title, meta), post|
      next unless post
      check(unescape(title) == post[:data]["title"].to_s, "#{file}: Latest item '#{unescape(title)}' is in date order")
      check(meta == display_date(post, lang), "#{file}: date of '#{post[:data]["title"]}' shows as '#{display_date(post, lang)}'")
      check(link_ok?(href, lang), "#{file}: link of '#{post[:data]["title"]}' (#{href}) resolves#{lang == DEFAULT_LANG ? "" : " inside /#{lang}/"}")
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
        links = card.scan(%r{<li><a href="([^"]+)">(.*?)</a></li>}m)
        titles = links.map { |_h, t| unescape(t) }
        expected = in_sec.first(3).map { |p| p[:data]["title"].to_s }
        check(titles == expected, "#{file}: card #{key} lists its #{expected.size} newest posts")
        check(links.all? { |h, _t| link_ok?(h, lang) }, "#{file}: card #{key} links resolve#{lang == DEFAULT_LANG ? "" : " inside /#{lang}/"}")
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
    # The URL keeps the section word it was published with, so any section's word is valid
    # (reshelving edits section: only; URLs are permanent).
    words = SECTIONS.values.filter_map { |s| s.dig("path", lang) }
    re = %r{\A/#{ROOT_WORD[lang]}/(?:#{words.map { |w| Regexp.escape(w) }.join("|")})/[a-z0-9]+(?:-[a-z0-9]+)*/\z}
    check(re.match?(d["permalink"].to_s), "#{p[:file]}: permalink #{d["permalink"]} matches /#{ROOT_WORD[lang]}/<section word>/<slug>/")
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

def switcher_href(html) = html[/class="page-link" lang="[^"]*" hreflang="[^"]*" aria-label="[^"]*" href="([^"]+)"/, 1]

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

# sitemap.xml lists every page with a language switcher (except 404s) exactly once, each with
# one hreflang alternate per language, and every alternate resolves to a built page.
def check_sitemap
  path = File.join(SITE, "sitemap.xml")
  return bad("sitemap.xml is missing") unless File.file?(path)

  xml = File.read(path)
  locs = xml.scan(%r{<loc>#{Regexp.escape(SITE_URL)}([^<]*)</loc>}).flatten
  pages = Dir[File.join(SITE, "**/*.html")].map { |f| f.delete_prefix("#{SITE}/") }
                                            .select { |rel| File.read(File.join(SITE, rel)).include?('class="site-nav lang-switch"') }
                                            .map { |rel| url_for(rel) }
                                            .reject { |u| u.end_with?("404.html") }
  check(locs.tally.values.all? { |n| n == 1 }, "sitemap has no duplicate URLs")
  missing = pages - locs
  extra = locs - pages
  check(missing.empty? && extra.empty?, "sitemap lists all #{pages.size} pages (missing: #{missing.first(5)}, extra: #{extra.first(5)})")
  broken = []
  xml.scan(%r{<url>(.*?)</url>}m).flatten.each do |u|
    alts = u.scan(/<xhtml:link rel="alternate" hreflang="[^"]+" href="#{Regexp.escape(SITE_URL)}([^"]*)"/).flatten
    broken << "#{u[/<loc>([^<]*)/, 1]}: #{alts.size} alternates" unless alts.size == LANGS.size
    alts.each { |a| broken << "alternate #{a} (no such page)" unless file_for(a) }
  end
  check(broken.empty?, "every sitemap URL has #{LANGS.size} resolving alternates" + (broken.empty? ? "" : ": #{broken.first(5)}"))
end

# Every built page with .post-content, alongside the raw HTML.
def post_pages
  Dir[File.join(SITE, "**/*.html")].map { |f| f.delete_prefix("#{SITE}/") }
                                    .select { |rel| File.read(File.join(SITE, rel)).include?('class="post-content e-content"') }
end

# Slices out the article body (H1, the post title, lives outside it, hence its own marker set).
def post_content_html(html)
  marker = /<nav class="series-nav"|<a class="btn btn-ghost back-link|<\/article>/
  html[/<div class="post-content e-content"[^>]*>(.*?)(?=#{marker})/m, 1]
end

# No heading level jumps inside .post-content (H1, the post title, lives outside it): a post
# must not go straight from the implied h1 to h3+, or from an hN to hN+2 or deeper.
def check_heading_order
  files = post_pages
  return bad("no post pages found to check heading order") if files.empty?

  broken = []
  files.each do |rel|
    content = post_content_html(File.read(File.join(SITE, rel)))
    next broken << "#{rel}: could not find the end of .post-content" if content.nil?

    prev = 1 # the page's own <h1> post title, rendered outside .post-content
    content.scan(/<h([1-6])[ >]/).flatten.map(&:to_i).each do |lvl|
      broken << "#{rel}: heading jumps from h#{prev} to h#{lvl}" if lvl > prev + 1
      prev = lvl
    end
  end
  check(broken.empty?, "no heading level skips inside .post-content" +
                       (broken.empty? ? "" : ":\n        " + broken.first(10).join("\n        ")))
end

# A <table> inside post content must be wrapped in a keyboard-scrollable, localized-labeled
# region (the same treatment post.html gives overflowing <pre> blocks), so a wide table scrolls
# in its own box instead of the whole page scrolling sideways.
def check_table_scroll
  found = 0
  broken = []
  post_pages.each do |rel|
    html = File.read(File.join(SITE, rel))
    content = post_content_html(html)
    next if content.nil?
    tables = content.scan("<table>").size
    next if tables.zero?
    found += tables
    lang = html[/<html lang="(\w\w)-/, 1] || DEFAULT_LANG
    label = STRINGS[lang]["table_region"]
    wrapped = content.scan(/<div class="table-scroll" tabindex="0" role="region" aria-label="#{Regexp.escape(label)}">\s*<table>.*?<\/table>\s*<\/div>/m).size
    broken << "#{rel}: #{tables} <table> but only #{wrapped} wrapped with aria-label #{label.inspect}" unless wrapped == tables
  end
  check(found.positive?, "found #{found} <table> elements to check")
  check(broken.empty?, "every table is wrapped in a keyboard-scrollable, labeled region" +
                       (broken.empty? ? "" : ":\n        " + broken.first(10).join("\n        ")))
end

case ARGV[0]
when "home"           then check_home
when "post-urls"      then check_post_urls
when "lang-links"     then check_lang_links
when "sitemap"        then check_sitemap
when "heading-order"  then check_heading_order
when "table-scroll"   then check_table_scroll
else abort "usage: ruby test/site_checks.rb <home|post-urls|lang-links|sitemap|heading-order|table-scroll> [SITE_DIR]"
end
exit($failed ? 1 : 0)
