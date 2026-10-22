#!/usr/bin/env python3
"""Gắn phần "Phân tích" (từng cụm, cách chia, lưu ý) vào câu ví dụ ngữ pháp.

Nội dung viết tay trong tools/analysis/*.txt, mỗi câu một khối:

    @g17-2-1
    毎日 | mỗi ngày. Từ chỉ tần suất, không cần trợ từ
    薬を | thuốc. を đánh dấu tân ngữ
    > 飲みます → 飲まない: nhóm I, み đổi thành ま rồi thêm ない
    ! "uống thuốc" dùng 飲む, không dùng 食べる

Dòng "ja | vi" là một cụm, dòng "> " là một bước chia, dòng "! " là lưu ý.
Chữ Hán viết trơn được tự thêm furigana theo cách đọc đã có trong dữ liệu;
chữ có nhiều cách đọc (như 来) thì phải tự viết {来|く}る.

Dùng: python3 tools/apply_analysis.py
"""
import glob
import json
import re
import sys

ROOT = __file__.rsplit("/tools/", 1)[0]
TARGETS = [f"{ROOT}/assets/lessons/26.json", f"{ROOT}/assets/n5/grammar.json"]
SOURCES = sorted(glob.glob(f"{ROOT}/tools/analysis/*.txt"))
DATA = glob.glob(f"{ROOT}/assets/**/*.json", recursive=True)

KANJI = r"一-鿿㐀-䶿々"
RUBY = re.compile(r"\{([^|{}]+)\|([^|{}]+)\}")

# Cách đọc thêm cho chữ dùng trong phần giải thích mà dữ liệu chưa có.
EXTRA = {
    "形": "けい",
    "普通形": "ふつうけい",
    "辞書形": "じしょけい",
    "疑問詞": "ぎもんし",
    "可能形": "かのうけい",
}


def readings():
    found = {}
    for file in DATA:
        text = open(file, encoding="utf-8").read()
        for base, reading in RUBY.findall(text):
            found.setdefault(base, set()).add(reading)
    for base, reading in EXTRA.items():
        found[base] = {reading}
    return found


def add_ruby(text, known, errors, where):
    """Thêm {漢字|かな} cho các đoạn chữ Hán chưa có furigana."""
    out, pos = [], 0
    for m in RUBY.finditer(text):
        out.append(_plain(text[pos:m.start()], known, errors, where))
        out.append(m.group(0))
        pos = m.end()
    out.append(_plain(text[pos:], known, errors, where))
    return "".join(out)


def _plain(text, known, errors, where):
    def repl(m):
        run, res, i = m.group(0), [], 0
        while i < len(run):
            for j in range(len(run), i, -1):
                base = run[i:j]
                if base in known and len(known[base]) == 1:
                    res.append(f"{{{base}|{next(iter(known[base]))}}}")
                    i = j
                    break
            else:
                ch = run[i]
                hint = "/".join(sorted(known.get(ch, []))) or "chưa có"
                errors.append(f"{where}: cần viết furigana cho {ch} ({hint}) trong: {text}")
                res.append(ch)
                i += 1
        return "".join(res)

    return re.sub(f"[{KANJI}]+", repl, text)


def parse(known, errors):
    result = {}
    for file in SOURCES:
        current = None
        for n, line in enumerate(open(file, encoding="utf-8"), 1):
            line = line.rstrip("\n")
            where = f"{file.rsplit('/', 1)[1]}:{n}"
            if not line.strip() or line.startswith("#"):
                continue
            if line.startswith("@"):
                current = {"parts": [], "steps": []}
                result[line[1:].strip()] = current
            elif current is None:
                errors.append(f"{where}: dòng nằm ngoài khối @id")
            elif line.startswith("> "):
                current["steps"].append(add_ruby(line[2:].strip(), known, errors, where))
            elif line.startswith("! "):
                current["note"] = add_ruby(line[2:].strip(), known, errors, where)
            elif " | " in line:
                ja, vi = line.split(" | ", 1)
                current["parts"].append(
                    [add_ruby(ja.strip(), known, errors, where),
                     add_ruby(vi.strip(), known, errors, where)]
                )
            else:
                errors.append(f"{where}: không hiểu dòng: {line}")
    return result


def object_end(text, start):
    """Vị trí dấu } đóng object chứa vị trí [start] (bỏ qua chuỗi)."""
    depth, i, in_str = 0, start, False
    while i < len(text):
        c = text[i]
        if in_str:
            if c == "\\":
                i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
        elif c in "{[":
            depth += 1
        elif c in "}]":
            if depth == 0:
                return i
            depth -= 1
        i += 1
    raise ValueError("không tìm thấy dấu đóng")


def attach(text, ids, analyses):
    """Chèn (hoặc thay) khóa "analysis" ở cuối object câu ví dụ, giữ nguyên
    cách trình bày file."""
    for eid in ids:
        key = f'"id": "{eid}"'
        start = text.index(key) + len(key)
        end = object_end(text, start)
        body = text[start:end]
        old = body.find(', "analysis": ')
        tail_ws = len(body) - len(body.rstrip())
        keep = body[:old] if old >= 0 else body.rstrip()
        value = json.dumps(analyses[eid], ensure_ascii=False)
        text = text[:start] + keep + f', "analysis": {value}' + body[len(body) - tail_ws:] + text[end:]
    return text


def examples(node):
    if isinstance(node, dict):
        for k, v in node.items():
            if k == "examples":
                yield from v
            else:
                yield from examples(v)
    elif isinstance(node, list):
        for v in node:
            yield from examples(v)


def main():
    errors = []
    analyses = parse(readings(), errors)
    used = set()
    for file in TARGETS:
        text = open(file, encoding="utf-8").read()
        data = json.loads(text)
        ids = [e["id"] for e in examples(data.get("grammar", data))]
        missing = [i for i in ids if i not in analyses]
        if missing:
            errors.append(f"{file}: chưa có phân tích cho {', '.join(missing)}")
        done = [i for i in ids if i in analyses]
        used.update(done)
        clean = {i: {k: v for k, v in analyses[i].items() if v} for i in done}
        text = attach(text, done, clean)
        json.loads(text)
        with open(file, "w", encoding="utf-8") as f:
            f.write(text)
    for extra in sorted(set(analyses) - used):
        errors.append(f"không có câu ví dụ nào mang id {extra}")
    for e in errors:
        print("-", e)
    print(f"Đã gắn {len(used)} phân tích, {len(errors)} lỗi")
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
