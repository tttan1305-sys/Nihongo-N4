"""Âm Hán Việt của chữ Hán, để ghi cột "Hán Việt" cho từ vựng
(giống cách trình bày của sổ tay từ vựng N5: 会社員 → Hội Xã Viên)."""
import re

HV = dict(x.split(":") for x in """
私:Tư 人:Nhân 男:Nam 女:Nữ 子:Tử 友:Hữu 達:Đạt 家:Gia 族:Tộc 父:Phụ 母:Mẫu
兄:Huynh 姉:Tỷ 弟:Đệ 妹:Muội 主:Chủ 内:Nội 名:Danh 前:Tiền 国:Quốc 皆:Giai
先:Tiên 生:Sinh 学:Học 会:Hội 社:Xã 員:Viên 医:Y 者:Giả 仕:Sĩ 事:Sự 議:Nghị
校:Hiệu 大:Đại 授:Thụ 業:Nghiệp 宿:Túc 題:Đề 試:Thí 験:Nghiệm 質:Chất 問:Vấn
言:Ngôn 葉:Diệp 漢:Hán 字:Tự 辞:Từ 書:Thư 本:Bản 刺:Thích 資:Tư 料:Liệu 休:Hưu
部:Bộ 屋:Ốc 駅:Dịch 銀:Ngân 行:Hành 郵:Bưu 便:Tiện 局:Cục 病:Bệnh 院:Viện 図:Đồ
館:Quán 公:Công 園:Viên 店:Điếm 食:Thực 堂:Đường 町:Đinh 道:Đạo 空:Không 港:Cảng
受:Thụ 付:Phó 務:Vụ 所:Sở 室:Thất 外:Ngoại 中:Trung 上:Thượng 下:Hạ 後:Hậu 隣:Lân
近:Cận 今:Kim 日:Nhật 明:Minh 昨:Tạc 毎:Mỗi 朝:Triều 昼:Trú 晩:Vãn 夜:Dạ 午:Ngọ
週:Chu 末:Mạt 来:Lai 年:Niên 去:Khứ 時:Thời 間:Gian 曜:Diệu 月:Nguyệt 誕:Đản
春:Xuân 夏:Hạ 冬:Đông 理:Lý 肉:Nhục 魚:Ngư 野:Dã 菜:Thái 果:Quả 物:Vật 卵:Noãn
水:Thủy 茶:Trà 牛:Ngưu 乳:Nhũ 酒:Tửu 弁:Biện 当:Đương 飲:Ẩm 砂:Sa 糖:Đường 塩:Diêm
金:Kim 財:Tài 布:Bố 円:Viên 買:Mãi 服:Phục 靴:Ngoa 傘:Tản 計:Kế 切:Thiết 手:Thủ
荷:Hà 高:Cao 安:An 全:Toàn 一:Nhất 電:Điện 車:Xa 地:Địa 鉄:Thiết 新:Tân 幹:Cán
線:Tuyến 自:Tự 転:Chuyển 飛:Phi 機:Cơ 符:Phù 旅:Lữ 出:Xuất 張:Trương 右:Hữu 左:Tả
信:Tín 号:Hiệu 机:Cơ 椅:Ỷ 窓:Song 気:Khí 鍵:Kiện 話:Thoại 冷:Lãnh 蔵:Tàng 庫:Khố
写:Tả 真:Chân 紙:Chỉ 聞:Văn 箱:Tương 体:Thể 頭:Đầu 目:Mục 耳:Nhĩ 口:Khẩu 足:Túc
歯:Xỉ 風:Phong 邪:Tà 熱:Nhiệt 薬:Dược 元:Nguyên 天:Thiên 雨:Vũ 雪:Tuyết 山:Sơn
川:Xuyên 海:Hải 花:Hoa 犬:Khuyển 猫:Miêu 暑:Thử 寒:Hàn 暖:Noãn 涼:Lương 小:Tiểu
古:Cổ 悪:Ác 難:Nan 易:Dị 忙:Mang 楽:Lạc 遠:Viễn 早:Tảo 長:Trường 短:Đoản 多:Đa
少:Thiểu 痛:Thống 静:Tĩnh 有:Hữu 親:Thân 利:Lợi 暇:Hạ 丈:Trượng 夫:Phu 好:Hảo
嫌:Hiềm 簡:Giản 単:Đơn 帰:Quy 起:Khởi 寝:Tẩm 見:Kiến 読:Độc 待:Đãi 働:Động
勉:Miễn 強:Cường 分:Phân 使:Sử 作:Tác 送:Tống 入:Nhập 乗:Thừa 降:Giáng 始:Thủy
終:Chung 教:Giáo 習:Tập 借:Tá 貸:Thải 持:Trì 忘:Vong 覚:Giác 知:Tri 住:Trú 遊:Du
泳:Vịnh 歩:Bộ 開:Khai 閉:Bế 消:Tiêu 撮:Toát 洗:Tẩy 呼:Hô 急:Cấp 失:Thất 礼:Lễ
願:Nguyện 疲:Bì 何:Hà 然:Nhiên 緒:Tự 診:Chẩn 探:Thám 遅:Trì 拾:Thập 連:Liên
絡:Lạc 直:Trực 接:Tiếp 平:Bình 捨:Xá 燃:Nhiên 申:Thân 込:Nhập 片:Phiến 付:Phó
調:Điều 故:Cố 合:Hợp 場:Trường 度:Độ 盆:Bồn 缶:Phẫu 置:Trí 踊:Dũng 障:Chướng 届:Giới 番:Phiên 号:Hiệu 運:Vận 動:Động 会:Hội
""".split())

_KANJI = re.compile(r"[一-鿿々]")


def han_viet(word: str) -> str:
    """Âm Hán Việt của các chữ Hán trong từ (bỏ phần furigana), "" nếu không có chữ Hán."""
    # "{何|なん}・{何|なに}": các cách viết của cùng một từ, lấy cách đầu.
    base = re.sub(r"\|[^}]*\}", "", word.split("・")[0]).replace("{", "")
    chars = _KANJI.findall(base)
    missing = [c for c in chars if c not in HV]
    if missing:
        raise KeyError(f"thiếu âm Hán Việt cho {''.join(missing)} trong {word}")
    return " ".join(HV[c] for c in chars)
