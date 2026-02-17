using Godot;
using Protogame2D.Core;

namespace Protogame2D.Services;

/// <summary>
/// 玩家生成服务。在当前场景查找 SpawnPoints/Marker2D。
/// </summary>
public class PlayerService : IService
{
    public const string DefaultPlayerPath = "res://Scenes/Gameplay/PlayerPawn.tscn";
    public const string SpawnPointPath = "SpawnPoint";

    public Node2D CurrentPlayer { get; private set; }

    public void Init() { }

    public void Spawn()
    {
        Despawn();

        var packed = GD.Load<PackedScene>(DefaultPlayerPath);
        if (packed == null)
        {
            GD.PushError($"[PlayerService] Player scene not found: {DefaultPlayerPath}");
            return;
        }

        var tree = Engine.GetMainLoop() as SceneTree;
        var root = tree?.CurrentScene;
        if (root == null)
        {
            GD.PushError("[PlayerService] No current scene");
            return;
        }

        Vector2 pos = Vector2.Zero;
        var marker = root.GetNodeOrNull<Marker2D>(SpawnPointPath);
        if (marker != null)
        {
            pos = marker.GlobalPosition;
        }
        else
        {
            GD.PushWarning($"[PlayerService] Spawn point '{SpawnPointPath}' not found, using (0,0)");
        }

        var player = packed.Instantiate<Node2D>();
        player.GlobalPosition = pos;
        root.AddChild(player);
        CurrentPlayer = player;
    }

    public void Despawn()
    {
        if (CurrentPlayer != null)
        {
            CurrentPlayer.QueueFree();
            CurrentPlayer = null;
        }
    }

    public void Shutdown()
    {
        Despawn();
    }
}
