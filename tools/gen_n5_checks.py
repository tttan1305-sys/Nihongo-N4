#!/usr/bin/env python3
"""Sinh assets/n5/checks.json từ tools/n5_checks_data.py và kiểm tra nội dung.

Kiểm tra: mỗi thể (forms.json) và mỗi mẫu ngữ pháp (grammar.json) có ít nhất
một câu; mỗi câu có 4 đáp án khác nhau; mọi chữ Hán đều có furigana. Chữ Hán
trần trong phần giải thích được tự thêm furigana từ các từ {漢字|かな} đã có
trong câu đó và trong dữ liệu N5; nếu cách đọc không chắc chắn thì báo lỗi.

Dùng: python3 tools/gen_n5_checks.py
"""
import glob
import json
import os
import random
import re
import sys

ROOT = os.path.join(os.path.dirname(__file__), "..")
sys.path.insert(0, os.path.dirname(__file__))
from n5_checks_data import SETS  # noqa: E402

KANJI = re.compile(r"[一-鿿㐀-䶿々]")
KANJI_RUN = re.compile(r"[一-鿿㐀-䶿々]+")
TOKEN = re.compile(r"\{([^{}|]+)\|([^{}|]+)\}")
BLANK = "（　）"
# Gợi ý tiếng Việt ở đầu câu hỏi, ví dụ （Nói với bạn）.
HINT = re.compile(r"^（[^）]*[A-Za-z0-9À-ỹ][^）]*）")


# Đáp án dính liền chữ đứng trước (trợ từ, です…); các đáp án khác cách bằng 　
# để câu đúng (fullJa) theo lối viết cách chữ của cả ứng dụng.
PARTICLES = {"は", "を", "へ", "に", "で", "が", "も", "か", "と", "の", "や", "から", "まで", "より",
             "だけ", "へも", "でも"}
ATTACH = ("です", "だ", "じゃ", "でした", "{分|")
SINGLE = ("か", "よ", "ね", "を", "の", "に", "が", "は", "と", "で", "も")


def _glued(after, particle):
    """Phần sau chỗ trống có viết liền với đáp án không."""
    if not after or after[0] in "　。、？」…":
        return True
    if after.startswith(("です", "から、")):
        return True
    # Một trợ từ đứng ngay sau (…を　, …か。); còn とき, かかります… là từ mới.
    return not particle and after[0] in SINGLE and (len(after) == 1 or after[1] in "　。、？")


def fill_blank(body, answer):
    before, after = body.split(BLANK)
    particle = answer in PARTICLES
    attach = particle or answer.startswith(ATTACH) or (answer.startswith("し") and before.endswith("}"))
    if before and not attach and before[-1] not in "　（「：、。":
        before += "　"
    if not _glued(after, particle):
        after = "　" + after
    return before + answer + after


def tokens_in(text):
    return [(k, r) for k, r in TOKEN.findall(text) if KANJI_RUN.fullmatch(k)]


def build_dictionary():
    readings = {}
    files = glob.glob(os.path.join(ROOT, "assets", "n5", "*.json")) + glob.glob(
        os.path.join(ROOT, "assets", "lessons", "*.json"))
    texts = [open(f, encoding="utf-8").read() for f in files]
    texts.append(json.dumps(SETS, ensure_ascii=False))
    for text in texts:
        for k, r in tokens_in(text):
            readings.setdefault(k, set()).add(r)
    return readings


def furigana(text, local, global_dict, where):
    """Thêm furigana cho chữ Hán trần. Trả về (text, lỗi)."""
    errors = []
    out = []
    pos = 0
    for m in TOKEN.finditer(text):
        out.append(_fill(text[pos:m.start()], local, global_dict, where, errors))
        out.append(m.group(0))
        pos = m.end()
    out.append(_fill(text[pos:], local, global_dict, where, errors))
    return "".join(out), errors


def _reading(word, local, global_dict):
    if word in local:
        return local[word]
    rs = global_dict.get(word)
    if rs and len(rs) == 1:
        return next(iter(rs))
    return None


def _fill(plain, local, global_dict, where, errors):
    def repl(m):
        run = m.group(0)
        parts = []
        i = 0
        while i < len(run):
            for j in range(len(run), i, -1):
                r = _reading(run[i:j], local, global_dict)
                if r:
                    parts.append(f"{{{run[i:j]}|{r}}}")
                    i = j
                    break
            else:
                errors.append(f"{where}: không rõ cách đọc của 「{run}」 trong: {plain.strip()[:60]}")
                return run
        return "".join(parts)
    return KANJI_RUN.sub(repl, plain)


def bare_kanji(text):
    return KANJI.search(TOKEN.sub("", text)) is not None


def main():
    forms = json.load(open(os.path.join(ROOT, "assets", "n5", "forms.json"), encoding="utf-8"))
    grammar = json.load(open(os.path.join(ROOT, "assets", "n5", "grammar.json"), encoding="utf-8"))
    form_ids = [f["id"] for f in forms["forms"]] + [forms["plain"]["id"]]
    grammar_ids = [p["id"] for lesson in grammar["lessons"] for p in lesson["points"]]
    titles = {f["id"]: f.get("name", f["id"]) for f in forms["forms"]}
    titles[forms["plain"]["id"]] = forms["plain"]["name"]
    for lesson in grammar["lessons"]:
        for p in lesson["points"]:
            titles[p["id"]] = p["pattern"]

    global_dict = build_dictionary()
    errors = []
    covered = set()
    sets = []
    for s in SETS:
        questions = []
        for n, item in enumerate(s["questions"], 1):
            covers, prompt, options, meaning, explain, wrong, tip = item
            qid = f"{s['id']}-{n:02d}"
            covers = [covers] if isinstance(covers, str) else list(covers)
            for c in covers:
                if c not in titles:
                    errors.append(f"{qid}: mã không có trong dữ liệu N5: {c}")
            covered.update(covers)
            if prompt.count(BLANK) != 1:
                errors.append(f"{qid}: câu hỏi phải có đúng một chỗ trống （　）")
            if len(options) != 4 or len(set(options)) != 4:
                errors.append(f"{qid}: cần 4 đáp án khác nhau: {options}")
            if len(wrong) != 3:
                errors.append(f"{qid}: cần 3 lý do sai, có {len(wrong)}")
            body = HINT.sub("", prompt)
            full_ja = fill_blank(body, options[0])
            for label, text in [("câu hỏi", prompt), *[(f"đáp án {i}", o) for i, o in enumerate(options)]]:
                if bare_kanji(HINT.sub("", text)):
                    errors.append(f"{qid}: chữ Hán thiếu furigana trong {label}: {text}")
                if text.count("{") != text.count("}"):
                    errors.append(f"{qid}: ngoặc {{}} không cân trong {label}")
            local = {}
            for k, r in tokens_in(prompt + "".join(options)):
                local.setdefault(k, r)
            fixed = []
            for label, text in [("nghĩa", meaning), ("phân tích", explain), ("mẹo", tip),
                                *[(f"lý do sai {i + 1}", w) for i, w in enumerate(wrong)]]:
                text, errs = furigana(text, local, global_dict, f"{qid} {label}")
                errors.extend(errs)
                fixed.append(text)
            meaning, explain, tip, *wrong = fixed

            # Xáo đáp án (cố định theo mã câu); lý do sai đi theo đáp án của nó.
            pairs = [(options[0], "")] + list(zip(options[1:], wrong))
            random.Random(qid).shuffle(pairs)
            question = {
                "id": qid,
                "covers": covers,
                "coversVi": [titles.get(c, c) for c in covers],
                "prompt": prompt,
                "options": [p[0] for p in pairs],
                "answer": [p[0] for p in pairs].index(options[0]),
                "fullJa": full_ja,
                "meaningVi": meaning,
                "explainVi": explain,
                "wrongVi": [p[1] for p in pairs],
                "tipVi": tip,
            }
            questions.append(question)
        sets.append({"id": s["id"], "titleVi": s["titleVi"], "subtitleVi": s["subtitleVi"],
                     "questions": questions})

    missing = [i for i in form_ids + grammar_ids if i not in covered]
    if missing:
        errors.append("Chưa có câu hỏi cho: " + ", ".join(missing))
    if errors:
        print("\n".join(errors))
        sys.exit(f"{len(errors)} lỗi")

    out = os.path.join(ROOT, "assets", "n5", "checks.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"sets": sets}, f, ensure_ascii=False, indent=1)
        f.write("\n")
    all_q = [q for s in sets for q in s["questions"]]
    counts = [sum(1 for q in all_q if q["answer"] == i) for i in range(4)]
    print(f"{out}: {len(sets)} bài, {len(all_q)} câu, phủ {len(form_ids)} thể + "
          f"{len(grammar_ids)} mẫu ngữ pháp, đáp án A/B/C/D: {counts}")


if __name__ == "__main__":
    main()
