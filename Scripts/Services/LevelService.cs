// LevelService.cs
using System.Threading.Tasks;
using Godot;
using Protogame2D.Core;

namespace Protogame2D.Services;

public partial class LevelService : Node, IService
{
    public void Init() { }

    public void Shutdown() { }

    public async Task LoadLevel(string path)
    {
        var packedScene = GD.Load<PackedScene>(path);
        if (packedScene == null)
        {
            GD.PushError($"[LevelService] Failed to load level scene at path: {path}");
            return;
        }

        await LoadLevel(packedScene);
    }

    public async Task LoadLevel(PackedScene devScene)
    {
        var path = devScene.ResourcePath;

        var rootNode = await Game.Instance.Get<SceneService>().ChangeScene(path);

        var spawnPoint = GetTree().GetFirstNodeInGroup("PlayerSpawnPoint") as Node2D;
        if (spawnPoint != null)
        {
            var packedPlayerScene = GD.Load<PackedScene>("res://Prefabs/Character/A_Player.tscn");
            var playerInstance = packedPlayerScene.Instantiate<Node2D>();
            playerInstance.GlobalPosition = spawnPoint.GlobalPosition;
            rootNode.AddChild(playerInstance);
        }
        else
        {
            GD.PushError($"[LevelService] No PlayerSpawnPoint found in scene {path}");
        }

        if (Game.Instance.TryGet<EventService>(out var evt))
        {
            evt.Publish(new LevelReadyEvent
            {
                Path = path,
                RootNode = rootNode
            });
            GD.Print($"[LevelService] LevelReady published: {path}");
        }
        else
        {
            GD.PushWarning("[LevelService] EventService not available, LevelReadyEvent was not published.");
        }
    }
}

public class LevelReadyEvent
{
    public string Path { get; set; } = "";
    public Node RootNode { get; set; }
}
