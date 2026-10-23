#!/usr/bin/env python3
"""Vẽ biểu tượng ứng dụng (chữ あ phát sáng, nhãn N4, hoa anh đào) cho Android, web và trang store.

Dùng: python3 tools/make_icons.py <thư mục dự án> <thư mục xuất ảnh store>
"""
import math, os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
R, OUT = sys.argv[1], sys.argv[2]
N = 1024
def gradient(n):
    im = Image.new('RGB', (n, n)); px = im.load()
    a = (18, 30, 78); b = (96, 58, 170)
    for y in range(n):
        for x in range(n):
            t = (x + y) / (2 * n); px[x, y] = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
    return im.convert('RGBA')
def art():
    bg = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    f = ImageFont.truetype('/usr/share/fonts/opentype/ipafont-gothic/ipag.ttf', 560)
    cx, cy = N / 2, N * 0.44
    layer = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    ImageDraw.Draw(layer).text((cx, cy), 'あ', font=f, fill=(110, 160, 255, 255), anchor='mm', stroke_width=12, stroke_fill=(110, 160, 255, 255))
    glow = layer.filter(ImageFilter.GaussianBlur(36)); bg.alpha_composite(glow); bg.alpha_composite(glow)
    d = ImageDraw.Draw(bg)
    d.text((cx, cy), 'あ', font=f, fill='white', anchor='mm', stroke_width=9, stroke_fill='white')
    fb = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 140)
    d.rounded_rectangle((N * 0.32, N * 0.77, N * 0.68, N * 0.91), radius=72, fill=(255, 169, 77, 255))
    d.text((N / 2, N * 0.84), 'N4', font=fb, fill=(26, 20, 60, 255), anchor='mm')
    def blossom(c, r):
        for i in range(5):
            an = i * 2 * math.pi / 5 - math.pi / 2; x = c[0] + math.cos(an) * r * 0.55; y = c[1] + math.sin(an) * r * 0.55
            d.ellipse((x - r * 0.5, y - r * 0.5, x + r * 0.5, y + r * 0.5), fill=(255, 183, 203, 255))
        d.ellipse((c[0] - r * 0.25, c[1] - r * 0.25, c[0] + r * 0.25, c[1] + r * 0.25), fill=(255, 111, 145, 255))
    blossom((N * 0.81, N * 0.18), 66); blossom((N * 0.90, N * 0.29), 40)
    return bg
fg = art(); grad = gradient(N)
full = grad.copy(); full.alpha_composite(fg)
full.convert('RGB').save(f'{OUT}/icon-1024.png')
for s in (512, 216):
    full.convert('RGB').resize((s, s), Image.LANCZOS).save(f'{OUT}/icon-{s}.png')
res = f'{R}/android/app/src/main/res'
dens = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
# Adaptive: foreground = art scaled into the 72dp-ish safe area of a 108dp canvas.
for name, k in dens.items():
    full.convert('RGB').resize((int(48 * k), int(48 * k)), Image.LANCZOS).save(f'{res}/mipmap-{name}/ic_launcher.png')
    size = int(108 * k)
    canvas = Image.new('RGBA', (N, N), (0, 0, 0, 0))
    small = fg.resize((int(N * 0.62), int(N * 0.62)), Image.LANCZOS)
    canvas.alpha_composite(small, ((N - small.width) // 2, (N - small.height) // 2))
    canvas.resize((size, size), Image.LANCZOS).save(f'{res}/mipmap-{name}/ic_launcher_foreground.png')
    grad.convert('RGB').resize((size, size), Image.LANCZOS).save(f'{res}/mipmap-{name}/ic_launcher_background.png')
os.makedirs(f'{res}/mipmap-anydpi-v26', exist_ok=True)
open(f'{res}/mipmap-anydpi-v26/ic_launcher.xml', 'w').write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''')
web = f'{R}/web'
for s in (192, 512):
    full.convert('RGB').resize((s, s), Image.LANCZOS).save(f'{web}/icons/Icon-{s}.png')
    # Maskable: art inside the 80% safe zone on the gradient.
    m = grad.copy(); sm = fg.resize((int(N * 0.78), int(N * 0.78)), Image.LANCZOS)
    m.alpha_composite(sm, ((N - sm.width) // 2, (N - sm.height) // 2))
    m.convert('RGB').resize((s, s), Image.LANCZOS).save(f'{web}/icons/Icon-maskable-{s}.png')
full.convert('RGB').resize((32, 32), Image.LANCZOS).save(f'{web}/favicon.png')
