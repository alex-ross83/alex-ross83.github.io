#!/usr/bin/env bash
# Assertions against the built site. Usage: test/check-site.sh [site_dir]
set -u
SITE="${1:-_site}"
fail=0

pass() { printf '  ok    %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; fail=1; }

exists()   { [ -f "$SITE/$1" ] && pass "exists $1" || bad "missing $1"; }
absent()   { [ ! -e "$SITE/$1" ] && pass "absent $1" || bad "should not exist: $1"; }
contains() { grep -qF -- "$2" "$SITE/$1" 2>/dev/null && pass "$1 has: $2" || bad "$1 lacks: $2"; }
lacks()    { [ -f "$SITE/$1" ] && ! grep -qF -- "$2" "$SITE/$1" && pass "$1 free of: $2" || bad "$1 must exist and not have: $2"; }
same_count() {
  local a b
  a=$(grep -oF -- "$3" "$SITE/$1" 2>/dev/null | wc -l | tr -d ' ')
  b=$(grep -oF -- "$3" "$SITE/$2" 2>/dev/null | wc -l | tr -d ' ')
  [ "$a" = "$b" ] && pass "same count of '$3' ($a) in $1 and $2" || bad "count of '$3': $1=$a $2=$b"
}
count_is() {
  local n
  n=$(grep -oF -- "$2" "$SITE/$1" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" = "$3" ] && pass "$1 has '$2' x$3" || bad "$1 has '$2' x$n, want $3"
}
# card_match FILE KEY NEEDLE -> 0 if the <article data-section="KEY"> in FILE contains NEEDLE
card_match() {
  KEY="$2" NEEDLE="$3" perl -0ne 'exit(!(/data-section="\Q$ENV{KEY}\E"(.*?)<\/article>/s && index($1, $ENV{NEEDLE}) >= 0))' "$SITE/$1" 2>/dev/null
}
card_has()   { card_match "$1" "$2" "$3" && pass "$1 card $2 has: $3" || bad "$1 card $2 lacks: $3"; }
# lacks_re FILE ERE -> FILE exists and no line matches the extended regex
lacks_re() { [ -f "$SITE/$1" ] && ! grep -qE -- "$2" "$SITE/$1" && pass "$1 free of /$2/" || bad "$1 matches /$2/: $(grep -oE -- "$2" "$SITE/$1" 2>/dev/null | head -3 | tr '\n' ' ')"; }
# menu_has FILE NEEDLE -> the <div id="site-menu"> in FILE contains NEEDLE
menu_has() {
  NEEDLE="$2" perl -0ne 'exit(!(/<div class="site-menu" id="site-menu">(.*?)<\/div>/s && index($1, $ENV{NEEDLE}) >= 0))' "$SITE/$1" 2>/dev/null \
    && pass "$1 menu has: $2" || bad "$1 menu lacks: $2"
}
card_lacks() { card_match "$1" "$2" "$3" && bad "$1 card $2 should not have: $3" || pass "$1 card $2 free of: $3"; }
# before FILE A B -> A appears earlier in FILE than B (both present)
before() {
  A="$2" B="$3" perl -0ne '$c=$_; $ia=index($c,$ENV{A}); $ib=index($c,$ENV{B}); exit(!($ia>=0 && $ib>=0 && $ia<$ib))' "$SITE/$1" \
    && pass "$1: '$2' comes before '$3'" || bad "$1: '$2' does not come before '$3'"
}

P1=coding/problem/2018/11/28/daily-coding-problem-1.html
P2=coding/problem/2018/11/29/daily-coding-problem-2.html
P3=coding/problem/2018/12/05/daily-coding-problem.html
P4=coding/problem/2018/12/06/daily-coding-problem-4.html

echo "== Task 1: URLs in both trees"
for p in index.html about/index.html 404.html feed.xml "$P1" "$P2" "$P3" "$P4"; do
  exists "$p"
  exists "es/$p"
done
contains es/index.html 'href="/assets/main.css"'
contains es/$P1 'href="/assets/main.css"'
lacks index.html 'rosslopez'

echo "== Task 2: Spanish pages"
contains about/index.html '<h1 class="post-title">About</h1>'
contains es/about/index.html '<h1 class="post-title">Acerca de</h1>'
contains 404.html 'Page not found'
contains es/404.html 'Página no encontrada'
contains es/about/index.html 'href="https://jekyllrb.com/"'
absent es/about-es.html
absent es/about-es/index.html
absent about-es/index.html
absent es/404-es.html

echo "== Task 3: Spanish posts"
for P in "$P1" "$P2" "$P3" "$P4"; do
  # Spanish posts keep the English title
  title=$(grep -o 'itemprop="name headline">[^<]*</h1>' "$SITE/$P")
  [ -n "$title" ] && contains "es/$P" "$title" || bad "no title found in $P"
  same_count "$P" "es/$P" '<pre'
  same_count "$P" "es/$P" '<code'
  same_count "$P" "es/$P" 'href="http'
  lacks "es/$P" '&lt;/content&gt;'
done
contains "$P1" 'itemprop="name headline">Daily Coding Problem # 1</h1>'
contains "es/$P1" 'Esta es mi versión de los ejercicios'
absent coding/problem/2018/11/28/daily-coding-problem-1-es.html
absent es/coding/problem/2018/11/28/daily-coding-problem-1-es.html

echo "== Task 4: lang, hreflang, canonical"
contains index.html '<html lang="en-US">'
contains es/index.html '<html lang="es-MX">'
contains "es/$P1" '<html lang="es-MX">'
for f in "$P1" "es/$P1"; do
  contains "$f" "hreflang=\"en-US\" href=\"https://blog.ross-lopez.rocks/$P1\""
  contains "$f" "hreflang=\"es-MX\" href=\"https://blog.ross-lopez.rocks/es/$P1\""
done
contains index.html 'hreflang="es-MX" href="https://blog.ross-lopez.rocks/es/"'
contains es/index.html 'hreflang="en-US" href="https://blog.ross-lopez.rocks/"'
contains "es/$P1" "rel=\"canonical\" href=\"https://blog.ross-lopez.rocks/es/$P1\""
contains "$P1" "rel=\"canonical\" href=\"https://blog.ross-lopez.rocks/$P1\""

echo "== Task 5: UI strings"
contains index.html '<span class="eyebrow">AI, code &amp; quick starts</span>'
contains es/index.html '<span class="eyebrow">IA, código y guías rápidas</span>'
contains index.html '<span class="site-title">Rosipedia</span>'
contains es/index.html '<span class="site-title">Rosipedia</span>'
lacks index.html 'Study Blog'
contains es/index.html '<h2 class="kicker">Últimas entradas</h2>'
contains es/index.html 'Suscribirse <a'
contains es/index.html '>vía RSS</a>'
contains "es/$P1" '← Todas las entradas'
contains "$P1" '← All posts'
contains es/index.html 'data-label-dark="Cambiar a modo oscuro"'
contains es/index.html 'aria-label="Cambiar a modo oscuro"'
contains index.html '<a class="page-link" href="/about/">About</a>'
contains es/index.html '<a class="page-link" href="/es/about/">Acerca de</a>'
contains es/index.html '<p class="footer-desc">Contenido breve sobre IA, problemas de programación, guías rápidas, tips y noticias de tecnología.</p>'
contains index.html '<p class="footer-desc">Bite-sized takes on AI, coding problems, quick starts, tips and tech news.</p>'
lacks index.html 'Programming Interview questions'

echo "== Task 6: dates"
contains "es/$P1" '28 nov 2018'
contains "$P1" 'Nov 28, 2018'
lacks es/index.html 'Nov 28, 2018'

echo "== Task 7: language switcher"
contains "$P1"    "<a class=\"page-link\" lang=\"es-MX\" hreflang=\"es-MX\" href=\"/es/$P1\">ES</a>"
contains "es/$P1" "<a class=\"page-link\" lang=\"en-US\" hreflang=\"en-US\" href=\"/$P1\">EN</a>"
contains "es/$P1" '<span class="page-link" lang="es-MX" aria-current="true">ES</span>'
contains "$P1"    '<span class="page-link" lang="en-US" aria-current="true">EN</span>'
contains index.html    '<a class="page-link" lang="es-MX" hreflang="es-MX" href="/es/">ES</a>'
contains es/index.html '<a class="page-link" lang="en-US" hreflang="en-US" href="/">EN</a>'
contains es/about/index.html '<a class="page-link" lang="en-US" hreflang="en-US" href="/about/">EN</a>'
contains es/index.html '<nav class="site-nav lang-switch" aria-label="Idioma">'

echo "== Final review fixes"
# Finding 1: og:url / JSON-LD url point at the /es/ URL on Spanish pages, English pages unaffected
contains "es/$P1" 'og:url" content="https://blog.ross-lopez.rocks/es/'"$P1"'"'
lacks "es/$P1" '"url":"https://blog.ross-lopez.rocks/'"$P1"'"'
contains es/index.html 'og:url" content="https://blog.ross-lopez.rocks/es/"'
contains "$P1" 'og:url" content="https://blog.ross-lopez.rocks/'"$P1"'"'
lacks "es/$P1" 'blog.ross-lopez.rocks/es/es/'

# Finding 2: og:locale is en_US on English pages, es_MX on Spanish pages (incl. pages with no lang front matter)
contains index.html 'og:locale" content="en_US"'
contains es/index.html 'og:locale" content="es_MX"'
contains "$P1" 'og:locale" content="en_US"'
contains "es/$P1" 'og:locale" content="es_MX"'

# Finding 3: Spanish readers stay in /es/, no cross-language leakage
contains "es/$P1" 'back-link" href="/es/"'
contains es/index.html 'href="/es/feed.xml">vía RSS'
lacks feed.xml 'Un nuevo día y un nuevo problema'
contains "es/$P2" 'un nuevo problema por resolver'
# every entry in the Spanish feed links inside /es/ (content-independent; jekyll-feed keeps only the newest 10)
perl -0ne 'my @l = /<entry[^>]*>.*?<link href="([^"]+)"/sg; exit(!(@l && !grep { !m{^https://blog\.ross-lopez\.rocks/es/} } @l))' "$SITE/es/feed.xml" \
  && pass "es/feed.xml entries all link inside /es/" || bad "es/feed.xml has entries linking outside /es/"
same_count index.html es/index.html 'class="feed-post"'
lacks index.html 'Un nuevo día y un nuevo problema'
contains es/about/index.html 'hreflang="en-US" href="https://blog.ross-lopez.rocks/about/"'

echo "== Series"
SER=series/index.html
exists "$SER"
exists "es/$SER"
contains "$SER" '<section class="series" id="daily-coding-problem">'
contains "es/$SER" '<section class="series" id="daily-coding-problem">'
contains "$SER" 'My solutions to the problems'
contains "es/$SER" 'Mis soluciones a los problemas'
# Parts listed oldest first, each language linking to its own posts
order=$(grep -o 'href="/[^"]*daily-coding-problem[^"]*\.html"' "$SITE/$SER" 2>/dev/null | tr '\n' ' ')
[ "$order" = "href=\"/$P1\" href=\"/$P2\" href=\"/$P3\" href=\"/$P4\" " ] && pass "series page lists parts in order" || bad "series page order: $order"
order=$(grep -o 'href="/es/[^"]*daily-coding-problem[^"]*\.html"' "$SITE/es/$SER" 2>/dev/null | tr '\n' ' ')
[ "$order" = "href=\"/es/$P1\" href=\"/es/$P2\" href=\"/es/$P3\" href=\"/es/$P4\" " ] && pass "es series page lists parts in order" || bad "es series page order: $order"
# Nav link
contains index.html '<a class="page-link" href="/series/">Series</a>'
contains es/index.html '<a class="page-link" href="/es/series/">Series</a>'
# Post label: series name + part number, linking to the series section
contains "$P2" '<a class="kicker" href="/series/#daily-coding-problem">Daily Coding Problem · Part 2 of 4</a>'
contains "es/$P2" '<a class="kicker" href="/es/series/#daily-coding-problem">Daily Coding Problem · Parte 2 de 4</a>'
contains "$P4" 'Daily Coding Problem · Part 4 of 4</a>'
# Previous / next within the series
lacks "$P1" 'rel="prev"'
contains "$P1" "rel=\"next\" href=\"/$P2\""
contains "$P4" "rel=\"prev\" href=\"/$P3\""
lacks "$P4" 'rel="next"'
contains "es/$P2" "rel=\"prev\" href=\"/es/$P1\""
contains "es/$P2" "rel=\"next\" href=\"/es/$P3\""
contains "es/$P2" '← Anterior'
contains "$P2" 'Next →'

echo "== Signal home: hero"
for f in index.html es/index.html; do
  contains "$f" '<section class="hero">'
done
contains index.html    'class="btn btn-ghost" href="/series/"'
contains es/index.html 'class="btn btn-ghost" href="/es/series/"'
contains index.html    '<h1 class="hero-title">Bite-sized takes on AI and code</h1>'
contains es/index.html '<h1 class="hero-title">Ideas breves sobre IA y código</h1>'
contains index.html    'Read the latest →'
contains es/index.html 'Lee lo más reciente →'
contains index.html    'All series</a>'
contains es/index.html 'Todas las series</a>'

echo "== Signal home: sections"
for f in index.html es/index.html; do
  count_is "$f" 'class="section-card"' 4
  order=$(grep -o 'data-section="[^"]*"' "$SITE/$f" 2>/dev/null | tr '\n' ' ')
  [ "$order" = 'data-section="ai" data-section="quick-starts" data-section="tips-news" data-section="coding" ' ] \
    && pass "$f section order" || bad "$f section order: $order"
  contains "$f" 'id="sections"'
done
contains index.html    '<h2 class="kicker">Sections</h2>'
contains es/index.html '<h2 class="kicker">Secciones</h2>'
contains index.html    'Tips &amp; news'
contains es/index.html 'Tips y noticias'
card_has   es/index.html coding 'Soluciones a problemas de tipo entrevista técnica con explicaciones.'

echo "== Home content (derived from _posts/)"
ruby "$(dirname "$0")/site_checks.rb" home "$SITE" || fail=1

echo "== Signal styles"
for f in index.html es/index.html "$P1" "es/$P1" about/index.html es/about/index.html series/index.html 404.html; do
  contains "$f" 'family=Manrope:wght@400;600;800&family=JetBrains+Mono:wght@400;500&display=swap'
  lacks "$f" 'Literata'
done
contains assets/main.css 'Manrope'
contains assets/main.css '#5F4FCF'
contains assets/main.css '#8E8CF5'
lacks assets/main.css 'Literata'
# Rouge wraps {% highlight %} in <figure>; its UA 40px margin must be reset so code aligns with text
contains assets/main.css '.post-content figure'

echo "== Mobile menu"
for f in index.html es/index.html "$P1" "es/$P1" about/index.html es/about/index.html series/index.html 404.html; do
  contains "$f" 'class="menu-toggle" type="button" aria-expanded="false" aria-controls="site-menu"'
  menu_has "$f" 'class="site-nav"'
  menu_has "$f" 'class="site-nav lang-switch"'
  contains "$f" "document.documentElement.classList.add('js')"
done
contains index.html    'aria-label="Menu"'
contains es/index.html 'aria-label="Menú"'
contains assets/main.css '.menu-toggle'
# the open phone menu is one row (Series, About | EN ES), not a vertical stack
perl -0ne 'exit(/\.site-menu[^{]*\{[^}]*flex-direction:\s*column/ ? 1 : 0)' "$SITE/assets/main.css" \
  && pass "phone menu is a single row" || bad "phone menu stacks its items in a column"
# .masthead-row shares its element with .wrap; a "padding: X 0" shorthand would wipe the side gutter
perl -0ne 'exit(/\.masthead-row\s*\{[^}]*\bpadding:\s*\S+\s+0\s*;/ ? 1 : 0)' "$SITE/assets/main.css" \
  && pass "masthead-row keeps the .wrap side gutter" || bad "masthead-row padding shorthand zeroes the side gutter"

echo "== Tap targets and text scaling"
contains assets/main.css 'min-height: 44px'
# font sizes must be relative (rem) so the reader's default text size is honored
lacks_re assets/main.css 'font-size: [0-9.]+px'
lacks_re assets/main.css '--(hero|h1|title|text|read|kicker-size): *[0-9.]+px'

echo "== Post URLs (new-style posts)"
ruby "$(dirname "$0")/site_checks.rb" post-urls "$SITE" || fail=1

echo "== Language links (every page)"
ruby "$(dirname "$0")/site_checks.rb" lang-links "$SITE" || fail=1

echo "== Post heading order (audit A1)"
ruby "$(dirname "$0")/site_checks.rb" heading-order "$SITE" || fail=1

echo "== Sitemap and robots"
exists sitemap.xml
exists robots.txt
absent es/sitemap.xml
absent es/robots.txt
contains robots.txt 'Sitemap: https://blog.ross-lopez.rocks/sitemap.xml'
contains sitemap.xml 'xmlns:xhtml="http://www.w3.org/1999/xhtml"'
lacks sitemap.xml '/404.html'
python3 -c 'import sys, xml.etree.ElementTree as E; E.parse(sys.argv[1])' "$SITE/sitemap.xml" 2>/dev/null \
  && pass "sitemap.xml is well-formed XML" || bad "sitemap.xml is not well-formed XML"
ruby "$(dirname "$0")/site_checks.rb" sitemap "$SITE" || fail=1

echo "== Spanish suggestion banner"
for f in index.html about/index.html series/index.html "$P1"; do
  contains "$f" '<div class="lang-suggest" lang="es-MX" role="region" aria-label="Idioma" hidden>'
  contains "$f" '¿Prefieres leer en español?'
  contains "$f" 'aria-label="Cerrar"'
done
contains index.html          'class="lang-suggest-cta" hreflang="es-MX" href="/es/">Ver en español</a>'
contains about/index.html    'class="lang-suggest-cta" hreflang="es-MX" href="/es/about/">Ver en español</a>'
contains "$P1"               "class=\"lang-suggest-cta\" hreflang=\"es-MX\" href=\"/es/$P1\">Ver en español</a>"
for f in es/index.html es/about/index.html "es/$P1"; do
  lacks "$f" 'class="lang-suggest"'
done
contains index.html 'rosipediaLangSuggest'
contains assets/main.css '.lang-suggest[hidden]'

echo "== Spanish search snippets (audit S1)"
EN_DESC='Bite-sized takes on AI, coding problems, quick starts, tips and tech news.'
ES_DESC='Contenido breve sobre IA, problemas de programación, guías rápidas, tips y noticias de tecnología.'
for f in es/index.html es/about/index.html es/series/index.html es/404.html; do
  lacks "$f" "$EN_DESC"
done
contains es/index.html "<meta name=\"description\" content=\"$ES_DESC\""
contains es/index.html "property=\"og:description\" content=\"$ES_DESC\""
contains es/index.html "\"description\":\"$ES_DESC\""
contains index.html "<meta name=\"description\" content=\"$EN_DESC\""

echo "== Favicon (audit S2)"
exists favicon.svg
exists favicon.ico
exists apple-touch-icon.png
absent es/favicon.svg
for f in index.html es/index.html about/index.html es/about/index.html "$P1" "es/$P1" 404.html es/404.html; do
  contains "$f" '<link rel="icon" href="/favicon.svg" type="image/svg+xml">'
  contains "$f" '<link rel="icon" href="/favicon.ico" sizes="32x32">'
  contains "$f" '<link rel="apple-touch-icon" href="/apple-touch-icon.png">'
done

echo "== Short home title (audit S3)"
contains index.html '<title>Rosipedia: bite-sized takes on AI and code</title>'
contains es/index.html '<title>Rosipedia: microideas sobre IA y código</title>'
contains index.html 'og:title" content="Rosipedia: bite-sized takes on AI and code"'
contains es/index.html 'og:title" content="Rosipedia: microideas sobre IA y código"'
contains index.html 'twitter:title" content="Rosipedia: bite-sized takes on AI and code"'
contains es/index.html 'twitter:title" content="Rosipedia: microideas sobre IA y código"'
lacks index.html 'Rosipedia: bite-sized takes on AI and code | Rosipedia'
lacks es/index.html 'Rosipedia: microideas sobre IA y código | Rosipedia'

echo "== Unique page descriptions (audit S4)"
ABOUT_EN='Meet Alex-Ross: a dad, gamer and builder of Rosipedia, a bilingual blog on AI, quick starts, tips and coding problems.'
ABOUT_ES='Conoce a Alex-Ross: papá, gamer y creador de Rosipedia, un blog bilingüe sobre IA, guías rápidas, tips y problemas de programación.'
SERIES_EN='Every multi-part series on Rosipedia, in order, including the Daily Coding Problem walkthroughs.'
SERIES_ES='Todas las series de varias partes en Rosipedia, en orden, incluyendo las soluciones de Daily Coding Problem.'
NOTFOUND_EN='This page does not exist on Rosipedia. Check the URL or head back to the home page.'
NOTFOUND_ES='Esta página no existe en Rosipedia. Revisa la URL o regresa al inicio del sitio.'
contains about/index.html "<meta name=\"description\" content=\"$ABOUT_EN\""
contains es/about/index.html "<meta name=\"description\" content=\"$ABOUT_ES\""
contains series/index.html "<meta name=\"description\" content=\"$SERIES_EN\""
contains es/series/index.html "<meta name=\"description\" content=\"$SERIES_ES\""
contains 404.html "<meta name=\"description\" content=\"$NOTFOUND_EN\""
contains es/404.html "<meta name=\"description\" content=\"$NOTFOUND_ES\""
# each page's <meta description> must differ from the generic site description
lacks about/index.html "<meta name=\"description\" content=\"$EN_DESC\""
lacks series/index.html "<meta name=\"description\" content=\"$EN_DESC\""
lacks 404.html "<meta name=\"description\" content=\"$EN_DESC\""
lacks es/about/index.html "<meta name=\"description\" content=\"$ES_DESC\""
lacks es/series/index.html "<meta name=\"description\" content=\"$ES_DESC\""
lacks es/404.html "<meta name=\"description\" content=\"$ES_DESC\""
contains es/series/index.html '<html lang="es-MX">'
contains es/series/index.html '<a class="page-link" lang="en-US" hreflang="en-US" href="/series/">EN</a>'

echo "== Default social share image (audit S5)"
exists social-card.png
absent es/social-card.png
for f in index.html es/index.html about/index.html es/about/index.html series/index.html es/series/index.html 404.html es/404.html "$P1" "es/$P1"; do
  contains "$f" 'property="og:image" content="https://blog.ross-lopez.rocks/social-card.png"'
  contains "$f" 'name="twitter:image" content="https://blog.ross-lopez.rocks/social-card.png"'
  contains "$f" 'name="twitter:card" content="summary_large_image"'
done

echo "== Real headings for Latest/Sections (audit A2)"
for f in index.html es/index.html; do
  count_is "$f" '<h2 class="kicker">' 2
done
lacks index.html '<h2 class="feed-title"'
contains index.html '<h3 class="feed-title">'
lacks index.html '<h2 class="kicker section-title"'
contains index.html '<h3 class="kicker section-title">'

echo "== Skip-to-content link (audit A3)"
for f in index.html about/index.html "$P1" 404.html; do
  contains "$f" '<a class="skip-link" href="#main">Skip to content</a>'
  contains "$f" 'id="main"'
  before "$f" '<a class="skip-link" href="#main">Skip to content</a>' '<header class="masthead"'
done
contains es/index.html '<a class="skip-link" href="#main">Saltar al contenido</a>'
before es/index.html '<a class="skip-link" href="#main">Saltar al contenido</a>' '<header class="masthead"'
contains assets/main.css '.skip-link'

echo "== Google Search Console verification"
for f in index.html es/index.html; do
  contains "$f" '<meta name="google-site-verification" content="hpYViAb1tvW9NeImktdpED81Rxt0Fi-N8yjJkfq7Z_A" />'
done

exit $fail
