using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace Nihongo.EditorTools
{
    /// Build không cần mở Unity: chép bài học từ ứng dụng Flutter, tạo cảnh chính
    /// có đối tượng Game, đặt thông tin ứng dụng rồi build APK.
    /// Gọi bằng: -executeMethod Nihongo.EditorTools.BuildScript.BuildAndroid
    public static class BuildScript
    {
        const string ScenePath = "Assets/Scenes/Main.unity";

        [MenuItem("Nihongo/Chuẩn bị cảnh và bài học")]
        public static void Prepare()
        {
            CopyLessons();
            Directory.CreateDirectory("Assets/Scenes");
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            new GameObject("Game").AddComponent<Game>();
            EditorSceneManager.SaveScene(scene, ScenePath);
            EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene(ScenePath, true) };
            AssetDatabase.Refresh();
        }

        /// Bài học nằm ở assets/lessons của repo (thư mục cha của unity/).
        static void CopyLessons()
        {
            var src = Path.GetFullPath(Path.Combine(Application.dataPath, "..", "..", "assets", "lessons"));
            var dst = Path.Combine(Application.dataPath, "Resources", "Lessons");
            Directory.CreateDirectory(dst);
            foreach (var f in Directory.GetFiles(src, "*.json"))
                File.Copy(f, Path.Combine(dst, Path.GetFileName(f)), true);
            AssetDatabase.Refresh();
            Debug.Log("Đã chép bài học từ " + src);
        }

        static string Arg(string name, string fallback)
        {
            var args = Environment.GetCommandLineArgs();
            int i = Array.IndexOf(args, name);
            return i >= 0 && i + 1 < args.Length ? args[i + 1] : fallback;
        }

        public static void BuildAndroid()
        {
            Prepare();
            PlayerSettings.companyName = "Nihongo N4";
            PlayerSettings.productName = "Nihongo Phiêu Lưu";
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, "com.tttan.nihongo.adventure");
            PlayerSettings.bundleVersion = Arg("-buildVersion", "0.1.0");
            if (int.TryParse(Arg("-androidVersionCode", "1"), out var code)) PlayerSettings.Android.bundleVersionCode = code;
            PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel24;
            PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64 | AndroidArchitecture.ARMv7;
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);
            PlayerSettings.defaultInterfaceOrientation = UIOrientation.LandscapeLeft;
            EditorUserBuildSettings.buildAppBundle = false;

            var path = Arg("-customBuildPath", "Builds/Android/nihongo-phieu-luu.apk");
            if (!path.EndsWith(".apk")) path = Path.Combine(path, "nihongo-phieu-luu.apk");
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions
            {
                scenes = EditorBuildSettings.scenes.Where(s => s.enabled).Select(s => s.path).ToArray(),
                locationPathName = path,
                target = BuildTarget.Android,
                options = BuildOptions.None,
            });
            Debug.Log("Kết quả build: " + report.summary.result + " → " + path);
            if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded) EditorApplication.Exit(1);
        }
    }
}
