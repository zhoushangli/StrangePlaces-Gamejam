using Godot;
using Protogame2D.Core;
namespace Protogame2D.Services;

public partial class LevelService : Node, IService
{
    public void Init()
    {
        
    }

    public void Shutdown()
    {
        
    }

    public void LoadLevel(PackedScene devScene)
    {
        var path = devScene.ResourcePath;
        Game.Instance.Get<SceneService>().ChangeScene(path);

        var nodes = GetTree().GetNodesInGroup("PlayerSpawnPoint");
        if (nodes.Count > 0)
        {
            var spawnPoint = nodes[0] as Node2D;
            if (spawnPoint != null)
            {
                
            }
        }
        else
        {
            GD.PrintErr($"[LevelService] No PlayerSpawnPoint found in scene {path}");
        }
    }
}