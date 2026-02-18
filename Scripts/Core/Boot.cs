using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

namespace Protogame2D;

/// <summary>
/// 全局启动器
/// </summary>
public partial class Boot : Node
{
    private const string DevModeKey = "strange_places/dev_mode";
    private const string DevStartSceneKey = "strange_places/dev_start_scene";

    public override void _Ready()
    {
        try
        {
            RegisterAndInit<EventService>();
            RegisterAndInit<UIService>();
            RegisterAndInit<SceneService>();
            RegisterAndInit<GameStateService>();
        }
        catch (System.Exception ex)
        {
            GD.PushError($"[Boot] Init failed: {ex}");
        }

        CallDeferred(nameof(DeferredStartupRoute));
    }

    T RegisterAndInit<T>() where T : class, IService, new()
    {
        var service = new T();
        Game.Instance.Register<T>(service);
        service.Init();
        return service;
    }

    private void DeferredStartupRoute()
    {
        var devMode = (bool)ProjectSettings.GetSetting(DevModeKey, false);
        if (devMode)
        {
            var devStartScene = ((string)ProjectSettings.GetSetting(DevStartSceneKey, "")).Trim();
            if (string.IsNullOrEmpty(devStartScene))
            {
                GD.PushError(
                    $"[Boot] Dev mode fallback to MainMenu: {DevModeKey}=true, {DevStartSceneKey} is empty.");
            }
            else if (!ResourceLoader.Exists(devStartScene))
            {
                GD.PushError(
                    $"[Boot] Dev mode fallback to MainMenu: {DevModeKey}=true, {DevStartSceneKey}='{devStartScene}' does not exist.");
            }
            else
            {
                Game.Instance.Get<SceneService>().ChangeScene(devStartScene);
                return;
            }
        }

        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.MainMenu);
    }
}

