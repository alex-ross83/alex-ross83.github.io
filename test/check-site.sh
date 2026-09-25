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
contains index.html '<span class="eyebrow">Daily coding practice</span>'
contains es/index.html '<span class="eyebrow">Práctica diaria de código</span>'
contains es/index.html '<span class="kicker">Últimas entradas</span>'
contains es/index.html 'Suscribirse <a'
contains es/index.html '>vía RSS</a>'
contains "es/$P1" '← Todas las entradas'
contains "$P1" '← All posts'
contains es/index.html 'data-label-dark="Cambiar a modo oscuro"'
contains es/index.html 'aria-label="Cambiar a modo oscuro"'
contains index.html '<a class="page-link" href="/about/">About</a>'
contains es/index.html '<a class="page-link" href="/es/about/">Acerca de</a>'
contains es/index.html '<p class="footer-desc">Escribo sobre mis experiencias'
contains index.html '<p class="footer-desc">Writing about my experiences'

echo "== Task 6: dates"
contains index.html 'Coding · Nov 28, 2018'
contains index.html 'Coding · Dec 5, 2018'
contains es/index.html 'Coding · 28 nov 2018'
contains es/index.html 'Coding · 5 dic 2018'
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
contains es/index.html "href=\"/es/$P1\""
contains es/index.html 'href="/es/feed.xml">vía RSS'
contains es/feed.xml "/es/$P1"
contains es/feed.xml 'Un nuevo día y un nuevo problema'
lacks feed.xml 'Un nuevo día y un nuevo problema'
same_count index.html es/index.html 'class="feed-post"'
contains es/index.html 'Un nuevo día y un nuevo problema'
lacks index.html 'Un nuevo día y un nuevo problema'
contains es/about/index.html 'hreflang="en-US" href="https://blog.ross-lopez.rocks/about/"'

exit $fail
