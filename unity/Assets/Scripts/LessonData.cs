using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEngine;

namespace Nihongo
{
    // Cấu trúc giống file assets/lessons/<n>.json của ứng dụng Flutter.
    // Bản build chép các file đó vào Resources/Lessons nên bài học chỉ có một nguồn.

    [Serializable]
    public class Quiz
    {
        public string prompt;
        public string[] options;
        public int answer;
        public string explanationVi;
    }

    [Serializable]
    public class Grammar
    {
        public string id;
        public string pattern;
        public string meaningVi;
        public Quiz[] quiz;
    }

    [Serializable]
    public class Vocab
    {
        public string id;
        public string word;
        public string kana;
        public string hanViet;
        public string meaningVi;
    }

    [Serializable]
    public class Reading
    {
        public string titleJa;
        public Quiz[] questions;
    }

    [Serializable]
    public class Lesson
    {
        public int number;
        public string titleJa;
        public string titleVi;
        public Grammar[] grammar;
        public Vocab[] vocab;
        public Reading reading;

        public static Lesson Load(int number)
        {
            var asset = Resources.Load<TextAsset>("Lessons/" + number);
            return asset == null ? null : JsonUtility.FromJson<Lesson>(asset.text);
        }
    }

    public enum GateKind { Minion, Elite, Boss }

    /// Một cửa ải: tên, loại quái và bộ câu hỏi lấy từ bài học.
    public class GateInfo
    {
        public string id;
        public string title;
        public string subtitle;
        public GateKind kind;
        public List<Quiz> questions = new List<Quiz>();

        public bool Cleared => PlayerPrefs.GetInt("gate." + id, 0) == 1;

        public void MarkCleared()
        {
            PlayerPrefs.SetInt("gate." + id, 1);
            PlayerPrefs.Save();
        }

        /// Ải của một bài: mỗi mẫu ngữ pháp là một lính thường, từ vựng là lính
        /// tinh anh, đọc hiểu cộng ôn ngữ pháp là boss.
        public static List<GateInfo> ForLesson(Lesson lesson)
        {
            var gates = new List<GateInfo>();
            var rng = new System.Random(lesson.number);
            int i = 1;
            foreach (var g in lesson.grammar)
            {
                var gate = new GateInfo
                {
                    id = lesson.number + "-" + g.id,
                    title = "Ải " + lesson.number + "-" + i++,
                    subtitle = Ruby.Plain(g.pattern),
                    kind = GateKind.Minion,
                };
                gate.questions.AddRange(g.quiz);
                gates.Add(gate);
            }
            var elite = new GateInfo
            {
                id = lesson.number + "-vocab",
                title = "Tinh anh",
                subtitle = "Từ vựng bài " + lesson.number,
                kind = GateKind.Elite,
            };
            elite.questions.AddRange(VocabQuiz(lesson.vocab, 8, rng));
            gates.Add(elite);
            var boss = new GateInfo
            {
                id = lesson.number + "-boss",
                title = "Boss",
                subtitle = "Đọc hiểu bài " + lesson.number,
                kind = GateKind.Boss,
            };
            if (lesson.reading?.questions != null) boss.questions.AddRange(lesson.reading.questions);
            foreach (var g in lesson.grammar)
                if (g.quiz.Length > 0) boss.questions.Add(g.quiz[rng.Next(g.quiz.Length)]);
            gates.Add(boss);
            return gates;
        }

        /// Câu hỏi từ vựng: hiện từ, chọn nghĩa đúng trong 4 nghĩa.
        static IEnumerable<Quiz> VocabQuiz(Vocab[] words, int count, System.Random rng)
        {
            var pool = new List<Vocab>(words);
            Shuffle(pool, rng);
            for (int i = 0; i < Math.Min(count, pool.Count); i++)
            {
                var w = pool[i];
                var options = new List<string> { w.meaningVi };
                foreach (var o in pool)
                {
                    if (options.Count == 4) break;
                    if (o != w && !options.Contains(o.meaningVi)) options.Add(o.meaningVi);
                }
                Shuffle(options, rng);
                yield return new Quiz
                {
                    prompt = w.word + " là gì?",
                    options = options.ToArray(),
                    answer = options.IndexOf(w.meaningVi),
                    explanationVi = Ruby.Plain(w.word) + " (" + w.kana + ") · " + w.hanViet + " · " + w.meaningVi,
                };
            }
        }

        static void Shuffle<T>(IList<T> list, System.Random rng)
        {
            for (int i = list.Count - 1; i > 0; i--)
            {
                int j = rng.Next(i + 1);
                (list[i], list[j]) = (list[j], list[i]);
            }
        }
    }

    /// Furigana viết kiểu {漢字|かんじ}.
    public static class Ruby
    {
        static readonly Regex Pattern = new Regex(@"\{([^|{}]+)\|([^|{}]+)\}");

        public static string Plain(string text) => Pattern.Replace(text ?? "", "$1");

        /// Chữ Hán kèm cách đọc nhỏ phía sau: 漢字(かんじ). IMGUI không vẽ được furigana phía trên.
        public static string Rich(string text, int smallSize)
        {
            return Pattern.Replace(text ?? "", m => m.Groups[1].Value + "<size=" + smallSize + "><color=#9fb6ff>(" + m.Groups[2].Value + ")</color></size>");
        }
    }
}
