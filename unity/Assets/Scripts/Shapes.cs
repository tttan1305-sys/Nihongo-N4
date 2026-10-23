using System.Collections.Generic;
using UnityEngine;

namespace Nihongo
{
    /// Dựng hình khối đơn giản (hộp, trụ, nón, cầu) với vật liệu hoạt hình.
    /// Toàn bộ cảnh được tạo bằng mã, không cần mô hình 3D có sẵn.
    public static class Shapes
    {
        static Shader _shader;
        static readonly Dictionary<string, Material> Mats = new Dictionary<string, Material>();
        static readonly Dictionary<string, Mesh> Meshes = new Dictionary<string, Mesh>();

        public static Color Hex(uint rgb)
        {
            return new Color(((rgb >> 16) & 0xff) / 255f, ((rgb >> 8) & 0xff) / 255f, (rgb & 0xff) / 255f);
        }

        public static Material Mat(uint rgb, float outline = 0.025f, uint emission = 0)
        {
            var key = rgb + "_" + outline + "_" + emission;
            if (Mats.TryGetValue(key, out var m)) return m;
            if (_shader == null) _shader = Resources.Load<Shader>("NihongoToon") ?? Shader.Find("Nihongo/Toon") ?? Shader.Find("Standard");
            m = new Material(_shader);
            m.SetColor("_Color", Hex(rgb));
            m.SetFloat("_Outline", outline);
            m.SetColor("_Emission", Hex(emission));
            m.color = Hex(rgb);
            Mats[key] = m;
            return m;
        }

        public static GameObject Make(string name, Mesh mesh, uint color, Transform parent, Vector3 pos, float outline = 0.025f, uint emission = 0)
        {
            var go = new GameObject(name);
            go.AddComponent<MeshFilter>().sharedMesh = mesh;
            var r = go.AddComponent<MeshRenderer>();
            r.sharedMaterial = Mat(color, outline, emission);
            go.transform.SetParent(parent, false);
            go.transform.localPosition = pos;
            return go;
        }

        public static GameObject Box(Transform p, Vector3 pos, Vector3 size, uint c, float outline = 0.025f, uint emission = 0)
        {
            var g = Make("box", BoxMesh(), c, p, pos, outline, emission);
            g.transform.localScale = size;
            return g;
        }

        /// Trụ (hoặc nón cụt) có [seg] cạnh. rTop = 0 thành hình nón; seg = 4 thành kim tự tháp (mái nhà).
        public static GameObject Cyl(Transform p, Vector3 pos, float rTop, float rBottom, float h, uint c, int seg = 16, float outline = 0.025f, uint emission = 0)
        {
            return Make("cyl", CylMesh(rTop, rBottom, h, seg), c, p, pos, outline, emission);
        }

        public static GameObject Cone(Transform p, Vector3 pos, float r, float h, uint c, int seg = 16, float outline = 0.025f)
        {
            return Cyl(p, pos, 0f, r, h, c, seg, outline);
        }

        public static GameObject Ball(Transform p, Vector3 pos, float r, uint c, float outline = 0.025f, uint emission = 0)
        {
            var g = Make("ball", SphereMesh(), c, p, pos, outline, emission);
            g.transform.localScale = Vector3.one * r * 2f;
            return g;
        }

        /// Mặt phẳng tròn nằm ngang (mặt đất, ao, vòng sáng).
        public static GameObject Disc(Transform p, Vector3 pos, float r, uint c, uint emission = 0)
        {
            var g = Make("disc", CylMesh(r, r, 0.02f, 48), c, p, pos, 0f, emission);
            return g;
        }

        public static GameObject Group(string name, Transform parent, Vector3 pos)
        {
            var g = new GameObject(name);
            g.transform.SetParent(parent, false);
            g.transform.localPosition = pos;
            return g;
        }

        // ---------- Lưới ----------

        static Mesh BoxMesh()
        {
            if (Meshes.TryGetValue("box", out var cached)) return cached;
            var go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            var m = go.GetComponent<MeshFilter>().sharedMesh;
            Object.Destroy(go);
            Meshes["box"] = m;
            return m;
        }

        static Mesh SphereMesh()
        {
            if (Meshes.TryGetValue("sphere", out var cached)) return cached;
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            var m = go.GetComponent<MeshFilter>().sharedMesh;
            Object.Destroy(go);
            Meshes["sphere"] = m;
            return m;
        }

        /// Trụ đáy tâm ở giữa chiều cao, có nắp trên và dưới, pháp tuyến phẳng từng mặt
        /// để đổ bóng hoạt hình rõ cạnh.
        public static Mesh CylMesh(float rTop, float rBottom, float h, int seg)
        {
            var key = "cyl_" + rTop + "_" + rBottom + "_" + h + "_" + seg;
            if (Meshes.TryGetValue(key, out var cached)) return cached;
            var v = new List<Vector3>();
            var n = new List<Vector3>();
            var t = new List<int>();
            float y0 = -h / 2f, y1 = h / 2f;
            float offset = seg == 4 ? Mathf.PI / 4f : 0f;
            for (int i = 0; i < seg; i++)
            {
                float a0 = offset + i * Mathf.PI * 2f / seg, a1 = offset + (i + 1) * Mathf.PI * 2f / seg;
                var b0 = new Vector3(Mathf.Cos(a0) * rBottom, y0, Mathf.Sin(a0) * rBottom);
                var b1 = new Vector3(Mathf.Cos(a1) * rBottom, y0, Mathf.Sin(a1) * rBottom);
                var c0 = new Vector3(Mathf.Cos(a0) * rTop, y1, Mathf.Sin(a0) * rTop);
                var c1 = new Vector3(Mathf.Cos(a1) * rTop, y1, Mathf.Sin(a1) * rTop);
                bool smooth = seg > 8;
                int s = v.Count;
                v.Add(b0); v.Add(b1); v.Add(c1); v.Add(c0);
                if (smooth)
                {
                    float slope = (rBottom - rTop) / h;
                    n.Add(new Vector3(Mathf.Cos(a0), slope, Mathf.Sin(a0)).normalized);
                    n.Add(new Vector3(Mathf.Cos(a1), slope, Mathf.Sin(a1)).normalized);
                    n.Add(new Vector3(Mathf.Cos(a1), slope, Mathf.Sin(a1)).normalized);
                    n.Add(new Vector3(Mathf.Cos(a0), slope, Mathf.Sin(a0)).normalized);
                }
                else
                {
                    var fn = Vector3.Cross(c0 - b0, b1 - b0).normalized;
                    for (int k = 0; k < 4; k++) n.Add(fn);
                }
                t.Add(s); t.Add(s + 2); t.Add(s + 1);
                t.Add(s); t.Add(s + 3); t.Add(s + 2);
                // nắp dưới
                int d = v.Count;
                v.Add(new Vector3(0, y0, 0)); v.Add(b0); v.Add(b1);
                n.Add(Vector3.down); n.Add(Vector3.down); n.Add(Vector3.down);
                t.Add(d); t.Add(d + 1); t.Add(d + 2);
                if (rTop > 0)
                {
                    int u = v.Count;
                    v.Add(new Vector3(0, y1, 0)); v.Add(c1); v.Add(c0);
                    n.Add(Vector3.up); n.Add(Vector3.up); n.Add(Vector3.up);
                    t.Add(u); t.Add(u + 1); t.Add(u + 2);
                }
            }
            var m = new Mesh { name = key };
            m.SetVertices(v);
            m.SetNormals(n);
            m.SetTriangles(t, 0);
            m.RecalculateBounds();
            Meshes[key] = m;
            return m;
        }
    }
}
