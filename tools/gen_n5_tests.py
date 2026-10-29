#!/usr/bin/env python3
"""Sinh assets/n5/tests.json từ tools/n5_tests_data.py và kiểm tra cấu trúc đề.

Dùng: python3 tools/gen_n5_tests.py
"""
import json
import os
import random
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from n5_tests_data import SECTION, TESTS  # noqa: E402
from n5_tests_translations import PASSAGES, QUESTIONS  # noqa: E402


KANJI = re.compile(r"[一-鿿㐀-䶿々亻罒]+")
TOKEN = re.compile(r"(\{[^{}]*\}|【[^】]*】)")


def mark_kanji(text):
    """Giải thích bàn về mặt chữ (vd. "車 và 東"): đóng 【】 quanh chữ Hán trần."""
    parts = TOKEN.split(text)
    return "".join(p if TOKEN.fullmatch(p) else KANJI.sub(lambda m: f"【{m.group(0)}】", p) for p in parts)


def main():
    tests = []
    for t, test in enumerate(TESTS, 1):
        passages = [{"id": f"t{t}-p{i}", "ja": p, "vi": PASSAGES[f"t{t}-p{i}"]}
                    for i, p in enumerate(test["passages"], 1)]
        questions = []
        for q, item in enumerate(test["questions"], 1):
            kind, prompt, options, answer, explanation = item[:5]
            assert kind in SECTION, kind
            assert len(options) == 4 and len(set(options)) == 4, (t, q, options)
            assert 0 <= answer < 4, (t, q)
            # Xáo đáp án (cố định theo mã câu) để đáp án đúng không dồn về A.
            correct = options[answer]
            options = list(options)
            random.Random(f"t{t}-q{q}").shuffle(options)
            answer = options.index(correct)
            question = {
                "id": f"t{t}-q{q:02d}", "type": kind, "section": SECTION[kind],
                "prompt": prompt, "options": options, "answer": answer,
                "explanationVi": mark_kanji(explanation),
                # Dịch nghĩa câu (đã điền đáp án), hiện sau phần giải thích.
                "translationVi": QUESTIONS[f"t{t}-q{q:02d}"],
            }
            if len(item) > 5:
                question["passage"] = passages[item[5]]["id"]
            questions.append(question)
        assert len(questions) == 20, (t, len(questions))
        tests.append({"id": f"test{t}", "titleVi": test["titleVi"], "passages": passages, "questions": questions})
    out = os.path.join(os.path.dirname(__file__), "..", "assets", "n5", "tests.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"tests": tests}, f, ensure_ascii=False, indent=1)
        f.write("\n")
    all_q = [q for t in tests for q in t["questions"]]
    counts = [sum(1 for q in all_q if q["answer"] == i) for i in range(4)]
    print(f"{out}: {len(tests)} đề, {sum(len(t['questions']) for t in tests)} câu, đáp án A/B/C/D: {counts}")


if __name__ == "__main__":
    main()
