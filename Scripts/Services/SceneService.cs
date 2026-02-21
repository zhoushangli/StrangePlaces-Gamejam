using System.Threading.Tasks;
using Godot;
using Protogame2D.Core;
using Protogame2D.UI;

namespace Protogame2D.Services;

/// <summary>
/// 场景加载服务。
/// </summary>
public class SceneService : IService
{
    public const string MainMenuScenePath = "res://Scenes/Gameplay/SCN_MainMenu.tscn";
    public const string GameScenePath = "res://Scenes/Gameplay/SCN_Game.tscn";

    public void Init() { }

    public Task ChangeScene(string path)
    {
        var tree = Engine.GetMainLoop() as SceneTree;
        if (tree != null)
        {
            tree.ChangeSceneToFile(path);
            GD.Print($"[SceneService] Changed scene to {path}");
        }

        if (Game.Instance.TryGet<EventService>(out var evt))
            evt.Publish(new SceneLoadedEvent { Path = path });

        return Task.CompletedTask;
    }

    public void Shutdown() { }
}

public class SceneLoadedEvent
{
    public string Path { get; set; } = "";
}
