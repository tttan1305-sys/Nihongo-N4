#!/usr/bin/env python3
"""Tạo assets/n5/kanji.json từ tools/n5_kanji_data.py."""
import json
import pathlib

from n5_kanji_data import KANJI

root = pathlib.Path(__file__).resolve().parent.parent
chars = [k[0] for k in KANJI]
assert len(chars) == len(set(chars)), "chữ Hán bị trùng"
items = []
for i, (char, han, meaning, on, kun, reading, strokes, radical, radical_name,
        mnemonic, ex_word, ex_vi) in enumerate(KANJI, 1):
    items.append({
        "id": f"k{i:03d}",
        "char": char,
        "hanViet": han,
        "meaningVi": meaning,
        "on": on,
        "kun": kun,
        "reading": reading,
        "strokes": strokes,
        "radical": radical,
        "radicalName": radical_name,
        "mnemonicVi": mnemonic,
        "example": {"id": f"k{i:03d}_e", "ja": ex_word, "vi": ex_vi},
    })
out = root / "assets/n5/kanji.json"
out.write_text(json.dumps({"id": "n5kanji", "kanji": items}, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print(f"{out}: {len(items)} chữ")
