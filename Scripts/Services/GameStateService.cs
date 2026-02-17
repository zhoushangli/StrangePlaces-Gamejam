using Godot;
using Protogame2D.Core;
using Protogame2D.UI;
using Protogame2D.Utils;

namespace Protogame2D.Services;

public enum GameState
{
    MainMenu,
    Play
}

public class GameStateService : IService
{
    private readonly SimpleStateMachine<GameState> _fsm = new();

    public GameState Current => _fsm.CurrentState;

    public void Init()
    {
        _fsm.AddState(
            GameState.MainMenu, 
            onEnter: () =>
            {
                EnterScene(SceneService.MainMenuScenePath);

                var uiService = Game.Instance.Get<UIService>();
                uiService.Open<MainMenuUI>();
            });
        
        _fsm.AddState(
            GameState.Play, 
            onEnter: () =>
            {
                EnterScene(SceneService.GameScenePath);
            }
        );
        
    }

    public bool ChangeGameState(GameState next)
    {
        var prev = _fsm.HasState ? _fsm.CurrentState : (GameState?)null;
        var changed = _fsm.ChangeState(next);
        if (!changed)
            return false;

        if (prev.HasValue && Game.Instance.TryGet<EventService>(out var evt))
        {
            evt.Publish(new GameStateChangedEvent
            {
                From = prev.Value,
                To = next
            });
        }

        return true;
    }

    public void Shutdown()
    {
    }

    private static void EnterScene(string path)
    {
        if (!Game.Instance.TryGet<SceneService>(out var scene))
        {
            GD.PushError("[GameStateService] SceneService is not available.");
            return;
        }

        scene.ChangeScene(path);
    }
}

public class GameStateChangedEvent
{
    public GameState From { get; set; }
    public GameState To { get; set; }
}
