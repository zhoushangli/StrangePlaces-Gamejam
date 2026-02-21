using Godot;
using Protogame2D.Core;
using System.Threading.Tasks;

namespace Protogame2D.Services;

/// <summary>
/// 场景加载服务。
/// </summary>
public partial class SceneService : Node, IService
{
    public const string MainMenuScenePath = "res://Scenes/Gameplay/SCN_MainMenu.tscn";
    public const string GameScenePath = "res://Scenes/Gameplay/SCN_Game.tscn";

    public void Init() { }

    public async Task<Node> ChangeScene(string path)
    {
        var tree = Engine.GetMainLoop() as SceneTree;
        
        tree.ChangeSceneToFile(path);

        GD.Print($"[SceneService] Changed scene to {path}");

        // 等一帧
        await ToSignal(tree, SceneTree.SignalName.SceneChanged);

        if (Game.Instance.TryGet<EventService>(out var evt))
            evt.Publish(new SceneLoadedEvent { Path = path });

        return tree.CurrentScene;
    }

    public void Shutdown() { }
}

public class SceneLoadedEvent
{
    public string Path { get; set; } = "";
}
