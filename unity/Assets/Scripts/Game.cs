using System.Collections.Generic;
using UnityEngine;
using static Nihongo.Shapes;

namespace Nihongo
{
    /// Điểm khởi đầu của game: dựng vùng Kyoto (bài 26), nhân vật, các cửa ải,
    /// cần điều khiển và giao diện. Toàn bộ cảnh tạo bằng mã.
    public class Game : MonoBehaviour
    {
        public const int LessonNumber = 26;

        class GateSpot
        {
            public GateInfo info;
            public Vector3 pos;
            public Transform enemy;
            public Transform marker;
        }

        Transform _world;
        Transform _hero;
        Appearance _look;
        Lesson _lesson;
        readonly List<GateSpot> _gates = new List<GateSpot>();
        Battle _battle;
        Camera _cam;
        Vector3 _velocity;
        float _walk;
        string _toast;
        float _toastUntil;
        bool _customizing;

        // Cần điều khiển ảo (tọa độ khung ảo của Ui).
        int _joyFinger = -1;
        Vector2 _joyCenter, _joyKnob;
        bool _joyMouse;

        const float JoyRadius = 70f;
        // Máy quay đứng phía sau (z dương) nhìn về hướng đường đi (z âm).
        static readonly Vector3 CamOffset = new Vector3(0, 7.5f, 9.5f);

        void Start()
        {
            Application.targetFrameRate = 60;
            _lesson = Lesson.Load(LessonNumber);
            _look = Appearance.Load();
            _world = new GameObject("world").transform;
            SetupCameraAndLight();
            BuildKyoto();
            SpawnHero();
            if (_lesson != null) SpawnGates(GateInfo.ForLesson(_lesson));
            else Toast("Không đọc được dữ liệu bài " + LessonNumber);
            _battle = gameObject.AddComponent<Battle>();
            _battle.OnFinished = OnBattleFinished;
        }

        void SetupCameraAndLight()
        {
            var camGo = new GameObject("camera");
            _cam = camGo.AddComponent<Camera>();
            _cam.clearFlags = CameraClearFlags.SolidColor;
            _cam.backgroundColor = Hex(0xffd6b0);
            _cam.fieldOfView = 50;
            _cam.farClipPlane = 200;
            RenderSettings.fog = true;
            RenderSettings.fogColor = Hex(0xffd6b0);
            RenderSettings.fogMode = FogMode.Linear;
            RenderSettings.fogStartDistance = 35;
            RenderSettings.fogEndDistance = 95;
            RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
            RenderSettings.ambientLight = Hex(0xb8c4e0);
            var sun = new GameObject("sun").AddComponent<Light>();
            sun.type = LightType.Directional;
            sun.color = Hex(0xfff2dd);
            sun.intensity = 1.25f;
            sun.shadows = LightShadows.Soft;
            sun.transform.rotation = Quaternion.Euler(50, -30, 0);
            QualitySettings.shadowDistance = 45;
        }

        // ---------- Bản đồ Kyoto ----------

        void BuildKyoto()
        {
            var w = _world;
            var ground = Box(w, new Vector3(0, -0.5f, -30), new Vector3(80, 1, 110), 0x9ed27a, 0f);
            ground.name = "ground";
            // Đường đá chính, đi từ cổng làng (z = 8) lên đền (z = -66).
            for (float z = 8; z > -66; z -= 1.2f) Box(w, new Vector3(0, 0.04f, z), new Vector3(3.2f, 0.08f, 1.1f), 0xd8c8a8, 0f);
            // Hàng cổng torii Fushimi Inari.
            for (int i = 0; i < 10; i++) Builders.Torii(w, new Vector3(0, 0, -14 - i * 2.2f), 0xf0532e, 1.5f);
            // Phố nhà gỗ machiya hai bên đường.
            uint[] wood = { 0x7a4b2a, 0x6a3a22, 0x8a5a3a };
            for (int i = 0; i < 6; i++)
                foreach (var x in new[] { -6.5f, 6.5f })
                {
                    var h = Builders.Machiya(w, new Vector3(x, 0, 6 - i * 4.5f), wood[i % 3], 2f);
                    h.localRotation = Quaternion.Euler(0, x < 0 ? 90 : -90, 0);
                }
            foreach (var p in new[] { new Vector3(-3.6f, 0, 3), new Vector3(3.6f, 0, 0), new Vector3(-3.8f, 0, -5), new Vector3(3.8f, 0, -10), new Vector3(-3.6f, 0, -40), new Vector3(3.6f, 0, -46) })
                Builders.Lantern(w, p, 1.6f);
            foreach (var p in new[] { new Vector3(-10, 0, -2), new Vector3(10, 0, -12), new Vector3(-11, 0, -16), new Vector3(10, 0, 2), new Vector3(-12, 0, 8), new Vector3(9, 0, -38), new Vector3(-9, 0, -44), new Vector3(11, 0, -52) })
                Builders.Sakura(w, p, 2.4f);
            for (int i = 0; i < 24; i++)
            {
                float side = i % 2 == 0 ? -1 : 1;
                Builders.Pine(w, new Vector3(side * (16 + (i * 7) % 9), 0, 10 - i * 3.3f), 1.6f + (i % 3) * 0.3f);
            }
            // Chùa tháp năm tầng và Kim Các Tự bên ao, gần chỗ boss.
            Builders.Pagoda(w, new Vector3(-12, 0, -30), 5, 0xc8462e, 0x3a3f4a, 2.4f);
            var pond = Disc(w, new Vector3(9, 0.03f, -58), 6f, 0x5ab8ee);
            pond.name = "pond";
            Builders.GoldenPavilion(w, new Vector3(9, 0, -63), 2.0f);
            Builders.Torii(w, new Vector3(0, 0, -62), 0xd8402e, 2.4f);
        }

        void SpawnHero()
        {
            if (_hero != null) Destroy(_hero.gameObject);
            var old = _hero != null ? _hero.position : new Vector3(0, 0, 6);
            _hero = Characters.Chibi(null, old, _look);
            _hero.localRotation = Quaternion.Euler(0, 180, 0);
        }

        void SpawnGates(List<GateInfo> infos)
        {
            // Vị trí ải dọc đường: lính thường xen kẽ hai bên, tinh anh, rồi boss ở cuối.
            float z = -4;
            int n = 0;
            foreach (var info in infos)
            {
                var spot = new GateSpot { info = info };
                float x = info.kind == GateKind.Boss ? 0 : (n % 2 == 0 ? 2.6f : -2.6f);
                spot.pos = new Vector3(x, 0, info.kind == GateKind.Boss ? -56 : z);
                spot.marker = Builders.GateMarker(_world, spot.pos + new Vector3(x > 0 ? 1.4f : -1.4f, 0, 0.8f), info.kind, 1.1f);
                spot.enemy = info.kind switch
                {
                    GateKind.Boss => Characters.Oni(_world, spot.pos, 0xd83a3a, 1.6f, true),
                    GateKind.Elite => Characters.Kitsune(_world, spot.pos, 1.15f),
                    _ => Characters.Oni(_world, spot.pos, n % 2 == 0 ? 0x4a8ae8u : 0x4ac878u, 0.9f, false),
                };
                spot.enemy.localRotation = Quaternion.Euler(0, 180, 0);
                spot.enemy.gameObject.SetActive(!info.Cleared);
                _gates.Add(spot);
                z -= info.kind == GateKind.Elite ? 10 : 8;
                n++;
            }
        }

        /// Ải đầu tiên chưa qua; ải sau mở khi ải trước đã qua.
        GateSpot NextGate()
        {
            foreach (var g in _gates) if (!g.info.Cleared) return g;
            return null;
        }

        // ---------- Mỗi khung hình ----------

        void Update()
        {
            if (_hero == null) return;
            bool busy = _battle.Active || _customizing;
            Vector2 input = busy ? Vector2.zero : ReadMove();
            // Đẩy cần lên là đi tới (z âm), sang phải là x âm vì máy quay nhìn ngược trục z.
            var move = new Vector3(-input.x, 0, -input.y);
            if (move.sqrMagnitude > 1) move.Normalize();
            _velocity = Vector3.Lerp(_velocity, move * 6f, Time.deltaTime * 10f);
            var p = _hero.position + _velocity * Time.deltaTime;
            p.x = Mathf.Clamp(p.x, -14, 14);
            p.z = Mathf.Clamp(p.z, -64, 9);
            _hero.position = p;
            if (_velocity.sqrMagnitude > 0.05f)
            {
                _hero.rotation = Quaternion.Slerp(_hero.rotation, Quaternion.LookRotation(_velocity), Time.deltaTime * 12f);
                _walk += Time.deltaTime * 12f;
            }
            else _walk = 0;
            // Nhún nhẹ khi đi.
            var bob = Mathf.Abs(Mathf.Sin(_walk)) * 0.12f;
            _hero.position = new Vector3(_hero.position.x, bob, _hero.position.z);

            var target = _hero.position + CamOffset;
            _cam.transform.position = Vector3.Lerp(_cam.transform.position == Vector3.zero ? target : _cam.transform.position, target, Time.deltaTime * 5f);
            _cam.transform.LookAt(_hero.position + Vector3.up * 1.2f);

            foreach (var g in _gates)
            {
                if (!g.enemy.gameObject.activeSelf) continue;
                g.enemy.localScale = g.enemy.localScale; // giữ nguyên tỉ lệ
                var e = g.enemy.position;
                e.y = Mathf.Abs(Mathf.Sin(Time.time * 2f + g.pos.z)) * 0.15f;
                g.enemy.position = e;
                var look = _hero.position - g.enemy.position;
                look.y = 0;
                if (look.sqrMagnitude > 0.01f) g.enemy.rotation = Quaternion.Slerp(g.enemy.rotation, Quaternion.LookRotation(look), Time.deltaTime * 4f);
                if (!busy && Vector3.Distance(Flat(_hero.position), Flat(g.pos)) < 1.8f) TryEnter(g);
            }
        }

        static Vector3 Flat(Vector3 v) => new Vector3(v.x, 0, v.z);

        void TryEnter(GateSpot g)
        {
            var next = NextGate();
            if (next != g)
            {
                Toast("Hãy qua " + next.info.title + " (" + next.info.subtitle + ") trước");
                // Đẩy nhân vật lùi lại để không vào lại ngay.
                _hero.position += (Flat(_hero.position) - Flat(g.pos)).normalized * 1.2f;
                return;
            }
            _battle.Begin(g.info);
        }

        void OnBattleFinished(GateInfo info, bool won)
        {
            var spot = _gates.Find(s => s.info == info);
            if (won)
            {
                info.MarkCleared();
                PlayerPrefs.SetInt("hero.xp", PlayerPrefs.GetInt("hero.xp", 0) + (info.kind == GateKind.Boss ? 100 : info.kind == GateKind.Elite ? 50 : 30));
                spot.enemy.gameObject.SetActive(false);
                Toast(NextGate() == null ? "Đã chinh phục Kyoto! Vùng tiếp theo sắp mở." : "Qua ải! Tiếp tục tới " + NextGate().info.title);
            }
            else
            {
                _hero.position += (Flat(_hero.position) - Flat(spot.pos)).normalized * 2f;
                Toast("Hết máu rồi. Ôn lại rồi thử lại nhé!");
            }
        }

        void Toast(string text)
        {
            _toast = text;
            _toastUntil = Time.time + 3f;
        }

        // ---------- Điều khiển ----------

        Vector2 ReadMove()
        {
            var v = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
            if (_joyFinger >= 0 || _joyMouse)
            {
                var d = (_joyKnob - _joyCenter) / JoyRadius;
                v += new Vector2(d.x, -d.y);
            }
            return v;
        }

        /// Chạm nửa trái màn hình để hiện cần điều khiển tại chỗ chạm.
        void TrackJoystick()
        {
            float s = Ui.Scale;
            Vector2 ToUi(Vector2 screen) => new Vector2(screen.x / s, (Screen.height - screen.y) / s);
            if (Input.touchCount > 0)
            {
                foreach (var t in Input.touches)
                {
                    var p = ToUi(t.position);
                    if (t.phase == TouchPhase.Began && _joyFinger < 0 && p.x < Ui.Width * 0.5f && p.y > 140)
                    {
                        _joyFinger = t.fingerId;
                        _joyCenter = _joyKnob = p;
                    }
                    else if (t.fingerId == _joyFinger)
                    {
                        if (t.phase == TouchPhase.Ended || t.phase == TouchPhase.Canceled) _joyFinger = -1;
                        else _joyKnob = _joyCenter + Vector2.ClampMagnitude(p - _joyCenter, JoyRadius);
                    }
                }
                return;
            }
            // Chuột (máy tính) cũng dùng được cần điều khiển.
            var m = ToUi(Input.mousePosition);
            if (Input.GetMouseButtonDown(0) && m.x < Ui.Width * 0.5f && m.y > 140) { _joyMouse = true; _joyCenter = _joyKnob = m; }
            else if (Input.GetMouseButton(0) && _joyMouse) _joyKnob = _joyCenter + Vector2.ClampMagnitude(m - _joyCenter, JoyRadius);
            else if (!Input.GetMouseButton(0)) _joyMouse = false;
        }

        void LateUpdate()
        {
            if (!_battle.Active && !_customizing) TrackJoystick();
            else { _joyFinger = -1; _joyMouse = false; }
        }

        // ---------- Giao diện ----------

        void OnGUI()
        {
            Ui.Begin();
            if (_battle.Active) return; // Battle tự vẽ giao diện riêng.
            float w = Ui.Width;
            int xp = PlayerPrefs.GetInt("hero.xp", 0);
            Ui.Panel(new Rect(12, 12, 250, 70));
            Ui.Label(new Rect(26, 18, 230, 28), "★ Lv." + (1 + xp / 200) + " · " + xp + " XP", 18, Color.white, FontStyle.Bold);
            Ui.Bar(new Rect(26, 52, 220, 12), (xp % 200) / 200f, Ui.Gold);

            // Bảng nhiệm vụ của vùng.
            float qh = 44 + _gates.Count * 26;
            Ui.Panel(new Rect(w - 352, 12, 340, qh));
            Ui.Label(new Rect(w - 338, 18, 320, 28), "Kyoto · Bài " + LessonNumber, 18, Color.white, FontStyle.Bold);
            var next = NextGate();
            for (int i = 0; i < _gates.Count; i++)
            {
                var g = _gates[i];
                string mark = g.info.Cleared ? "✓" : g == next ? "▶" : "·";
                var col = g.info.Cleared ? Ui.Green : g == next ? Color.white : Ui.Muted;
                Ui.Label(new Rect(w - 338, 46 + i * 26, 320, 24), mark + " " + g.info.title + ": " + g.info.subtitle, 15, col);
            }

            if (_joyFinger >= 0 || _joyMouse)
            {
                Ui.Circle(_joyCenter, JoyRadius, new Color(1, 1, 1, 0.15f));
                Ui.Circle(_joyKnob, 30, new Color(1, 1, 1, 0.6f));
            }
            else Ui.Label(new Rect(20, Ui.VirtualHeight - 60, 360, 40), "Chạm và kéo bên trái để đi · tới gần quái để vào ải", 15, new Color(1, 1, 1, 0.85f));

            if (Ui.Button(new Rect(w - 152, Ui.VirtualHeight - 72, 140, 56), "Nhân vật", Ui.Purple, 18)) _customizing = !_customizing;
            if (_customizing) DrawCustomizer();

            if (Time.time < _toastUntil && !string.IsNullOrEmpty(_toast))
            {
                var r = new Rect(w / 2 - 260, 110, 520, 54);
                Ui.Panel(r, Ui.Gold);
                Ui.Label(r, _toast, 18, Color.white, FontStyle.Bold, TextAnchor.MiddleCenter);
            }
        }

        static readonly uint[] HairColors = { 0x3a2a5a, 0x2a2a3a, 0xf0b030, 0xf28ab8, 0x6ad8c8, 0xc8502a, 0xf2f2f2 };
        static readonly uint[] EyeColors = { 0x7a4ad8, 0x2a9ad8, 0xd84a7a, 0xd8402a, 0x2ab89a, 0x8a5a2a };
        static readonly uint[] TopColors = { 0xf6f6f6, 0x2c3e75, 0x4aa8e0, 0x3a3a52, 0xd8402e, 0x3a9a5a };
        static readonly string[] StyleNames = { "Ngắn", "Dựng", "Đuôi ngựa", "Hai bím", "Dài" };
        static readonly string[] OutfitNames = { "Đồng phục", "Yukata", "Ninja", "Samurai" };

        void DrawCustomizer()
        {
            float w = Ui.Width;
            var r = new Rect(w / 2 - 230, 110, 460, 420);
            Ui.Panel(r, Ui.Purple);
            Ui.Label(new Rect(r.x + 20, r.y + 12, 420, 34), "Tùy biến nhân vật", 22, Color.white, FontStyle.Bold);
            float y = r.y + 60;
            bool changed = false;
            changed |= Row(ref y, r, "Kiểu tóc", StyleNames[(int)_look.style], () => _look.style = (HairStyle)(((int)_look.style + 1) % 5));
            changed |= Row(ref y, r, "Màu tóc", "●", () => _look.hair = Cycle(HairColors, _look.hair), Hex(_look.hair));
            changed |= Row(ref y, r, "Màu mắt", "●", () => _look.eye = Cycle(EyeColors, _look.eye), Hex(_look.eye));
            changed |= Row(ref y, r, "Trang phục", OutfitNames[(int)_look.outfit], () => _look.outfit = (Outfit)(((int)_look.outfit + 1) % 4));
            changed |= Row(ref y, r, "Màu áo", "●", () => _look.top = Cycle(TopColors, _look.top), Hex(_look.top));
            changed |= Row(ref y, r, "Dáng", _look.girl ? "Nữ" : "Nam", () => _look.girl = !_look.girl);
            if (changed) { _look.Save(); SpawnHero(); }
            if (Ui.Button(new Rect(r.x + 130, r.yMax - 66, 200, 50), "Xong", Ui.Blue)) _customizing = false;
        }

        static uint Cycle(uint[] list, uint current)
        {
            int i = System.Array.IndexOf(list, current);
            return list[(i + 1) % list.Length];
        }

        static bool Row(ref float y, Rect r, string label, string value, System.Action next, Color? swatch = null)
        {
            Ui.Label(new Rect(r.x + 24, y, 160, 40), label, 18, Ui.Muted);
            bool hit = Ui.Button(new Rect(r.x + 190, y, 246, 40), value, Shapes.Hex(0x1b2c5c), 18);
            if (swatch.HasValue) Ui.Circle(new Vector2(r.x + 313, y + 20), 12, swatch.Value);
            y += 50;
            if (hit) next();
            return hit;
        }
    }
}
