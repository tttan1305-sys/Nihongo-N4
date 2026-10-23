using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Nihongo
{
    /// Giao diện vẽ bằng IMGUI: khung bo góc màu xanh đêm giống ứng dụng.
    /// Tọa độ tính trên khung ảo cao 800 điểm, tự co giãn theo màn hình.
    public static class Ui
    {
        public const float VirtualHeight = 800f;
        public static float Scale => Screen.height / VirtualHeight;
        public static float Width => Screen.width / Scale;

        static Font _font;
        static readonly Dictionary<string, Texture2D> Tex = new Dictionary<string, Texture2D>();
        static readonly Dictionary<string, GUIStyle> Styles = new Dictionary<string, GUIStyle>();

        public static readonly Color Navy = new Color(0.055f, 0.086f, 0.204f, 0.92f);
        public static readonly Color Blue = Shapes.Hex(0x4d8dff);
        public static readonly Color Purple = Shapes.Hex(0xb46cff);
        public static readonly Color Red = Shapes.Hex(0xff4d5e);
        public static readonly Color Green = Shapes.Hex(0x3ad87a);
        public static readonly Color Gold = Shapes.Hex(0xffb547);
        public static readonly Color Muted = Shapes.Hex(0xbcd0ff);

        public static void Begin()
        {
            GUI.matrix = Matrix4x4.Scale(new Vector3(Scale, Scale, 1));
            if (_font == null) _font = LoadFont();
        }

        /// Phông có chữ Nhật: tìm phông CJK của hệ thống (Android có Noto CJK).
        static Font LoadFont()
        {
            var names = Font.GetOSInstalledFontNames();
            var cjk = names.Where(n => n.Contains("CJK") || n.Contains("JP") || n.Contains("Japanese") || n.Contains("Gothic") || n.Contains("Fallback")).ToList();
            cjk.AddRange(new[] { "Noto Sans CJK JP", "NotoSansCJK-Regular", "Droid Sans Fallback", "Roboto", "Arial" });
            return Font.CreateDynamicFontFromOSFont(cjk.ToArray(), 28);
        }

        /// Ô màu bo góc (vẽ một lần rồi dùng lại).
        public static Texture2D Rounded(Color fill, Color border, int radius = 14, int borderWidth = 2)
        {
            var key = fill + "|" + border + "|" + radius + "|" + borderWidth;
            if (Tex.TryGetValue(key, out var t)) return t;
            int size = radius * 2 + 4;
            t = new Texture2D(size, size, TextureFormat.RGBA32, false) { filterMode = FilterMode.Bilinear, wrapMode = TextureWrapMode.Clamp };
            for (int y = 0; y < size; y++)
                for (int x = 0; x < size; x++)
                {
                    float cx = Mathf.Clamp(x + 0.5f, radius, size - radius), cy = Mathf.Clamp(y + 0.5f, radius, size - radius);
                    float d = Vector2.Distance(new Vector2(x + 0.5f, y + 0.5f), new Vector2(cx, cy));
                    Color c = d > radius ? Color.clear : d > radius - borderWidth ? border : fill;
                    if (d > radius - 1 && d <= radius) c.a *= radius - d;
                    t.SetPixel(x, y, c);
                }
            t.Apply();
            Tex[key] = t;
            return t;
        }

        public static GUIStyle Style(string name, int size, Color color, FontStyle weight = FontStyle.Normal, TextAnchor align = TextAnchor.MiddleLeft)
        {
            var key = name + size + color + weight + align;
            if (Styles.TryGetValue(key, out var s)) return s;
            s = new GUIStyle(GUI.skin.label)
            {
                font = _font, fontSize = size, fontStyle = weight, alignment = align, richText = true, wordWrap = true,
                padding = new RectOffset(0, 0, 0, 0), margin = new RectOffset(0, 0, 0, 0),
            };
            s.normal.textColor = color;
            Styles[key] = s;
            return s;
        }

        public static void Panel(Rect r, Color? border = null)
        {
            var tex = Rounded(Navy, border ?? Shapes.Hex(0x2a3b6e));
            GUI.Box(r, GUIContent.none, Box9(tex));
        }

        static readonly Dictionary<Texture2D, GUIStyle> BoxStyles = new Dictionary<Texture2D, GUIStyle>();

        static GUIStyle Box9(Texture2D tex)
        {
            if (BoxStyles.TryGetValue(tex, out var s)) return s;
            int b = tex.width / 2 - 1;
            s = new GUIStyle { border = new RectOffset(b, b, b, b) };
            s.normal.background = tex;
            BoxStyles[tex] = s;
            return s;
        }

        public static void Label(Rect r, string text, int size = 18, Color? color = null, FontStyle weight = FontStyle.Normal, TextAnchor align = TextAnchor.MiddleLeft)
        {
            GUI.Label(r, text, Style("l", size, color ?? Color.white, weight, align));
        }

        /// Nút bo góc. Trả về true khi bấm.
        public static bool Button(Rect r, string text, Color fill, int size = 20, Color? border = null)
        {
            var tex = Rounded(fill, border ?? Color.Lerp(fill, Color.white, 0.25f));
            var style = new GUIStyle(Box9(tex)) { font = _font, fontSize = size, alignment = TextAnchor.MiddleCenter, richText = true, wordWrap = true, fontStyle = FontStyle.Bold };
            style.normal.textColor = Color.white;
            style.padding = new RectOffset(10, 10, 4, 4);
            return GUI.Button(r, text, style);
        }

        public static void Bar(Rect r, float value, Color color)
        {
            GUI.DrawTexture(r, Rounded(Shapes.Hex(0x2a3b6e), Shapes.Hex(0x2a3b6e), 6, 0));
            if (value > 0.01f) GUI.DrawTexture(new Rect(r.x, r.y, r.width * Mathf.Clamp01(value), r.height), Rounded(color, color, 6, 0));
        }

        public static void Circle(Vector2 center, float radius, Color color)
        {
            GUI.DrawTexture(new Rect(center.x - radius, center.y - radius, radius * 2, radius * 2), Rounded(color, color, 32, 0));
        }
    }
}
