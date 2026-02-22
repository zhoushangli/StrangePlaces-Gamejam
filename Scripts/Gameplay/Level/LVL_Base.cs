using Godot;
using Protogame2D.Core;
using Protogame2D.Services;
using Protogame2D.UI;

public partial class LVL_Base : Node2D
{
    public override void _Process(double delta)
    {
        base._Process(delta);
        if (Input.IsActionJustPressed("pause"))
        {
            Game.Instance.Get<UIService>().Open<PauseUI>();
        }
        
    }

}