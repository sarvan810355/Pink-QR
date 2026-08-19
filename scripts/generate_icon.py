"""
Generates QR Bloom's app icon and splash logo assets programmatically
(no external design tool available in this environment) — a minimalist
mark combining a QR "finder pattern" corner with a blooming flower, in
the app's pink / rose-gold palette.

Run: python3 scripts/generate_icon.py
Outputs into assets/icon/: app_icon.png, splash_logo.png, splash_logo_dark.png
"""

import math
from PIL import Image, ImageDraw

BLUSH = (255, 246, 249, 255)
SOFT_PINK = (255, 214, 232, 255)
HOT_PINK = (255, 139, 171, 255)
HOT_PINK_2 = (255, 107, 129, 255)
ROSE_GOLD = (183, 110, 121, 255)
ROSE_GOLD_LIGHT = (232, 180, 184, 255)
WHITE = (255, 251, 253, 255)
CHARCOAL = (36, 27, 30, 255)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(4))


def diagonal_gradient(size, c1, c2):
    img = Image.new("RGBA", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * size)
            px[x, y] = lerp(c1, c2, t)
    return img


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return mask


def draw_finder_mark(draw, cx, cy, s, color):
    """A single rounded QR 'finder pattern' square: outer ring + inner dot."""
    r = s * 0.22
    draw.rounded_rectangle(
        [cx - s / 2, cy - s / 2, cx + s / 2, cy + s / 2], radius=r, outline=color, width=int(s * 0.16)
    )
    inner = s * 0.34
    draw.rounded_rectangle(
        [cx - inner / 2, cy - inner / 2, cx + inner / 2, cy + inner / 2],
        radius=r * 0.5,
        fill=color,
    )


def draw_flower(img, cx, cy, petal_r, color, petal_count=5, core_color=None):
    draw = ImageDraw.Draw(img)
    orbit = petal_r * 0.95
    for i in range(petal_count):
        angle = (2 * math.pi / petal_count) * i - math.pi / 2
        px = cx + orbit * math.cos(angle)
        py = cy + orbit * math.sin(angle)
        draw.ellipse([px - petal_r, py - petal_r, px + petal_r, py + petal_r], fill=color)
    core_r = petal_r * 0.85
    draw.ellipse(
        [cx - core_r, cy - core_r, cx + core_r, cy + core_r],
        fill=core_color or WHITE,
    )


def make_app_icon(path, size=1024):
    bg = diagonal_gradient(size, SOFT_PINK, HOT_PINK)
    mask = rounded_mask(size, int(size * 0.22))
    icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    icon.paste(bg, (0, 0), mask)

    # Floating white "card" for the mark to sit on.
    card_size = int(size * 0.72)
    card = Image.new("RGBA", (card_size, card_size), (0, 0, 0, 0))
    card_mask = rounded_mask(card_size, int(card_size * 0.26))
    card_fill = Image.new("RGBA", (card_size, card_size), WHITE)
    card.paste(card_fill, (0, 0), card_mask)
    card_pos = ((size - card_size) // 2, (size - card_size) // 2)
    icon.alpha_composite(card, card_pos)

    draw = ImageDraw.Draw(icon)
    draw_finder_mark(draw, size * 0.365, size * 0.365, size * 0.20, HOT_PINK_2)
    draw_flower(icon, size * 0.63, size * 0.63, size * 0.075, ROSE_GOLD, core_color=ROSE_GOLD_LIGHT)

    icon.save(path)
    print(f"wrote {path}")


def make_splash_logo(path, mark_color, core_color, size=640):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_finder_mark(draw, size * 0.38, size * 0.38, size * 0.30, mark_color)
    draw_flower(img, size * 0.66, size * 0.66, size * 0.11, ROSE_GOLD, core_color=core_color)
    img.save(path)
    print(f"wrote {path}")


if __name__ == "__main__":
    import os

    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
    os.makedirs(out_dir, exist_ok=True)
    make_app_icon(os.path.join(out_dir, "app_icon.png"))
    make_splash_logo(os.path.join(out_dir, "splash_logo.png"), HOT_PINK_2, WHITE)
    make_splash_logo(os.path.join(out_dir, "splash_logo_dark.png"), ROSE_GOLD_LIGHT, CHARCOAL)
