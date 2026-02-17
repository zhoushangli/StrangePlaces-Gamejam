using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

namespace Protogame2D;

/// <summary>
/// 启动器，负责初始化所有服务并加载主菜单场景。
/// </summary>
public partial class Boot : Node
{
    public override void _Ready()
    {
        try
        {
            RegisterAndInit<EventService>();
            RegisterAndInit<UIService>();
            RegisterAndInit<SceneService>();
            RegisterAndInit<GameStateService>();
            RegisterAndInit<PlayerService>();
        }
        catch (System.Exception ex)
        {
            GD.PushError($"[Boot] Init failed: {ex}");
        }

        CallDeferred(MethodName.DeferredGoMainMenu);
    }

    T RegisterAndInit<T>() where T : class, IService, new()
    {
        var service = new T();
        Game.Instance.Register<T>(service);
        service.Init();
        return service;
    }

    private void DeferredGoMainMenu()
    {
        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.MainMenu);
    }
}
