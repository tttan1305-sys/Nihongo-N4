#!/usr/bin/env python3
"""Kiểm tra file bài học: JSON hợp lệ, mọi chữ Hán đều có furigana {漢字|かな}, id câu không trùng.

Dùng: python3 tools/check_lessons.py assets/lessons/*.json
"""
import json
import re
import sys

KANJI = re.compile(r"[一-鿿㐀-䶿々]")
RUBY = re.compile(r"\{([^|{}]+)\|([^|{}]+)\}")
# Các trường được phép có chữ Hán không furigana (chữ mẫu để tập viết).
SKIP_KEYS = {"char"}


def walk(node, path, errors, ids):
    if isinstance(node, dict):
        if "id" in node and isinstance(node["id"], str):
            if node["id"] in ids:
                errors.append(f"{path}: id trùng '{node['id']}'")
            ids.add(node["id"])
        for k, v in node.items():
            if k in SKIP_KEYS:
                continue
            walk(v, f"{path}.{k}", errors, ids)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk(v, f"{path}[{i}]", errors, ids)
    elif isinstance(node, str):
        for base, reading in RUBY.findall(node):
            if KANJI.search(reading):
                errors.append(f"{path}: phần đọc '{reading}' còn chữ Hán")
        rest = RUBY.sub("", node)
        bad = KANJI.findall(rest)
        if bad:
            errors.append(f"{path}: thiếu furigana cho {''.join(bad)} trong: {node}")


def check(file):
    with open(file, encoding="utf-8") as f:
        lesson = json.load(f)
    errors, ids = [], set()
    walk(lesson, lesson.get("id", file) if isinstance(lesson, dict) else file, errors, ids)
    if not isinstance(lesson, dict):
        return lesson, errors
    for ref in lesson.get("speaking", []) + [q["audioId"] for q in lesson.get("listening", [])]:
        if ref not in ids:
            errors.append(f"tham chiếu câu không tồn tại: {ref}")
    return lesson, errors


if __name__ == "__main__":
    total = 0
    for file in sys.argv[1:]:
        lesson, errors = check(file)
        total += len(errors)
        if isinstance(lesson, dict) and "grammar" in lesson and "vocab" in lesson:
            print(f"{file}: {len(lesson['grammar'])} ngữ pháp, {len(lesson['vocab'])} từ, {len(errors)} lỗi")
        else:
            print(f"{file}: {len(errors)} lỗi")
        for e in errors:
            print("  -", e)
    sys.exit(1 if total else 0)
