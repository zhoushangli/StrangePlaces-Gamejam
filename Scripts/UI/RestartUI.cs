using Godot;
using Protogame2D.UI;
using System;

public partial class RestartUI : Control
{
	// Called when the node enters the scene tree for the first time.
	[Export] private TextureProgressBar _progressCircle;
	[Export] private TextureButton _restartButton;
	[Export] private float restartTime;
	[Export] private float resetSpeed;
	private double deltaTime;
	public override void _Ready()
	{
		_restartButton.Pressed += OnRestartPressed;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		deltaTime = delta;
		_progressCircle.Value -= delta * resetSpeed;
	}
	void OnRestartPressed()
	{
		_progressCircle.Value += deltaTime * (resetSpeed + 100.0f/restartTime);
	}

    


}
