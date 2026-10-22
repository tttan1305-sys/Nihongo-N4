#!/usr/bin/env python3
"""Tạo assets/n5/kanji.json từ tools/n5_kanji_data.py."""
import json
import pathlib

from n5_kanji_data import KANJI

# Tên bộ thủ theo kiểu "Miên (mái nhà)" như bảng 214 bộ thủ.
RADICALS = {
    "一": "Nhất (số một)", "丨": "Cổn (nét sổ)", "乙": "Ất (can thứ hai)",
    "二": "Nhị (số hai)", "人": "Nhân (người)", "亻": "Nhân đứng (người)",
    "儿": "Nhân đi (người đi)", "入": "Nhập (vào)", "八": "Bát (số tám)",
    "冂": "Quynh (biên giới)", "凵": "Khảm (há miệng)", "刀": "Đao (con dao)",
    "刂": "Đao đứng (con dao)", "匕": "Chủy (cái thìa)", "十": "Thập (số mười)",
    "又": "Hựu (lại nữa)", "口": "Khẩu (cái miệng)", "囗": "Vi (vây quanh)",
    "土": "Thổ (đất)", "夕": "Tịch (chiều tối)", "大": "Đại (to lớn)",
    "女": "Nữ (phụ nữ)", "子": "Tử (con)", "宀": "Miên (mái nhà)",
    "小": "Tiểu (nhỏ)", "山": "Sơn (núi)", "川": "Xuyên (sông)",
    "工": "Công (người thợ)", "干": "Can (thiên can)", "广": "Nghiễm (hiên nhà)",
    "彳": "Xích (bước chân trái)", "手": "Thủ (tay)", "斤": "Cân (cái rìu)",
    "日": "Nhật (mặt trời)", "曰": "Viết (nói rằng)", "月": "Nguyệt (mặt trăng)",
    "木": "Mộc (cây)", "毋": "Vô (chớ, đừng)", "气": "Khí (hơi nước)",
    "水": "Thủy (nước)", "火": "Hỏa (lửa)", "父": "Phụ (cha)",
    "生": "Sinh (sống)", "田": "Điền (ruộng)", "白": "Bạch (màu trắng)",
    "目": "Mục (mắt)", "礻": "Thị (thần đất)", "立": "Lập (đứng)",
    "耳": "Nhĩ (tai)", "艹": "Thảo (cỏ)", "行": "Hành (đi)",
    "襾": "Á (che đậy)", "見": "Kiến (nhìn)", "言": "Ngôn (nói)",
    "貝": "Bối (vỏ sò)", "足": "Túc (chân)", "車": "Xa (xe)",
    "辶": "Sước (bước đi)", "金": "Kim (kim loại)", "長": "Trường (dài)",
    "雨": "Vũ (mưa)", "食": "Thực (ăn)", "飠": "Thực (ăn)",
    "馬": "Mã (ngựa)", "高": "Cao (cao)",
}

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
        "radicalName": RADICALS[radical],
        "radicalJa": radical_name,
        "mnemonicVi": mnemonic,
        "example": {"id": f"k{i:03d}_e", "ja": ex_word, "vi": ex_vi},
    })
out = root / "assets/n5/kanji.json"
out.write_text(json.dumps({"id": "n5kanji", "kanji": items}, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print(f"{out}: {len(items)} chữ")
