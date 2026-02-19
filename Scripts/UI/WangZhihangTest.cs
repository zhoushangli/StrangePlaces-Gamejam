using Godot;
using Protogame2D.Core;
using Protogame2D.Services;
using Protogame2D.UI;
using System;

public partial class WangZhihangTest : Node2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		Game.Instance.Get<UIService>().Open<PauseUI>();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
