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
    [Export] private TextureButton _levelButton;
    [Export] private NinePatchRect _startPlate;
    [Export] float sparkSpeed;
    [Export] private AudioStream _hoverSound; 
    [Export] private AudioStream _confirmSound; 
    [Export] private AudioStream _bgm;
    [Export] private PackedScene _firstLevel;
    bool startPressed;
    float increasing;
    public override void OnOpen(object args)
    {
        startPressed = false;
        Game.Instance.Get<AudioService>().PlayBgm(_bgm);
        increasing = 1.0f;
        _startButton.Pressed += OnStartPressed;
        _quitButton.Pressed += OnQuitPressed;
        _pressStartButton.Pressed += OnPressStartPressed;
        _levelButton.Pressed += OnLevelsPressed;

        _startButton.Pressed += OnConfirmed;
        _quitButton.Pressed += OnConfirmed;
        _pressStartButton.Pressed += OnConfirmed;
        _levelButton.Pressed += OnConfirmed;

        _startButton.MouseEntered += OnHovered;
        _quitButton.MouseEntered += OnHovered;
        _levelButton.MouseEntered += OnHovered;



        _startPlate.Visible = false;
    }
    public override void _Process(double delta)
    {
        base._Process(delta);
        Spark(delta);
        
    }
    void OnHovered()
    {
        Game.Instance.Get<AudioService>().PlaySfx(_hoverSound);
    }
    void OnConfirmed()
    {
        Game.Instance.Get<AudioService>().PlaySfx(_confirmSound);
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
        if (!startPressed)
        {
            startPressed = true;
            
            Game.Instance.Get<GameStateService>().ChangeGameState(GameState.Game);
            _= Game.Instance.Get<LevelService>().LoadLevel(_firstLevel);

        }
        
    }

    private void OnQuitPressed()
    {
        GetTree().Quit();
    }
    private void OnLevelsPressed()
    {
        Game.Instance.Get<UIService>().CloseTop();
        Game.Instance.Get<UIService>().Open<LevelsUI>();
    }
    private void OnPressStartPressed()
    {
        _pressStartButton.Visible = false;
        _startPlate.Visible=true;
    }
}
