#!/usr/bin/env bash
# build-pages.sh — render the CKC markdown docs into styled HTML pages.
# Pages live under a /<version>/<language>/ path (e.g. docs/0.1.0/en/spec.html);
# the site root and /<version>/ redirect to the current version + default language.
# No CI (the org disables Actions); run locally, commit the generated files.
# Requires: pandoc.  Usage:  tools/build-pages.sh
set -euo pipefail
cd "$(dirname "$0")/.."
command -v pandoc >/dev/null || { echo "pandoc required"; exit 127; }

# ---- site config -------------------------------------------------------------
SITE="https://conventional-knowledge-commits.org"   # official canonical origin
VERSION="0.1.0"          # current/latest version (the one the root redirects to)
LANG_CODE="en"           # default language
LANG_NAME="English"
OUT="docs/$VERSION/$LANG_CODE"   # where pages are written
# versions and languages offered in the nav selectors (latest first).
#   "0.1.0|current"  →  label v0.1.0, sublabel "current"
VERSIONS=( "0.1.0|current" )
#   "en|English"     →  label EN, panel "English / en"
LANGS=( "en|English" )

CC_URL="https://www.conventionalcommits.org/en/v1.0.0/"
GH_URL="https://github.com/hotherio/conventional-knowledge-commits"
TOOLS_URL="https://github.com/hotherio/ckc-tools"
# GitHub mark (inline SVG, inherits currentColor)
GH_ICON='<svg viewBox="0 0 16 16" width="17" height="17" aria-hidden="true"><path fill="currentColor" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.6 7.6 0 0 1 2-.27c.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>'

navlink(){ # $1 href  $2 label  $3 cur
  local cls=""; [ "$1" = "$3" ] && cls=" class=\"here\""
  printf '<a%s href="%s">%s</a>' "$cls" "$1" "$2"
}

render_nav(){ # $1 = current page filename (e.g. spec.html)
  local cur="$1" pcls="" cgcls="" tcls="" v vlabel vsub l lcode lname
  case "$cur" in proof-profile.html|science-profile.html) pcls=" here";; esac
  case "$cur" in claimgraph.html|identifiers.html) cgcls=" here";; esac
  case "$cur" in tooling.html) tcls=" here";; esac
  printf '<nav class="nav"><div class="wrap">'
  printf '<a class="home" href="index.html"><img class="brand" src="../../assets/logo.png" width="384" height="343" alt="">CKC</a><span class="sp"></span>'
  # Profiles dropdown
  printf '<div class="menu%s"><button class="menu-trigger" type="button" aria-haspopup="true" aria-expanded="false">Profiles</button><div class="menu-panel">' "$pcls"
  printf '<a href="proof-profile.html"><b>Proof</b><span>mathematics &amp; formal proving</span></a>'
  printf '<a href="science-profile.html"><b>Science</b><span>empirical research</span></a>'
  printf '</div></div>'
  # content links + ClaimGraph and Tooling dropdowns
  navlink "spec.html" "Spec" "$cur"
  printf '<div class="menu%s"><button class="menu-trigger" type="button" aria-haspopup="true" aria-expanded="false">ClaimGraph</button><div class="menu-panel">' "$cgcls"
  printf '<a href="claimgraph.html"><b>ClaimGraph</b><span>dependency graph of claims</span></a>'
  printf '<a href="identifiers.html"><b>Identifiers</b><span>stable names the graph references</span></a>'
  printf '</div></div>'
  navlink "examples.html" "Examples" "$cur"
  printf '<div class="menu%s"><button class="menu-trigger" type="button" aria-haspopup="true" aria-expanded="false">Tooling</button><div class="menu-panel">' "$tcls"
  printf '<a href="tooling.html"><b>Tooling</b><span>hooks, configs, CI</span></a>'
  printf '<a href="%s"><b>Pre-commit hooks \xe2\x86\x97</b><span>ckc-tools repository</span></a>' "$TOOLS_URL"
  printf '</div></div>'
  navlink "faq.html" "FAQ" "$cur"
  printf '<span class="navsep"></span>'
  # version selector — entries point to the same page under each version
  printf '<div class="menu sel"><button class="menu-trigger" type="button" aria-haspopup="true" aria-expanded="false">v%s</button><div class="menu-panel">' "$VERSION"
  for v in "${VERSIONS[@]}"; do
    vlabel="${v%%|*}"; vsub="${v##*|}"
    cls=""; [ "$vlabel" = "$VERSION" ] && cls=" class=\"cur\""
    printf '<a%s href="../../%s/%s/%s"><b>v%s</b><span>%s</span></a>' "$cls" "$vlabel" "$LANG_CODE" "$cur" "$vlabel" "$vsub"
  done
  printf '</div></div>'
  # language selector — entries point to the same page under each language
  printf '<div class="menu sel"><button class="menu-trigger" type="button" aria-haspopup="true" aria-expanded="false">%s</button><div class="menu-panel">' "$(echo "$LANG_CODE" | tr '[:lower:]' '[:upper:]')"
  for l in "${LANGS[@]}"; do
    lcode="${l%%|*}"; lname="${l##*|}"
    cls=""; [ "$lcode" = "$LANG_CODE" ] && cls=" class=\"cur\""
    printf '<a%s href="../%s/%s"><b>%s</b><span>%s</span></a>' "$cls" "$lcode" "$cur" "$lname" "$lcode"
  done
  printf '</div></div>'
  printf '<span class="navsep"></span>'
  printf '<a class="ext" href="%s" title="Conventional Commits 1.0.0">CC \xe2\x86\x97</a>' "$CC_URL"
  printf '<a class="gh" href="%s" aria-label="GitHub repository" title="GitHub repository">%s</a>' "$GH_URL" "$GH_ICON"
  printf '</div></nav>'
}

FOOTER='<footer><div class="wrap">Part of <a href="index.html">Conventional Knowledge Commits</a> · extends <a href="https://www.conventionalcommits.org/en/v1.0.0/">Conventional Commits 1.0.0</a> · spec licensed <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>.</div></footer>'

# rewrite intra-doc .md links (any path prefix) to the flat .html page names
rewrite(){
  sed -E \
    -e 's#href="[^"]*v0\.1\.0\.md"#href="spec.html"#g' \
    -e 's#href="[^"]*proof-profile\.md"#href="proof-profile.html"#g' \
    -e 's#href="[^"]*science-profile\.md"#href="science-profile.html"#g' \
    -e 's#href="[^"]*claimgraph\.md"#href="claimgraph.html"#g' \
    -e 's#href="[^"]*identifiers\.md"#href="identifiers.html"#g' \
    -e 's#href="[^"]*EXAMPLES\.md"#href="examples.html"#g' \
    -e 's#href="[^"]*FAQ\.md"#href="faq.html"#g' \
    -e 's#href="[^"]*README\.md"#href="index.html"#g'
}

page(){ # $1 src md   $2 out html   $3 <title>   $4 extra main class (optional)
  local src="$1" out="$2" title="$3" extra="${4:-}"
  { cat <<EOF
<!DOCTYPE html><html lang="$LANG_CODE"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title} · CKC</title>
<link rel="icon" href="../../assets/favicon.ico" sizes="16x16 32x32 48x48">
<link rel="icon" type="image/png" sizes="96x96" href="../../assets/favicon.png">
<link rel="apple-touch-icon" href="../../assets/apple-touch-icon.png">
<link rel="canonical" href="${SITE}/${VERSION}/${LANG_CODE}/${out}">
<meta property="og:title" content="${title} · CKC">
<meta property="og:url" content="${SITE}/${VERSION}/${LANG_CODE}/${out}">
<meta property="og:image" content="${SITE}/assets/og-image.png">
<link rel="stylesheet" href="../../assets/ckc.css">
</head><body>
$(render_nav "$out")
<main class="doc${extra:+ $extra}"><div class="wrap">
EOF
    pandoc -f gfm -t html --no-highlight "$src" | rewrite
    printf '</div></main>\n%s\n<script src="../../assets/nav.js" defer></script>\n</body></html>\n' "$FOOTER"
  } > "$OUT/$out"
  echo "  wrote $OUT/$out"
}

redirect(){ # $1 out-path (relative to docs/)   $2 target href (relative)   $3 canonical (absolute, optional)
  local out="$1" target="$2" canon="${3:-$SITE/$VERSION/$LANG_CODE/}"
  cat > "docs/$out" <<EOF
<!DOCTYPE html><html lang="$LANG_CODE"><head><meta charset="utf-8">
<title>Conventional Knowledge Commits</title>
<link rel="canonical" href="$canon">
<meta name="robots" content="noindex">
<meta http-equiv="refresh" content="0; url=$target">
<script>location.replace("$target"+location.search+location.hash)</script>
</head><body><p>Redirecting to <a href="$target">$target</a>…</p></body></html>
EOF
  echo "  wrote docs/$out (redirect → $target)"
}

mkdir -p "$OUT"
echo "rendering doc pages → $OUT …"
page spec/v0.1.0.md          spec.html             "Specification v0.1.0"
page spec/proof-profile.md   proof-profile.html    "Proof profile"
page spec/science-profile.md science-profile.html  "Science profile"
page claimgraph.md           claimgraph.html       "The ClaimGraph"
page identifiers.md          identifiers.html      "Stable identifiers"
page EXAMPLES.md             examples.html         "Examples"
page tooling.md              tooling.html          "Tooling"
page FAQ.md                  faq.html              "FAQ"            faq

# llms.txt: condensed spec for AI tools, kept at the stable site root
cp -f llms.txt docs/llms.txt && echo "  copied docs/llms.txt"

# redirect stubs: root and bare-version → current version + default language
redirect "index.html"          "$VERSION/$LANG_CODE/"
redirect "$VERSION/index.html" "$LANG_CODE/"
redirect "404.html"            "/$VERSION/$LANG_CODE/"   # catch-all (absolute)
# legacy: the ClaimGraph page was renamed from impact-graph.html
redirect "$VERSION/$LANG_CODE/impact-graph.html" "claimgraph.html" "$SITE/$VERSION/$LANG_CODE/claimgraph.html"
echo "done."
