using System.Diagnostics.CodeAnalysis;
using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

namespace Protogame2D.UI;

/// <summary>
/// 暂停菜单，由 UIService.Open&lt;UI_Pause&gt; 打开。
/// </summary>
public partial class PauseUI : UIBase
{
    [Export]
    private TextureButton _resumeButton;
    [Export]
    private TextureButton _backButton;
    [Export]
    private TextureButton _exitButton;
    [Export]
    private AudioStream _focusSound;
    [Export] private AudioStream _confirmSound;
    public override void _Ready()
    {
        // _resumeButton = GetNode<Button>("CenterContainer/VBoxContainer/ResumeButton");
        // _backButton = GetNode<Button>("CenterContainer/VBoxContainer/BackToMenuButton");

        // _resumeButton.Pressed += OnResumePressed;
        // _backButton.Pressed += OnBackPressed;
        // _quitButton.Pressed += OnQuitPressed;
    }
    public override void OnOpen(object args)
    {
        //我把该函数功能理解为_Ready函数。_xxxButton在inspector中赋值

        _resumeButton.Pressed += OnResumePressed;
        _backButton.Pressed += OnBackPressed;
        _exitButton.Pressed += OnQuitPressed;

        _resumeButton.MouseEntered += OnHovered;
        _backButton.MouseEntered += OnHovered;
        _exitButton.MouseEntered += OnHovered;
    }

    void OnHovered()
    {
        Game.Instance.Get<AudioService>().PlaySfx(_focusSound);
    }

    private void OnResumePressed()
    {
        // QueueFree();
        Game.Instance.Get<AudioService>().PlaySfx(_confirmSound);
        Game.Instance.Get<UIService>().CloseTop();
    }

    private void OnBackPressed()
    {
        Game.Instance.Get<AudioService>().PlaySfx(_confirmSound);
        Game.Instance.Get<UIService>().CloseTop();
        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.MainMenu);
    }
    private void OnQuitPressed()
    {
        
        Game.Instance.Get<AudioService>().PlaySfx(_confirmSound);
        //关闭游戏
        GetTree().Quit();
    }

    

    public override void OnClose()
    {
        //TODO
    }

}
