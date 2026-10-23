using System;
using UnityEngine;
using static Nihongo.Shapes;

namespace Nihongo
{
    public enum HairStyle { Short, Spiky, Ponytail, Twin, Long }
    public enum Outfit { School, Kimono, Ninja, Samurai }

    /// Ngoại hình nhân vật chính, lưu vào máy để giữ lựa chọn tùy biến.
    [Serializable]
    public class Appearance
    {
        public HairStyle style = HairStyle.Ponytail;
        public Outfit outfit = Outfit.School;
        public bool girl = true;
        public uint skin = 0xffe0c8;
        public uint hair = 0x3a2a5a;
        public uint eye = 0x7a4ad8;
        public uint top = 0xf6f6f6;
        public uint bottom = 0x2c3e75;
        public uint accent = 0xe0403a;

        const string Key = "hero.appearance";

        public static Appearance Load()
        {
            var json = PlayerPrefs.GetString(Key, "");
            return string.IsNullOrEmpty(json) ? new Appearance() : JsonUtility.FromJson<Appearance>(json);
        }

        public void Save()
        {
            PlayerPrefs.SetString(Key, JsonUtility.ToJson(this));
            PlayerPrefs.Save();
        }
    }

    /// Nhân vật chibi kiểu anime (đầu to, mắt to) và các loại quái.
    public static class Characters
    {
        const uint Ink = 0x1a1426;

        /// Mặt phẳng tròn dẹt để vẽ mắt, má hồng (không viền).
        static GameObject Flat(Transform p, Vector3 pos, float rx, float ry, uint c)
        {
            var g = Ball(p, pos, 0.5f, c, 0f);
            g.transform.localScale = new Vector3(rx * 2f, ry * 2f, 0.02f);
            return g;
        }

        public static Transform Chibi(Transform parent, Vector3 pos, Appearance a)
        {
            var g = Group("hero", parent, pos).transform;
            bool kimono = a.outfit == Outfit.Kimono;
            foreach (var x in new[] { -0.17f, 0.17f })
            {
                Cyl(g, new Vector3(x, 0.32f, 0), 0.1f, 0.1f, 0.45f, kimono ? a.top : a.skin, 12);
                Box(g, new Vector3(x, 0.08f, 0.04f), new Vector3(0.2f, 0.12f, 0.3f), a.outfit == Outfit.Ninja ? 0x1e1e28u : 0x3a2a26u);
            }
            Cyl(g, new Vector3(0, 0.9f, 0), 0.3f, 0.38f, 0.75f, a.top);
            switch (a.outfit)
            {
                case Outfit.School:
                    if (a.girl) Cyl(g, new Vector3(0, 0.62f, 0), 0.38f, 0.5f, 0.35f, a.bottom);
                    else foreach (var x in new[] { -0.17f, 0.17f }) Cyl(g, new Vector3(x, 0.55f, 0), 0.11f, 0.11f, 0.35f, a.bottom, 12);
                    Box(g, new Vector3(0, 1.24f, 0.12f), new Vector3(0.5f, 0.06f, 0.25f), 0xf6f6f6, 0.01f);
                    Cone(g, new Vector3(0, 1.12f, 0.32f), 0.08f, 0.18f, a.accent, 4).transform.localRotation = Quaternion.Euler(180, 0, 0);
                    break;
                case Outfit.Kimono:
                    Cyl(g, new Vector3(0, 0.6f, 0), 0.39f, 0.52f, 0.5f, a.top);
                    Cyl(g, new Vector3(0, 0.98f, 0), 0.32f, 0.33f, 0.16f, a.accent);
                    Box(g, new Vector3(0, 0.98f, -0.32f), new Vector3(0.22f, 0.18f, 0.12f), a.accent);
                    break;
                case Outfit.Ninja:
                    foreach (var x in new[] { -0.17f, 0.17f }) Cyl(g, new Vector3(x, 0.55f, 0), 0.12f, 0.11f, 0.35f, a.top, 12);
                    Cyl(g, new Vector3(0, 0.82f, 0), 0.31f, 0.32f, 0.1f, a.accent);
                    Box(g, new Vector3(-0.28f, 1.0f, -0.3f), new Vector3(0.12f, 0.6f, 0.04f), a.accent).transform.localRotation = Quaternion.Euler(0, 0, 23);
                    break;
                case Outfit.Samurai:
                    Cyl(g, new Vector3(0, 0.6f, 0), 0.42f, 0.55f, 0.45f, a.bottom, 8);
                    foreach (var x in new[] { -1f, 1f })
                        Box(g, new Vector3(x * 0.38f, 1.2f, 0), new Vector3(0.25f, 0.08f, 0.35f), a.accent).transform.localRotation = Quaternion.Euler(0, 0, -x * 23);
                    Cyl(g, new Vector3(-0.25f, 0.8f, -0.3f), 0.03f, 0.03f, 1.0f, 0x2a2026, 6).transform.localRotation = Quaternion.Euler(0, 0, 63);
                    break;
            }
            foreach (var x in new[] { -1f, 1f })
            {
                Cyl(g, new Vector3(x * 0.4f, 0.95f, 0), 0.08f, 0.09f, 0.5f, a.top, 10).transform.localRotation = Quaternion.Euler(0, 0, x * 20);
                Ball(g, new Vector3(x * 0.49f, 0.72f, 0), 0.09f, a.skin);
            }

            var head = Group("head", g, new Vector3(0, 1.75f, 0)).transform;
            Ball(head, Vector3.zero, 0.55f, a.skin);
            foreach (var x in new[] { -0.2f, 0.2f })
            {
                var e = Group("eye", head, new Vector3(x, -0.05f, 0.5f)).transform;
                e.localRotation = Quaternion.Euler(0, -x * 34, 0);
                Flat(e, Vector3.zero, 0.12f, 0.16f, Ink);
                Flat(e, new Vector3(0, 0, 0.01f), 0.095f, 0.13f, a.eye);
                Flat(e, new Vector3(0, -0.01f, 0.02f), 0.05f, 0.07f, Ink);
                Flat(e, new Vector3(-0.035f, 0.06f, 0.03f), 0.035f, 0.035f, 0xffffff);
                Flat(e, new Vector3(0.04f, -0.06f, 0.03f), 0.018f, 0.018f, 0xffffff);
                Box(e, new Vector3(0, 0.17f, 0.01f), new Vector3(0.28f, 0.035f, 0.01f), Ink, 0f).transform.localRotation = Quaternion.Euler(0, 0, x > 0 ? -9 : 9);
                Flat(e, new Vector3(x * 0.3f, -0.2f, -0.03f), 0.07f, 0.04f, 0xffaab8);
            }
            Box(head, new Vector3(0, -0.28f, 0.52f), new Vector3(0.1f, 0.025f, 0.01f), 0x8a2a30, 0f);

            // Tóc: chỏm + mái + tóc mai, rồi phần riêng theo kiểu tóc.
            var cap = Ball(head, new Vector3(0, 0.1f, -0.06f), 0.6f, a.hair, 0.02f);
            cap.transform.localScale = new Vector3(1.2f, 1.05f, 1.15f);
            for (int i = -2; i <= 2; i++)
            {
                var b = Cone(head, new Vector3(i * 0.17f, 0.25f, 0.44f - Mathf.Abs(i) * 0.05f), 0.13f, 0.42f, a.hair, 6, 0.02f);
                b.transform.localRotation = Quaternion.Euler(180 - 29, 0, -i * 7);
            }
            foreach (var x in new[] { -1f, 1f })
                Cone(head, new Vector3(x * 0.5f, -0.15f, 0.05f), 0.14f, 0.6f, a.hair, 6, 0.02f).transform.localRotation = Quaternion.Euler(0, 0, 180 + x * 9);
            switch (a.style)
            {
                case HairStyle.Spiky:
                    for (int i = 0; i < 7; i++)
                    {
                        float ang = i / 7f * Mathf.PI * 2f;
                        var sp = Cone(head, new Vector3(Mathf.Cos(ang) * 0.3f, 0.5f, Mathf.Sin(ang) * 0.3f - 0.1f), 0.16f, 0.55f, a.hair, 6, 0.02f);
                        sp.transform.localRotation = Quaternion.Euler(Mathf.Sin(ang) * 40, 0, -Mathf.Cos(ang) * 40);
                    }
                    break;
                case HairStyle.Ponytail:
                    Ball(head, new Vector3(0, 0.25f, -0.58f), 0.16f, a.hair, 0.02f);
                    Cone(head, new Vector3(0, -0.3f, -0.72f), 0.22f, 1.0f, a.hair, 10, 0.02f).transform.localRotation = Quaternion.Euler(180 + 14, 0, 0);
                    Cyl(head, new Vector3(0, 0.2f, -0.62f), 0.1f, 0.1f, 0.08f, a.accent, 12).transform.localRotation = Quaternion.Euler(75, 0, 0);
                    break;
                case HairStyle.Twin:
                    foreach (var x in new[] { -1f, 1f })
                    {
                        Ball(head, new Vector3(x * 0.52f, 0.25f, -0.2f), 0.14f, a.hair, 0.02f);
                        Cone(head, new Vector3(x * 0.62f, -0.25f, -0.25f), 0.18f, 0.9f, a.hair, 10, 0.02f).transform.localRotation = Quaternion.Euler(180, 0, x * 11);
                    }
                    break;
                case HairStyle.Long:
                    var l = Cyl(head, new Vector3(0, -0.45f, -0.18f), 0.5f, 0.56f, 1.1f, a.hair, 20, 0.02f);
                    l.transform.localScale = new Vector3(1f, 1f, 0.6f);
                    Ball(head, new Vector3(0.42f, 0.3f, 0.25f), 0.1f, a.accent);
                    break;
            }
            if (a.outfit == Outfit.Ninja)
            {
                Cyl(head, new Vector3(0, -0.32f, 0.02f), 0.56f, 0.56f, 0.22f, 0x1e1e28, 24, 0.01f);
                Cyl(head, new Vector3(0, 0.3f, 0), 0.62f, 0.62f, 0.1f, a.accent, 24, 0.01f).transform.localRotation = Quaternion.Euler(-14, 0, 0);
            }
            if (a.outfit == Outfit.Samurai) Cyl(head, new Vector3(0, 0.62f, -0.1f), 0.12f, 0.08f, 0.14f, 0x2a2a3a, 10);
            return g;
        }

        /// Quỷ Oni: lính thường (nhỏ, một sừng) hoặc boss (to, hai sừng, mắt vàng).
        public static Transform Oni(Transform parent, Vector3 pos, uint skin, float size, bool boss)
        {
            var g = Group(boss ? "oni-boss" : "oni", parent, pos).transform;
            foreach (var x in new[] { -0.22f, 0.22f }) Cyl(g, new Vector3(x, 0.25f, 0), 0.13f, 0.15f, 0.5f, skin, 10);
            Cyl(g, new Vector3(0, 0.6f, 0), 0.45f, 0.42f, 0.3f, 0xf2c230);
            Cyl(g, new Vector3(0, 1.05f, 0), 0.38f, 0.45f, 0.7f, skin);
            foreach (var x in new[] { -1f, 1f })
            {
                Cyl(g, new Vector3(x * 0.55f, 1.05f, 0), 0.12f, 0.14f, 0.6f, skin, 10).transform.localRotation = Quaternion.Euler(0, 0, x * 29);
                Ball(g, new Vector3(x * 0.7f, 0.78f, 0), 0.14f, skin);
            }
            var head = Group("head", g, new Vector3(0, 1.75f, 0)).transform;
            Ball(head, Vector3.zero, 0.5f, skin);
            var hair = Ball(head, new Vector3(0, 0.15f, -0.08f), 0.52f, 0x2a2030, 0.02f);
            hair.transform.localScale = new Vector3(1.1f, 0.9f, 1.05f);
            if (boss)
                foreach (var x in new[] { -0.25f, 0.25f })
                    Cone(head, new Vector3(x, 0.55f, 0.05f), 0.1f, 0.4f, 0xfff2d0, 8).transform.localRotation = Quaternion.Euler(0, 0, -x * 69);
            else Cone(head, new Vector3(0, 0.55f, 0.05f), 0.1f, 0.4f, 0xfff2d0, 8);
            foreach (var x in new[] { -0.18f, 0.18f })
            {
                var e = Group("eye", head, new Vector3(x, 0.02f, 0.47f)).transform;
                e.localRotation = Quaternion.Euler(0, -x * 57, 0);
                Flat(e, Vector3.zero, 0.1f, 0.08f, boss ? 0xffe23au : 0xffffffu);
                Flat(e, new Vector3(0, -0.01f, 0.01f), 0.045f, 0.045f, Ink);
                Box(e, new Vector3(0, 0.12f, 0.01f), new Vector3(0.22f, 0.05f, 0.01f), Ink, 0f).transform.localRotation = Quaternion.Euler(0, 0, x > 0 ? 23 : -23);
            }
            foreach (var x in new[] { -0.12f, 0.12f }) Cone(head, new Vector3(x, -0.22f, 0.44f), 0.04f, 0.12f, 0xffffff, 6, 0.01f);
            // Gậy gai kanabō
            var club = Group("club", g, new Vector3(0.8f, 0.7f, 0.1f)).transform;
            Cyl(club, new Vector3(0, 0.3f, 0), 0.05f, 0.05f, 0.6f, 0x5a3a2a, 8);
            Cyl(club, new Vector3(0, 1.0f, 0), 0.16f, 0.1f, 1.0f, 0x3a3240, 8);
            club.localRotation = Quaternion.Euler(0, 0, -29);
            g.localScale = Vector3.one * size;
            return g;
        }

        /// Kiếm sĩ cáo (lính tinh anh): chibi samurai có tai và đuôi cáo.
        public static Transform Kitsune(Transform parent, Vector3 pos, float size)
        {
            var a = new Appearance
            {
                skin = 0xfff2e6, hair = 0xf0a040, eye = 0xd8402a, style = HairStyle.Long,
                outfit = Outfit.Samurai, top = 0xf6f4ee, bottom = 0xb8303a, accent = 0x2a2a3a,
            };
            var g = Chibi(parent, pos, a);
            g.name = "kitsune";
            var head = g.Find("head");
            foreach (var x in new[] { -1f, 1f })
            {
                Cone(head, new Vector3(x * 0.32f, 0.6f, 0), 0.17f, 0.4f, 0xf0a040, 4).transform.localRotation = Quaternion.Euler(0, 0, x * 20);
            }
            for (int i = 0; i < 3; i++)
            {
                var t = Group("tail", g, new Vector3(0, 0.7f, -0.35f)).transform;
                var b = Ball(t, new Vector3(0, 0.45f, 0), 0.3f, 0xf0a040);
                b.transform.localScale = new Vector3(0.42f, 0.96f, 0.42f);
                Ball(t, new Vector3(0, 0.95f, 0), 0.18f, 0xfff2e6);
                t.localRotation = Quaternion.Euler(-46, 0, (i - 1) * 34);
            }
            g.localScale = Vector3.one * size;
            return g;
        }
    }
}
