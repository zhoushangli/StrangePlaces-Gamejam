using Godot;
using Protogame2D.Core;
using Protogame2D.UI;
using Protogame2D.Utils;

namespace Protogame2D.Services;

public enum GameState
{
    Boot,
    MainMenu,
    Game
}

public class GameStateService : IService
{
    private readonly SimpleStateMachine<GameState> _fsm = new();

    public GameState Current => _fsm.CurrentState;

    public void Init()
    {
        _fsm.AddState(
            GameState.Boot
        );

        _fsm.AddState(
            GameState.MainMenu, 
            onEnter: () =>
            {
                EnterScene(SceneService.MainMenuScenePath);

                var uiService = Game.Instance.Get<UIService>();
                uiService.Open<MainMenuUI>();
            }
        );
        
        _fsm.AddState(
            GameState.Game, 
            onEnter: () =>
            {
                Game.Instance.RegisterFromScene<LevelService>("res://Prefabs/Services/SVC_LevelService.tscn");
                Game.Instance.RegisterFromScene<QuantumService>("res://Prefabs/Services/SVC_QuantumService.tscn");

                var levelService = Game.Instance.Get<LevelService>();
                
            },
            onExit: () =>
            {
                Game.Instance.Unregister<QuantumService>();
                Game.Instance.Unregister<LevelService>();
            }
        );
        
        _fsm.Init(GameState.Boot);
    }

    public bool ChangeGameState(GameState next)
    {
        var prev = _fsm.CurrentState;
        var changed = _fsm.ChangeState(next);
        if (!changed)
            return false;

        if (Game.Instance.TryGet<EventService>(out var evt))
        {
            evt.Publish(new GameStateChangedEvent
            {
                From = prev,
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
