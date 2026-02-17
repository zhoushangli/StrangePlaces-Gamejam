using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

namespace Protogame2D.UI;

/// <summary>
/// 暂停菜单，由 UIService.Open&lt;UI_Pause&gt; 打开。
/// </summary>
public partial class UI_Pause : UIBase
{
    private Button _resumeButton;
    private Button _backButton;

    public override void _Ready()
    {
        _resumeButton = GetNode<Button>("CenterContainer/VBoxContainer/ResumeButton");
        _backButton = GetNode<Button>("CenterContainer/VBoxContainer/BackToMenuButton");

        _resumeButton.Pressed += OnResumePressed;
        _backButton.Pressed += OnBackPressed;
    }

    private void OnResumePressed()
    {
        QueueFree();
    }

    private void OnBackPressed()
    {
        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.MainMenu);
    }
}
