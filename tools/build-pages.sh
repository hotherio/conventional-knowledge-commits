#!/usr/bin/env bash
# build-pages.sh — render the CKC markdown docs into styled HTML pages under docs/.
# No CI (the org disables Actions); run locally, commit the generated docs/*.html.
# Requires: pandoc.  Usage:  tools/build-pages.sh
set -euo pipefail
cd "$(dirname "$0")/.."
command -v pandoc >/dev/null || { echo "pandoc required"; exit 127; }

ICON="data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20viewBox='0%200%2032%2032'%3E%3Crect%20width='32'%20height='32'%20fill='%23f7f4ee'/%3E%3Cpath%20d='M9%206V26H27'%20stroke='%231a1a1a'%20stroke-width='2.4'%20fill='none'/%3E%3Ccircle%20cx='20'%20cy='13'%20r='3.4'%20fill='%23a9c39c'%20stroke='%231a1a1a'%20stroke-width='1.2'/%3E%3C/svg%3E"

# nav: label|href  (Home first; Proof/Science live in the Profiles dropdown)
NAV=( "Home|index.html" "Spec|spec.html" "ClaimGraph|impact-graph.html" \
      "Identifiers|identifiers.html" "Examples|examples.html" \
      "Tooling|tooling.html" "FAQ|faq.html" )
CC_URL="https://www.conventionalcommits.org/en/v1.0.0/"

render_nav(){ # $1 = current href
  local cur="$1" item label href cls pcls=""
  case "$cur" in proof-profile.html|science-profile.html) pcls=" here";; esac
  printf '<nav class="nav"><div class="wrap">'
  printf '<a class="home" href="index.html">CKC</a><span class="sp"></span>'
  printf '<div class="menu%s"><button class="menu-trigger" type="button" aria-haspopup="true" aria-expanded="false">Profiles</button><div class="menu-panel">' "$pcls"
  printf '<a href="proof-profile.html"><b>Proof</b><span>mathematics &amp; formal proving</span></a>'
  printf '<a href="science-profile.html"><b>Science</b><span>empirical research</span></a>'
  printf '</div></div>'
  for item in "${NAV[@]:1}"; do
    label="${item%%|*}"; href="${item##*|}"
    cls=""; [ "$href" = "$cur" ] && cls=" class=\"here\""
    printf '<a%s href="%s">%s</a>' "$cls" "$href" "$label"
  done
  printf '<a class="ext" href="%s">Conventional Commits \xe2\x86\x97</a>' "$CC_URL"
  printf '</div></nav>'
}

FOOTER='<footer><div class="wrap">Part of <a href="index.html">Conventional Knowledge Commits</a> · extends <a href="https://www.conventionalcommits.org/en/v1.0.0/">Conventional Commits 1.0.0</a> · spec licensed <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>.</div></footer>'

# rewrite intra-doc .md links (any path prefix) to the flat .html page names
rewrite(){
  sed -E \
    -e 's#href="[^"]*v0\.1\.0\.md"#href="spec.html"#g' \
    -e 's#href="[^"]*proof-profile\.md"#href="proof-profile.html"#g' \
    -e 's#href="[^"]*science-profile\.md"#href="science-profile.html"#g' \
    -e 's#href="[^"]*impact-graph\.md"#href="impact-graph.html"#g' \
    -e 's#href="[^"]*identifiers\.md"#href="identifiers.html"#g' \
    -e 's#href="[^"]*EXAMPLES\.md"#href="examples.html"#g' \
    -e 's#href="[^"]*FAQ\.md"#href="faq.html"#g' \
    -e 's#href="[^"]*README\.md"#href="index.html"#g'
}

page(){ # $1 src md   $2 out html   $3 <title>   $4 extra main class (optional)
  local src="$1" out="$2" title="$3" extra="${4:-}"
  { cat <<EOF
<!DOCTYPE html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title} · CKC</title>
<link rel="icon" href="${ICON}">
<link rel="stylesheet" href="assets/ckc.css">
</head><body>
$(render_nav "$out")
<main class="doc${extra:+ $extra}"><div class="wrap">
EOF
    pandoc -f gfm -t html --no-highlight "$src" | rewrite
    printf '</div></main>\n%s\n<script src="assets/nav.js" defer></script>\n</body></html>\n' "$FOOTER"
  } > "docs/$out"
  echo "  wrote docs/$out"
}

echo "rendering doc pages…"
page spec/v0.1.0.md        spec.html             "Specification v0.1.0"
page spec/proof-profile.md proof-profile.html    "Proof profile"
page spec/science-profile.md science-profile.html "Science profile"
page impact-graph.md       impact-graph.html     "The ClaimGraph"
page identifiers.md        identifiers.html      "Stable identifiers"
page EXAMPLES.md           examples.html         "Examples"
page tooling.md            tooling.html          "Tooling"
page FAQ.md                faq.html              "FAQ"            faq
# llms.txt: condensed spec for AI tools, served at the site root
cp -f llms.txt docs/llms.txt 2>/dev/null && echo "  copied docs/llms.txt"
echo "done."
