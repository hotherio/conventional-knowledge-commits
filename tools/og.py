"""og.py: render branded 1200x630 social cards (the YASSG approach, on the CKC brand).

A card is the warm-paper background, an orange accent bar, the {C logo, the page
title wrapped in the monospace brand font, and a project byline. Fonts are bundled
under tools/fonts/ so the build is reproducible (no system-font dependency).
"""
import os
from PIL import Image, ImageDraw, ImageFont

OG_W, OG_H = 1200, 630
PAPER = (247, 244, 238)   # #f7f4ee
INK = (26, 26, 26)        # #1a1a1a
ACCENT = (231, 82, 5)     # #e75205, the logo orange
MUTED = (107, 114, 128)   # #6b7280

_FONTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fonts")
_TITLE_FONT = os.path.join(_FONTS, "DejaVuSansMono-Bold.ttf")
_BYLINE_FONT = os.path.join(_FONTS, "DejaVuSansMono.ttf")


def _wrap(draw, text, font, max_width):
    lines, cur = [], ""
    for word in text.split():
        trial = (cur + " " + word).strip()
        if draw.textlength(trial, font=font) <= max_width:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines


def card(title, out_path, *, logo, eyebrow, cta, accent=ACCENT, paper=PAPER):
    img = Image.new("RGB", (OG_W, OG_H), paper)
    draw = ImageDraw.Draw(img)
    draw.rectangle([0, 0, 14, OG_H], fill=accent)        # left accent bar

    margin = 84
    # logo, top-left
    logo_h = 90
    lg = Image.open(logo).convert("RGBA")
    lg = lg.resize((round(lg.width * logo_h / lg.height), logo_h), Image.LANCZOS)
    img.paste(lg, (margin, 58), lg)

    # title, wrapped, vertically centred between the logo and the byline
    tfont = ImageFont.truetype(_TITLE_FONT, 64)
    lines = _wrap(draw, title, tfont, OG_W - margin - 70)[:4]
    line_h = int(tfont.size * 1.16)
    block_h = line_h * len(lines)
    top, bottom = 58 + logo_h, OG_H - 112
    y = top + (bottom - top - block_h) // 2
    for line in lines:
        draw.text((margin, y), line, font=tfont, fill=INK)
        y += line_h

    # bottom row: byline (left) + a CTA button (right)
    bfont = ImageFont.truetype(_BYLINE_FONT, 27)
    cy = OG_H - 60
    draw.text((margin, cy), eyebrow.upper(), font=bfont, fill=accent, anchor="lm")
    pad_x, btn_h = 26, 54
    btn_w = draw.textlength(cta, font=bfont) + 2 * pad_x
    x1 = OG_W - margin
    draw.rounded_rectangle([x1 - btn_w, cy - btn_h // 2, x1, cy + btn_h // 2], radius=9, fill=accent)
    draw.text((x1 - btn_w / 2, cy), cta, font=bfont, fill=paper, anchor="mm")

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img.save(out_path, "PNG")
    return out_path
