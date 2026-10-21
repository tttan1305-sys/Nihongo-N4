#!/usr/bin/env python3
"""Sinh assets/n5/vocab.json từ tools/n5_vocab_data.py.

Dùng: python3 tools/gen_n5_vocab.py
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from n5_vocab_data import TOPICS  # noqa: E402


def main():
    topics, n = [], 0
    for i, (title, words) in enumerate(TOPICS, 1):
        items = []
        for word, kana, meaning, ja, vi in words:
            n += 1
            items.append({
                "id": f"n5v{n:03d}", "word": word, "kana": kana, "meaningVi": meaning,
                "example": {"id": f"n5e{n:03d}", "ja": ja, "vi": vi},
            })
        topics.append({"id": f"t{i:02d}", "titleVi": title, "words": items})
    out = os.path.join(os.path.dirname(__file__), "..", "assets", "n5", "vocab.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"topics": topics}, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print(f"{out}: {len(topics)} chủ đề, {n} từ")


if __name__ == "__main__":
    main()
