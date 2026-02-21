using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

public partial class ChangeGameState : Node
{
    [Export] public GameState TargetState { get; set; } = GameState.MainMenu;

    public override void _Ready()
    {
        Game.Instance.Get<GameStateService>().ChangeGameState(TargetState);
    }
}