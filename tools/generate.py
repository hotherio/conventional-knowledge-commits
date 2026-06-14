#!/usr/bin/env python3
"""generate.py: render the CKC markdown docs into the styled, versioned site under docs/.

Pages live under /<version>/<language>/ (e.g. docs/0.1.0/en/spec.html); the site root
and /<version>/ redirect to the current version + default language. The nav is defined
once (templates/nav.html) and shared by every page, including the landing page.

No CI (the org disables Actions); run locally and commit docs/.
  python3 -m venv .ckc-venv
  .ckc-venv/bin/pip install -r tools/requirements.txt
  .ckc-venv/bin/python tools/generate.py
"""
import json
import os
import re
import shutil

import markdown
from jinja2 import Environment, FileSystemLoader, select_autoescape
from pymdownx.superfences import fence_div_format

# ---- paths -------------------------------------------------------------------
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TPL_DIR = os.path.join(ROOT, "tools", "templates")
DOCS = os.path.join(ROOT, "docs")

# ---- site config -------------------------------------------------------------
SITE = "https://conventional-knowledge-commits.org"   # official canonical origin
SITE_NAME = "Conventional Knowledge Commits"
DESCRIPTION = ("Structured commits for mathematical proofs and scientific findings: "
               "the two axes of knowledge change.")
VERSION = "0.1.0"          # current/latest version (the one the root redirects to)
LANG_CODE = "en"           # default language
VERSIONS = [("0.1.0", "current")]   # (label, sublabel) shown in the version selector, latest first
LANGS = [("en", "English")]         # (code, name) shown in the language selector
OUT = os.path.join(DOCS, VERSION, LANG_CODE)

CC_URL = "https://www.conventionalcommits.org/en/v1.0.0/"
GH_URL = "https://github.com/hotherio/conventional-knowledge-commits"
TOOLS_URL = "https://github.com/hotherio/ckc-tools"
VIEWER_URL = "https://claimgraph.conventional-knowledge-commits.org/"   # the live ClaimGraph viewer
GH_ICON = ('<svg viewBox="0 0 16 16" width="17" height="17" aria-hidden="true"><path fill="currentColor" '
           'd="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49'
           '-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 '
           '1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59'
           '.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.6 7.6 0 0 1 2-.27c.68 0 1.36.09 2 .27 '
           '1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 '
           '3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42'
           '-3.58-8-8-8z"/></svg>')
ASSET = "../../"   # from a /<version>/<language>/ page to the site root (where /assets lives)

# src markdown, output filename, <title> (before " · CKC"), extra <main> class
PAGES = [
    ("spec/v0.1.0.md",          "spec.html",            "Specification v0.1.0", ""),
    ("spec/proof-profile.md",   "proof-profile.html",   "Proof profile",        ""),
    ("spec/science-profile.md", "science-profile.html", "Science profile",      ""),
    ("claimgraph.md",           "claimgraph.html",      "The ClaimGraph",       ""),
    ("identifiers.md",          "identifiers.html",     "Stable identifiers",   ""),
    ("EXAMPLES.md",             "examples.html",        "Examples",             ""),
    ("tooling.md",              "tooling.html",         "Tooling",              ""),
    ("FAQ.md",                  "faq.html",             "FAQ",                  "faq"),
]

# ---- markdown ----------------------------------------------------------------
# GFM-equivalent feature set. Smart typography is intentionally OFF (no em dashes).
# Code is left un-highlighted (use_pygments False) to keep the minimalist look; flip
# it on and add a Pygments stylesheet to enable colour. KaTeX (math) and mermaid load
# only on pages that actually contain them.
MD_EXTENSIONS = [
    "tables", "footnotes", "attr_list", "def_list", "abbr", "sane_lists", "toc",
    "admonition", "pymdownx.highlight", "pymdownx.superfences", "pymdownx.arithmatex",
]
MD_CONFIG = {
    "toc": {"permalink": False},
    "pymdownx.highlight": {"use_pygments": False},
    "pymdownx.arithmatex": {"generic": True},
    "pymdownx.superfences": {
        "custom_fences": [{"name": "mermaid", "class": "mermaid", "format": fence_div_format}]
    },
}

# rewrite intra-doc .md links (any path prefix) to the flat .html page names
LINK_REWRITES = [
    (re.compile(r'href="[^"]*v0\.1\.0\.md"'),        'href="spec.html"'),
    (re.compile(r'href="[^"]*proof-profile\.md"'),   'href="proof-profile.html"'),
    (re.compile(r'href="[^"]*science-profile\.md"'), 'href="science-profile.html"'),
    (re.compile(r'href="[^"]*claimgraph\.md"'),      'href="claimgraph.html"'),
    (re.compile(r'href="[^"]*identifiers\.md"'),     'href="identifiers.html"'),
    (re.compile(r'href="[^"]*EXAMPLES\.md"'),        'href="examples.html"'),
    (re.compile(r'href="[^"]*FAQ\.md"'),             'href="faq.html"'),
    (re.compile(r'href="[^"]*README\.md"'),          'href="index.html"'),
]


def render_markdown(text):
    md = markdown.Markdown(extensions=MD_EXTENSIONS, extension_configs=MD_CONFIG, output_format="html")
    html = md.convert(text)
    for pat, repl in LINK_REWRITES:
        html = pat.sub(repl, html)
    return html


def jsonld(kind, title, url):
    website = {"@type": "WebSite", "name": SITE_NAME,
               "url": "{}/{}/{}/".format(SITE, VERSION, LANG_CODE)}
    if kind == "website":
        data = {"@context": "https://schema.org", "@type": "WebSite", "name": SITE_NAME,
                "url": url, "description": DESCRIPTION, "inLanguage": LANG_CODE}
    else:
        data = {"@context": "https://schema.org", "@type": "TechArticle", "headline": title,
                "url": url, "isPartOf": website, "inLanguage": LANG_CODE,
                "license": "https://creativecommons.org/licenses/by/4.0/"}
    return json.dumps(data, ensure_ascii=False, separators=(",", ":"))


def write(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print("  wrote", os.path.relpath(path, ROOT))


def main():
    env = Environment(
        loader=FileSystemLoader(TPL_DIR),
        autoescape=select_autoescape(["html"]),
        keep_trailing_newline=True,
    )
    env.globals.update(SITE=SITE, VERSION=VERSION, LANG_CODE=LANG_CODE, VERSIONS=VERSIONS,
                       LANGS=LANGS, CC_URL=CC_URL, GH_URL=GH_URL, TOOLS_URL=TOOLS_URL,
                       VIEWER_URL=VIEWER_URL, GH_ICON=GH_ICON, ASSET=ASSET)
    page_tpl = env.get_template("page.html")
    index_tpl = env.get_template("index.html")
    redirect_tpl = env.get_template("redirect.html")

    os.makedirs(OUT, exist_ok=True)
    print("rendering doc pages -> {} ...".format(os.path.relpath(OUT, ROOT)))

    # doc pages
    for src, out, title, extra in PAGES:
        body = render_markdown(open(os.path.join(ROOT, src), encoding="utf-8").read())
        canonical = "{}/{}/{}/{}".format(SITE, VERSION, LANG_CODE, out)
        full_title = "{} · CKC".format(title)
        write(os.path.join(OUT, out), page_tpl.render(
            title=full_title, og_title=full_title, canonical=canonical, cur=out,
            main_class=extra, content=body,
            jsonld=jsonld("article", full_title, canonical),
            needs_katex=("arithmatex" in body), needs_mermaid=('class="mermaid"' in body),
        ))

    # landing page (its own template; the rich hero is not markdown)
    landing_canonical = "{}/{}/{}/".format(SITE, VERSION, LANG_CODE)
    write(os.path.join(OUT, "index.html"), index_tpl.render(
        title=SITE_NAME, og_title=SITE_NAME, canonical=landing_canonical, cur="index.html",
        jsonld=jsonld("website", SITE_NAME, landing_canonical),
        needs_katex=False, needs_mermaid=False,
    ))

    # llms.txt: condensed spec for AI tools, kept at the stable site root
    shutil.copyfile(os.path.join(ROOT, "llms.txt"), os.path.join(DOCS, "llms.txt"))
    print("  copied docs/llms.txt")

    # redirect stubs
    def redirect(out_path, target, canon):
        write(os.path.join(DOCS, out_path), redirect_tpl.render(target=target, canon=canon))

    home = "{}/{}/{}/".format(SITE, VERSION, LANG_CODE)
    redirect("index.html", "{}/{}/".format(VERSION, LANG_CODE), home)
    redirect(os.path.join(VERSION, "index.html"), "{}/".format(LANG_CODE), home)
    redirect("404.html", "/{}/{}/".format(VERSION, LANG_CODE), home)
    # legacy: the ClaimGraph page was renamed from impact-graph.html
    redirect(os.path.join(VERSION, LANG_CODE, "impact-graph.html"), "claimgraph.html",
             "{}/{}/{}/claimgraph.html".format(SITE, VERSION, LANG_CODE))

    # SEO artifacts
    urls = [landing_canonical] + ["{}/{}/{}/{}".format(SITE, VERSION, LANG_CODE, out)
                                  for _, out, _, _ in PAGES]
    sitemap = ('<?xml version="1.0" encoding="UTF-8"?>\n'
               '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
               + "".join("  <url><loc>{}</loc></url>\n".format(u) for u in urls)
               + "</urlset>\n")
    write(os.path.join(DOCS, "sitemap.xml"), sitemap)
    # robots: allow everything (CKC wants AI tools to read llms.txt), point at the sitemap
    write(os.path.join(DOCS, "robots.txt"),
          "User-agent: *\nAllow: /\n\nSitemap: {}/sitemap.xml\n".format(SITE))

    check_links()
    print("done.")


def check_links():
    """Warn on internal links/assets that don't resolve to a generated file."""
    href_re = re.compile(r'(?:href|src)\s*=\s*"([^"]+)"')
    bad = 0
    for dp, _, fns in os.walk(DOCS):
        for fn in fns:
            if not fn.endswith(".html"):
                continue
            fp = os.path.join(dp, fn)
            for raw in href_re.findall(open(fp, encoding="utf-8").read()):
                if raw.startswith(("http://", "https://", "data:", "mailto:", "#")):
                    continue
                rel = raw.split("#")[0].split("?")[0]
                base = DOCS if rel.startswith("/") else dp   # site-absolute paths resolve from docs/
                target = os.path.normpath(os.path.join(base, rel.lstrip("/")))
                if raw.endswith("/"):
                    target = os.path.join(target, "index.html")
                if not os.path.exists(target):
                    print("  BROKEN LINK: {} -> {}".format(os.path.relpath(fp, ROOT), raw))
                    bad += 1
    print("  link check: {}".format("all internal links resolve" if not bad else "{} broken".format(bad)))


if __name__ == "__main__":
    main()
