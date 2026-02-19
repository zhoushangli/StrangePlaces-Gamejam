using Godot;
using Protogame2D.UI;
using System;

public partial class LoadingUI : UIBase
{
	// Called when the node enters the scene tree for the first time.
	[Export] TextureProgressBar _bar;
	public float percentage;
	[Export] float _fillingSpeed;

	public override void _Ready()
	{
	}
	public override void OnOpen(object args)
    {
        
    }
	public void ChangePercent(float targetVal)
	{
		percentage = targetVal;
	}
    public override void OnClose()
    {
        
    }
	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if(_bar.Value < percentage)
		{
			_bar.Value += delta * _fillingSpeed;
		}
		else if(_bar.Value >= percentage)
		{
			_bar.Value -= delta * _fillingSpeed;
		}
		
	}

    

}
