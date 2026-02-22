using System.Threading.Tasks;
using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

namespace Protogame2D;

public enum DevMode
{
    None,
    UI,
    Game
}

/// <summary>
/// 全局启动器
/// </summary>
public partial class Boot : Node
{
    [Export] private DevMode _devMode = DevMode.UI;
    [Export] private PackedScene _devScene;

    public override void _Ready()
    {
        try
        {
            Game.Instance.RegisterNew<EventService>();
            Game.Instance.RegisterNew<GameStateService>();

            Game.Instance.RegisterFromScene<SceneService>("res://Prefabs/Services/SVC_SceneService.tscn");
            Game.Instance.RegisterFromScene<AudioService>("res://Prefabs/Services/SVC_AudioService.tscn");
            Game.Instance.RegisterFromScene<UIService>("res://Prefabs/Services/SVC_UIService.tscn");
            Game.Instance.RegisterFromScene<PostProcessService>("res://Prefabs/Services/SVC_PostProcessService.tscn");

        }
        catch (System.Exception ex)
        {
            GD.PushError($"[Boot] Init failed: {ex}");
            return;
        }

        CallDeferred(nameof(DeferredStartupRoute));
    }

    private async void DeferredStartupRoute()
    {
        try
        {
            switch (_devMode)
            {
                case DevMode.None:
                    break;
                case DevMode.UI:
                    Game.Instance.Get<GameStateService>().ChangeGameState(GameState.MainMenu);
                    Game.Instance.Get<UIService>().Open(_devScene);
                    return;
                case DevMode.Game:
                    Game.Instance.Get<GameStateService>().ChangeGameState(GameState.Game);
                    await Game.Instance.Get<LevelService>().LoadLevel(_devScene.ResourcePath);
                    return;
            }
        }
        catch (System.Exception ex)
        {
            GD.PushError($"[Boot] DeferredStartupRoute failed: {ex}");
            return;
        }

        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.MainMenu);
    }
}

