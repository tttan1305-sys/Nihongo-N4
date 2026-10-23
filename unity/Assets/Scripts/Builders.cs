using UnityEngine;
using static Nihongo.Shapes;

namespace Nihongo
{
    /// Kiến trúc và cây cối Nhật Bản dựng từ khối đơn giản, theo bản phác thảo.
    public static class Builders
    {
        public const uint Dark = 0x2a2026;

        public static Transform Torii(Transform parent, Vector3 pos, uint color = 0xe0402a, float s = 1f)
        {
            var g = Group("torii", parent, pos).transform;
            foreach (var x in new[] { -0.9f, 0.9f })
            {
                Cyl(g, new Vector3(x, 1.2f, 0), 0.12f, 0.14f, 2.4f, color);
                Box(g, new Vector3(x, 0.1f, 0), new Vector3(0.34f, 0.2f, 0.34f), Dark);
            }
            Box(g, new Vector3(0, 2.45f, 0), new Vector3(2.6f, 0.18f, 0.3f), Dark);
            Box(g, new Vector3(0, 2.28f, 0), new Vector3(2.3f, 0.14f, 0.24f), color);
            Box(g, new Vector3(0, 1.9f, 0), new Vector3(2.1f, 0.12f, 0.18f), color);
            g.localScale = Vector3.one * s;
            return g;
        }

        static void Roof(Transform g, Vector3 pos, float w, float h, uint c)
        {
            Cyl(g, pos, 0f, w, h, c, 4);
        }

        public static Transform Pagoda(Transform parent, Vector3 pos, int levels = 5, uint wall = 0xc8462e, uint roof = 0x3a3f4a, float s = 1f)
        {
            var g = Group("pagoda", parent, pos).transform;
            Box(g, new Vector3(0, 0.2f, 0), new Vector3(2.2f, 0.4f, 2.2f), 0x8b8b8b);
            float y = 0.4f;
            for (int i = 0; i < levels; i++)
            {
                float w = 1.5f - i * 0.16f;
                Box(g, new Vector3(0, y + 0.35f, 0), new Vector3(w, 0.7f, w), wall);
                Roof(g, new Vector3(0, y + 0.85f, 0), w * 1.15f, 0.45f, roof);
                y += 0.95f;
            }
            Cyl(g, new Vector3(0, y + 0.4f, 0), 0.04f, 0.06f, 1.1f, 0xd4a72c, 8);
            g.localScale = Vector3.one * s;
            return g;
        }

        public static Transform GoldenPavilion(Transform parent, Vector3 pos, float s = 1f)
        {
            var g = Group("kinkakuji", parent, pos).transform;
            Box(g, new Vector3(0, 0.5f, 0), new Vector3(3, 1, 2.2f), 0xf2ead8);
            Box(g, new Vector3(0, 1.05f, 0), new Vector3(3.6f, 0.15f, 2.8f), 0x3a3226);
            Box(g, new Vector3(0, 1.55f, 0), new Vector3(2.6f, 0.9f, 2f), 0xe8b931, 0.025f, 0x3a2a00);
            Box(g, new Vector3(0, 2.05f, 0), new Vector3(3.2f, 0.15f, 2.6f), 0x3a3226);
            Box(g, new Vector3(0, 2.5f, 0), new Vector3(1.8f, 0.8f, 1.5f), 0xf0c63a, 0.025f, 0x3a2a00);
            Roof(g, new Vector3(0, 3.3f, 0), 1.9f, 0.9f, 0x3a3226);
            Ball(g, new Vector3(0, 3.85f, 0), 0.18f, 0xffd84a);
            g.localScale = Vector3.one * s;
            return g;
        }

        public static Transform Machiya(Transform parent, Vector3 pos, uint color = 0x7a4b2a, float s = 1f)
        {
            var g = Group("machiya", parent, pos).transform;
            Box(g, new Vector3(0, 0.45f, 0), new Vector3(1.6f, 0.9f, 1.2f), color);
            var r = Cyl(g, new Vector3(0, 1.15f, 0), 0.01f, 1.2f, 0.5f, 0x3d4250, 4);
            r.transform.localScale = new Vector3(1.3f, 1, 1);
            Box(g, new Vector3(0.5f, 0.5f, 0.62f), new Vector3(0.06f, 0.6f, 0.02f), 0xe85a3a, 0f);
            Box(g, new Vector3(-0.3f, 0.45f, 0.61f), new Vector3(0.6f, 0.5f, 0.02f), 0xfff2c0, 0f, 0x403010);
            g.localScale = Vector3.one * s;
            return g;
        }

        public static Transform Sakura(Transform parent, Vector3 pos, float s = 1f)
        {
            var g = Group("sakura", parent, pos).transform;
            Cyl(g, new Vector3(0, 0.5f, 0), 0.08f, 0.13f, 1f, 0x5a3a2a, 8);
            Ball(g, new Vector3(0, 1.3f, 0), 0.6f, 0xf6b6cc);
            Ball(g, new Vector3(0.4f, 1.1f, 0.2f), 0.45f, 0xf6b6cc);
            Ball(g, new Vector3(-0.4f, 1.15f, -0.1f), 0.45f, 0xf6b6cc);
            Ball(g, new Vector3(0.1f, 1.2f, -0.4f), 0.4f, 0xf6b6cc);
            g.localScale = Vector3.one * s;
            return g;
        }

        public static Transform Pine(Transform parent, Vector3 pos, float s = 1f)
        {
            var g = Group("pine", parent, pos).transform;
            Cyl(g, new Vector3(0, 0.3f, 0), 0.07f, 0.1f, 0.6f, 0x5a3a2a, 8);
            Cone(g, new Vector3(0, 0.9f, 0), 0.6f, 0.9f, 0x2f7a4a, 8);
            Cone(g, new Vector3(0, 1.35f, 0), 0.45f, 0.8f, 0x358a52, 8);
            g.localScale = Vector3.one * s;
            return g;
        }

        public static Transform Lantern(Transform parent, Vector3 pos, float s = 1f)
        {
            var g = Group("lantern", parent, pos).transform;
            Cyl(g, new Vector3(0, 0.25f, 0), 0.12f, 0.18f, 0.5f, 0x9a958c, 6);
            Box(g, new Vector3(0, 0.65f, 0), new Vector3(0.36f, 0.3f, 0.36f), 0xfff0a0, 0.025f, 0x7a5a10);
            Roof(g, new Vector3(0, 0.92f, 0), 0.4f, 0.25f, 0x8a857c);
            g.localScale = Vector3.one * s;
            return g;
        }

        /// Cổng ải: bệ đá, cờ và vòng sáng. Màu theo loại quái.
        public static Transform GateMarker(Transform parent, Vector3 pos, GateKind kind, float s = 1f)
        {
            var g = Group("gate", parent, pos).transform;
            uint col = kind == GateKind.Minion ? 0x4d8dffu : kind == GateKind.Elite ? 0xb46cffu : 0xff4d5eu;
            float size = kind == GateKind.Boss ? 1.4f : 1f;
            Cyl(g, new Vector3(0, 0.15f, 0), 0.45f * size, 0.55f * size, 0.3f, 0x8a857c, 8);
            Cyl(g, new Vector3(0, 0.95f * size, 0), 0.03f, 0.03f, 1.6f * size, 0x3a3226, 6);
            Box(g, new Vector3(0.3f * size, 1.5f * size, 0), new Vector3(0.6f * size, 0.4f * size, 0.03f), col, 0.025f, col & 0x555555);
            Disc(g, new Vector3(0, 0.02f, 0), 0.8f * size, col, col & 0x777777);
            g.localScale = Vector3.one * s;
            return g;
        }
    }
}
