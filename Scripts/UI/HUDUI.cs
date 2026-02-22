using Godot;
using Protogame2D.UI;
using System;
using System.ComponentModel.DataAnnotations;

public partial class HUDUI : UIBase
{
	// Called when the node enters the scene tree for the first time.
	[Export] private TextureProgressBar _progressCircle;
	[Export] private TextureButton _restartButton;
	[Export] private double restartTime;
	[Export] private double resetSpeed;
	[Export] bool pressing;
	private double deltaTime;
	public override void _Ready()
	{
		
	}
	public override void OnOpen(object args)
    {
		pressing = false;
		_restartButton.ButtonDown += OnRestartPressed;
		_restartButton.ButtonUp += OnRestartReleased;
    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		// deltaTime = delta;
		// _progressCircle.Value -= delta * resetSpeed;
		// _progressCircle.Value = Math.Max(_progressCircle.Value, 0);
		
	}
    public override void _PhysicsProcess(double delta)
    {
        base._PhysicsProcess(delta);
		if (pressing)
		{
			
			_progressCircle.Value += delta * 100.0f/restartTime;
		}
		else
		{
			_progressCircle.Value -= delta * resetSpeed;
			if(_progressCircle.Value < 0)
			{
				_progressCircle.Value = 0;
			}
		}
    }

	void OnRestartPressed()
	{
		GD.Print("Pressing restart.");
		// _progressCircle.Value += deltaTime * (resetSpeed + 100.0f/restartTime);
		pressing = true;
	}
	void OnRestartReleased()
	{
		GD.Print("Pressing release.");
		// _progressCircle.Value += deltaTime * (resetSpeed + 100.0f/restartTime);
		pressing = false;
	}
    

    public override void OnClose()
    {

    }

}
