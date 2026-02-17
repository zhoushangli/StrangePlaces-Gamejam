using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

namespace Protogame2D.UI;

/// <summary>
/// 主菜单场景脚本。此场景作为独立场景加载，非通过 UIService.Open。
/// </summary>
public partial class MainMenuUI : UIBase
{
    [Export] private Button _startButton;
    [Export] private Button _quitButton;

    public override void OnOpen(object args)
    {
        _startButton.Pressed += OnStartPressed;
        _quitButton.Pressed += OnQuitPressed;
    }

    public override void OnClose()
    {
        
    }

    private void OnStartPressed()
    {
        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.Play);
    }

    private void OnQuitPressed()
    {
        GetTree().Quit();
    }
}
