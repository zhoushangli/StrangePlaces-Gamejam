using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

namespace Protogame2D.UI;

/// <summary>
/// 主菜单场景脚本。此场景作为独立场景加载，非通过 UIService.Open。
/// </summary>
public partial class MainMenuUI : UIBase
{
    [Export] private TextureButton _startButton;
    [Export] private TextureButton _quitButton;
    [Export] private TextureButton _pressStartButton;
    [Export] private NinePatchRect _StartPlate;
    [Export] float sparkSpeed;
    float increasing;
    public override void OnOpen(object args)
    {

        increasing = 1.0f;
        _startButton.Pressed += OnStartPressed;
        _quitButton.Pressed += OnQuitPressed;
        _pressStartButton.Pressed += OnPressStartPressed;
        _StartPlate.Visible = false;
    }
    public override void _Process(double delta)
    {
        base._Process(delta);
        Spark(delta);
    }
    void Spark(double delta)
    {
        float oldAlpha = _pressStartButton.Modulate.A;
        if(oldAlpha >= 1.0f)
        {
            increasing = -1.0f;
        }
        else if(oldAlpha <= 0.0f)
        {
            increasing = 1.0f;
        }
        oldAlpha += increasing * sparkSpeed * (float)delta;
        _pressStartButton.Modulate = new Color(1,1,1,oldAlpha);
    }


    public override void OnClose()
    {
        
    }

    private void OnStartPressed()
    {
        Game.Instance.Get<UIService>().CloseTop();
        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.Play);
    }

    private void OnQuitPressed()
    {
        GetTree().Quit();
    }
    private void OnPressStartPressed()
    {
        _pressStartButton.Visible = false;
        _StartPlate.Visible=true;
    }
}
