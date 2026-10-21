#!/usr/bin/env python3
"""Sinh assets/n5/forms.json: bảng chia các thể N5 (Minna bài 1-25).

Chia theo quy tắc trên phần kana cuối từ, nên không phải gõ tay từng ô.
Dùng: python3 tools/gen_n5_forms.py
"""
import json
import os

# (id, phần có furigana, đuôi kana, nhóm, nghĩa)
VERBS = [
    ("kaku", "{書|か}", "く", 1, "viết"),
    ("iku", "{行|い}", "く", 1, "đi"),
    ("oyogu", "{泳|およ}", "ぐ", 1, "bơi"),
    ("hanasu", "{話|はな}", "す", 1, "nói chuyện"),
    ("matsu", "{待|ま}", "つ", 1, "chờ"),
    ("shinu", "{死|し}", "ぬ", 1, "chết"),
    ("asobu", "{遊|あそ}", "ぶ", 1, "chơi"),
    ("nomu", "{飲|の}", "む", 1, "uống"),
    ("kaeru", "{帰|かえ}", "る", 1, "về"),
    ("kau", "{買|か}", "う", 1, "mua"),
    ("taberu", "{食|た}", "べる", 2, "ăn"),
    ("miru", "{見|み}", "る", 2, "xem, nhìn"),
    ("okiru", "{起|お}", "きる", 2, "thức dậy"),
    ("neru", "{寝|ね}", "る", 2, "ngủ"),
    ("suru", "", "する", 3, "làm"),
    ("benkyousuru", "{勉強|べんきょう}", "する", 3, "học"),
    ("kuru", None, None, 3, "đến"),
]

I_ROW = {"う": "い", "く": "き", "ぐ": "ぎ", "す": "し", "つ": "ち", "ぬ": "に", "ぶ": "び", "む": "み", "る": "り"}
A_ROW = {"う": "わ", "く": "か", "ぐ": "が", "す": "さ", "つ": "た", "ぬ": "な", "ぶ": "ば", "む": "ま", "る": "ら"}
TE = {"う": "って", "つ": "って", "る": "って", "む": "んで", "ぶ": "んで", "ぬ": "んで", "く": "いて", "ぐ": "いで", "す": "して"}


def conjugate(vid, head, tail, group):
    if vid == "kuru":
        k = lambda r, rest: "{来|" + r + "}" + rest
        return {
            "dict": k("く", "る"), "masu": k("き", "ます"), "masen": k("き", "ません"),
            "mashita": k("き", "ました"), "nai": k("こ", "ない"), "nakatta": k("こ", "なかった"),
            "te": k("き", "て"), "ta": k("き", "た"), "tara": k("き", "たら"), "temo": k("き", "ても"),
        }
    if group == 3:
        stem_i, stem_a, te, dic = "し", "し", "して", "する"
    elif group == 2:
        stem = tail[:-1]
        stem_i = stem_a = stem
        te, dic = stem + "て", tail
    else:
        last = tail[-1]
        base = tail[:-1]
        stem_i, stem_a = base + I_ROW[last], base + A_ROW[last]
        te = base + ("って" if vid == "iku" else TE[last])
        dic = tail
    ta = te[:-1] + ("だ" if te.endswith("で") else "た")
    f = {
        "dict": dic, "masu": stem_i + "ます", "masen": stem_i + "ません",
        "mashita": stem_i + "ました", "nai": stem_a + "ない", "nakatta": stem_a + "なかった",
        "te": te, "ta": ta, "tara": ta + "ら", "temo": te + "も",
    }
    return {k: head + v for k, v in f.items()}


FORMS = [
    {
        "id": "masu", "name": "Thể ます", "nameJa": "ます{形|けい}", "lesson": "Bài 4–5",
        "usesVi": "Cách nói lịch sự, dùng với người không thân, ở chỗ làm. Phủ định ～ません, quá khứ ～ました, quá khứ phủ định ～ませんでした.",
        "rules": [
            {"group": "Nhóm I", "ruleVi": "đổi đuôi hàng う sang hàng い + ます", "example": "{書|か}く → {書|か}きます"},
            {"group": "Nhóm II", "ruleVi": "bỏ る + ます", "example": "{食|た}べる → {食|た}べます"},
            {"group": "Nhóm III", "ruleVi": "する → します, {来|く}る → {来|き}ます", "example": "{勉強|べんきょう}する → {勉強|べんきょう}します"},
        ],
        "examples": [
            {"id": "f-masu-1", "ja": "{毎朝|まいあさ}　コーヒーを　{飲|の}みます。", "vi": "Mỗi sáng tôi uống cà phê."},
            {"id": "f-masu-2", "ja": "きのう　{会社|かいしゃ}へ　{行|い}きませんでした。", "vi": "Hôm qua tôi đã không đi làm."},
        ],
        "table": ["masu", "masen", "mashita"],
    },
    {
        "id": "te", "name": "Thể て", "nameJa": "て{形|けい}", "lesson": "Bài 14",
        "usesVi": "Nhờ vả (～てください), đang làm (～ています), nối hành động (～て、～), xin phép (～てもいいです), cấm (～てはいけません).",
        "rules": [
            {"group": "Nhóm I", "ruleVi": "う・つ・る → って", "example": "{買|か}う → {買|か}って、{待|ま}つ → {待|ま}って"},
            {"group": "Nhóm I", "ruleVi": "む・ぶ・ぬ → んで", "example": "{飲|の}む → {飲|の}んで、{遊|あそ}ぶ → {遊|あそ}んで"},
            {"group": "Nhóm I", "ruleVi": "く → いて, ぐ → いで (ngoại lệ: {行|い}く → {行|い}って)", "example": "{書|か}く → {書|か}いて、{泳|およ}ぐ → {泳|およ}いで"},
            {"group": "Nhóm I", "ruleVi": "す → して", "example": "{話|はな}す → {話|はな}して"},
            {"group": "Nhóm II", "ruleVi": "bỏ る + て", "example": "{見|み}る → {見|み}て"},
            {"group": "Nhóm III", "ruleVi": "する → して, {来|く}る → {来|き}て", "example": "{来|く}る → {来|き}て"},
        ],
        "examples": [
            {"id": "f-te-1", "ja": "すみません、ちょっと　{待|ま}って　ください。", "vi": "Xin lỗi, vui lòng chờ một chút."},
            {"id": "f-te-2", "ja": "{今|いま}　{会議|かいぎ}の　{資料|しりょう}を　{読|よ}んで　います。", "vi": "Bây giờ tôi đang đọc tài liệu họp."},
        ],
        "table": ["te"],
    },
    {
        "id": "nai", "name": "Thể ない", "nameJa": "ない{形|けい}", "lesson": "Bài 17",
        "usesVi": "Phủ định thân mật. Dùng trong ～ないでください (xin đừng), ～なければなりません (phải), ～なくてもいいです (không cần).",
        "rules": [
            {"group": "Nhóm I", "ruleVi": "đổi đuôi hàng う sang hàng あ + ない (う → わない)", "example": "{書|か}く → {書|か}かない、{買|か}う → {買|か}わない"},
            {"group": "Nhóm II", "ruleVi": "bỏ る + ない", "example": "{寝|ね}る → {寝|ね}ない"},
            {"group": "Nhóm III", "ruleVi": "する → しない, {来|く}る → {来|こ}ない", "example": "{来|く}る → {来|こ}ない"},
        ],
        "examples": [
            {"id": "f-nai-1", "ja": "ここで　たばこを　{吸|す}わないで　ください。", "vi": "Xin đừng hút thuốc ở đây."},
            {"id": "f-nai-2", "ja": "{明日|あした}までに　レポートを　{出|だ}さなければ　なりません。", "vi": "Tôi phải nộp báo cáo trước ngày mai."},
        ],
        "table": ["nai", "nakatta"],
    },
    {
        "id": "dict", "name": "Thể từ điển", "nameJa": "{辞書形|じしょけい}", "lesson": "Bài 18",
        "usesVi": "Dạng gốc của động từ, tra trong từ điển. Dùng trong ～ことができます (có thể), {趣味|しゅみ}は～ことです (sở thích), ～まえに (trước khi).",
        "rules": [
            {"group": "Nhóm I", "ruleVi": "từ thể ます: đổi hàng い sang hàng う, bỏ ます", "example": "{書|か}きます → {書|か}く"},
            {"group": "Nhóm II", "ruleVi": "bỏ ます + る", "example": "{食|た}べます → {食|た}べる"},
            {"group": "Nhóm III", "ruleVi": "します → する, {来|き}ます → {来|く}る", "example": "{来|き}ます → {来|く}る"},
        ],
        "examples": [
            {"id": "f-dict-1", "ja": "{私|わたし}は　{日本語|にほんご}を　{話|はな}す　ことが　できます。", "vi": "Tôi có thể nói tiếng Nhật."},
            {"id": "f-dict-2", "ja": "{寝|ね}る　まえに、{本|ほん}を　{読|よ}みます。", "vi": "Trước khi ngủ tôi đọc sách."},
        ],
        "table": ["dict"],
    },
    {
        "id": "ta", "name": "Thể た", "nameJa": "た{形|けい}", "lesson": "Bài 19",
        "usesVi": "Quá khứ thân mật. Dùng trong ～たことがあります (đã từng), ～たり～たりします (nào là... nào là...).",
        "rules": [
            {"group": "Tất cả", "ruleVi": "chia giống thể て, đổi て → た, で → だ", "example": "{飲|の}んで → {飲|の}んだ、{行|い}って → {行|い}った"},
        ],
        "examples": [
            {"id": "f-ta-1", "ja": "{富士山|ふじさん}に　{登|のぼ}った　ことが　あります。", "vi": "Tôi đã từng leo núi Phú Sĩ."},
            {"id": "f-ta-2", "ja": "{日曜日|にちようび}は　{掃除|そうじ}したり、{買|か}い{物|もの}したり　します。", "vi": "Chủ nhật tôi nào là dọn dẹp, nào là đi mua sắm."},
        ],
        "table": ["ta"],
    },
    {
        "id": "tara", "name": "Thể たら, ても", "nameJa": "～たら・～ても", "lesson": "Bài 25",
        "usesVi": "～たら: nếu, khi (điều kiện). ～ても: dù, cho dù.",
        "rules": [
            {"group": "Tất cả", "ruleVi": "～たら = thể た + ら", "example": "{雨|あめ}が　{降|ふ}ったら → nếu trời mưa"},
            {"group": "Tất cả", "ruleVi": "～ても = thể て + も", "example": "{高|たか}くても → dù đắt"},
        ],
        "examples": [
            {"id": "f-tara-1", "ja": "{駅|えき}に　{着|つ}いたら、{電話|でんわ}して　ください。", "vi": "Khi đến ga thì gọi điện cho tôi nhé."},
            {"id": "f-tara-2", "ja": "{雨|あめ}が　{降|ふ}っても、{会社|かいしゃ}へ　{行|い}きます。", "vi": "Dù trời mưa tôi vẫn đi làm."},
        ],
        "table": ["tara", "temo"],
    },
]

FORM_LABELS = {
    "dict": "Từ điển", "masu": "ます", "masen": "ません", "mashita": "ました",
    "nai": "ない", "nakatta": "なかった", "te": "て", "ta": "た", "tara": "たら", "temo": "ても",
}

# Thể thông thường (普通形, bài 20) của tính từ và danh từ.
PLAIN = {
    "id": "plain", "name": "Thể thông thường", "nameJa": "{普通形|ふつうけい}", "lesson": "Bài 8, 12, 20",
    "usesVi": "Nói chuyện thân mật với bạn bè, gia đình, và đứng trước các mẫu như ～と{思|おも}います, ～と{言|い}いました (bài 21).",
    "columns": ["Hiện tại", "Phủ định", "Quá khứ", "Quá khứ phủ định"],
    "rows": [
        {"label": "Động từ", "cells": ["{書|か}く", "{書|か}かない", "{書|か}いた", "{書|か}かなかった"]},
        {"label": "Tính từ い", "cells": ["{高|たか}い", "{高|たか}くない", "{高|たか}かった", "{高|たか}くなかった"]},
        {"label": "いい (đặc biệt)", "cells": ["いい", "よくない", "よかった", "よくなかった"]},
        {"label": "Tính từ な", "cells": ["{静|しず}かだ", "{静|しず}かじゃない", "{静|しず}かだった", "{静|しず}かじゃなかった"]},
        {"label": "Danh từ", "cells": ["{雨|あめ}だ", "{雨|あめ}じゃない", "{雨|あめ}だった", "{雨|あめ}じゃなかった"]},
    ],
    "examples": [
        {"id": "f-plain-1", "ja": "あした　{雨|あめ}が　{降|ふ}ると　{思|おも}う。", "vi": "Tôi nghĩ mai trời sẽ mưa."},
        {"id": "f-plain-2", "ja": "きのうの　テストは　{難|むずか}しかった。", "vi": "Bài kiểm tra hôm qua khó."},
    ],
}

GROUPS = [
    {"name": "Nhóm I", "descVi": "Đuôi thể ます thuộc hàng い: {書|か}きます、{飲|の}みます、{帰|かえ}ります. Chú ý: {帰|かえ}る、{入|はい}る、{走|はし}る、{知|し}る、{切|き}る là nhóm I dù trông giống nhóm II."},
    {"name": "Nhóm II", "descVi": "Đuôi thể ます thuộc hàng え, và một số từ hàng い: {食|た}べます、{寝|ね}ます、{見|み}ます、{起|お}きます."},
    {"name": "Nhóm III", "descVi": "Chỉ có する (và danh từ + する như {勉強|べんきょう}する) và {来|く}る."},
]


def main():
    verbs = []
    for vid, head, tail, group, meaning in VERBS:
        forms = conjugate(vid, head, tail, group)
        verbs.append({"id": vid, "group": group, "meaningVi": meaning, "forms": forms})
    data = {"groups": GROUPS, "formLabels": FORM_LABELS, "forms": FORMS, "verbs": verbs, "plain": PLAIN}
    out = os.path.join(os.path.dirname(__file__), "..", "assets", "n5", "forms.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print(f"{out}: {len(verbs)} động từ, {len(FORMS)} thể")


if __name__ == "__main__":
    main()
