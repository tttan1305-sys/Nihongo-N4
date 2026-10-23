using System;
using System.Collections.Generic;
using UnityEngine;

namespace Nihongo
{
    /// Màn đánh quái: mỗi câu trả lời đúng là một đòn đánh, sai thì bị mất máu.
    /// Hết câu hỏi (quái hết máu) là qua ải; hết máu thì phải thử lại.
    public class Battle : MonoBehaviour
    {
        public Action<GateInfo, bool> OnFinished;
        public bool Active { get; private set; }

        GateInfo _gate;
        List<Quiz> _questions;
        int _index;
        int _enemyHp, _enemyMax;
        int _heroHp;
        int _picked = -1;
        float _shake;
        bool _done;
        bool _won;

        const int HeroMax = 5;

        public void Begin(GateInfo gate)
        {
            _gate = gate;
            _questions = new List<Quiz>(gate.questions);
            var rng = new System.Random();
            for (int i = _questions.Count - 1; i > 0; i--)
            {
                int j = rng.Next(i + 1);
                (_questions[i], _questions[j]) = (_questions[j], _questions[i]);
            }
            _index = 0;
            _enemyHp = _enemyMax = Mathf.Max(1, _questions.Count);
            _heroHp = gate.kind == GateKind.Boss ? HeroMax : HeroMax - 1;
            _picked = -1;
            _done = false;
            Active = true;
        }

        void Answer(int option)
        {
            if (_picked >= 0) return;
            _picked = option;
            if (option == _questions[_index].answer) _enemyHp--;
            else { _heroHp--; _shake = 0.4f; }
        }

        void Next()
        {
            _picked = -1;
            _index++;
            if (_enemyHp <= 0) { _done = true; _won = true; }
            else if (_heroHp <= 0) { _done = true; _won = false; }
            else if (_index >= _questions.Count) _index = 0; // trả lời sai thì câu hỏi quay vòng lại
        }

        void Finish()
        {
            Active = false;
            OnFinished?.Invoke(_gate, _won);
        }

        void Update()
        {
            if (_shake > 0) _shake -= Time.deltaTime;
        }

        void OnGUI()
        {
            if (!Active) return;
            Ui.Begin();
            float w = Ui.Width, h = Ui.VirtualHeight;
            var shake = _shake > 0 ? new Vector2(Mathf.Sin(Time.time * 80) * 6, 0) : Vector2.zero;
            GUI.color = new Color(1, 1, 1, 1);
            GUI.DrawTexture(new Rect(0, 0, w, h), Ui.Rounded(new Color(0.02f, 0.03f, 0.1f, 0.55f), new Color(0, 0, 0, 0), 2, 0));

            var enemyColor = _gate.kind == GateKind.Boss ? Ui.Red : _gate.kind == GateKind.Elite ? Ui.Purple : Ui.Blue;
            string enemyName = _gate.kind == GateKind.Boss ? "Đại quỷ Oni" : _gate.kind == GateKind.Elite ? "Kiếm sĩ Cáo" : "Tiểu quỷ Oni";

            // Thanh máu hai bên.
            Ui.Panel(new Rect(12 + shake.x, 12, 300, 64));
            Ui.Label(new Rect(26 + shake.x, 16, 280, 26), "♥ Bạn", 18, Color.white, FontStyle.Bold);
            Ui.Bar(new Rect(26 + shake.x, 48, 270, 14), _heroHp / (float)HeroMax, Ui.Green);
            Ui.Panel(new Rect(w - 372, 12, 360, 64), enemyColor);
            Ui.Label(new Rect(w - 358, 16, 340, 26), enemyName + " · " + _gate.title, 18, Color.white, FontStyle.Bold);
            Ui.Bar(new Rect(w - 358, 48, 330, 14), _enemyHp / (float)_enemyMax, Ui.Red);

            var panel = new Rect(w / 2 - 440, h - 400, 880, 384);
            Ui.Panel(panel, enemyColor);

            if (_done)
            {
                Ui.Label(new Rect(panel.x, panel.y + 60, panel.width, 60), _won ? "Chiến thắng!" : "Thua rồi…", 34, _won ? Ui.Gold : Ui.Red, FontStyle.Bold, TextAnchor.MiddleCenter);
                Ui.Label(new Rect(panel.x + 40, panel.y + 130, panel.width - 80, 80),
                    _won ? "Bạn đã qua " + _gate.title + " · " + _gate.subtitle : "Hãy xem lại phần ngữ pháp trong ứng dụng rồi quay lại thử nhé.",
                    20, Color.white, FontStyle.Normal, TextAnchor.MiddleCenter);
                if (Ui.Button(new Rect(panel.center.x - 120, panel.yMax - 90, 240, 60), _won ? "Tiếp tục" : "Rời ải", _won ? Ui.Green : Ui.Blue, 22)) Finish();
                return;
            }

            var q = _questions[_index];
            Ui.Label(new Rect(panel.x + 24, panel.y + 14, panel.width - 48, 26),
                _gate.subtitle + " · trả lời đúng để tấn công", 15, Ui.Muted);
            Ui.Label(new Rect(panel.x + 24, panel.y + 42, panel.width - 48, 90), Ruby.Rich(q.prompt, 17), 28, Color.white, FontStyle.Bold);

            for (int i = 0; i < q.options.Length && i < 4; i++)
            {
                var r = new Rect(panel.x + 24 + (i % 2) * 422, panel.y + 140 + (i / 2) * 70, 410, 60);
                Color fill = Shapes.Hex(0x1b2c5c);
                if (_picked >= 0 && i == q.answer) fill = Shapes.Hex(0x1f6a46);
                else if (_picked == i) fill = Shapes.Hex(0x7a2232);
                string letter = ((char)('A' + i)).ToString();
                if (Ui.Button(r, letter + ". " + Ruby.Rich(q.options[i], 15), fill, 21)) Answer(i);
            }

            if (_picked >= 0)
            {
                bool right = _picked == q.answer;
                string text = (right ? "Đúng! Quái mất máu. " : "Sai rồi, bạn bị đánh. ") + (q.explanationVi ?? "");
                Ui.Label(new Rect(panel.x + 24, panel.yMax - 92, panel.width - 250, 80), Ruby.Rich(text, 13), 16, right ? Ui.Green : Shapes.Hex(0xff9aa8));
                if (Ui.Button(new Rect(panel.xMax - 210, panel.yMax - 80, 186, 60), "Tiếp ▶", Ui.Blue, 22)) Next();
            }
        }
    }
}
