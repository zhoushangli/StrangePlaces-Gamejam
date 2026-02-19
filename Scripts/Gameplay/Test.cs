using Godot;
using Protogame2D.Core;

public partial class Test : Node
{
    public override void _Ready()
    {
        var sfx = GD.Load<AudioStream>("res://Assets/Audio/Test.wav");
        Game.Instance.Get<AudioService>().PlaySfx(sfx);
    }
}