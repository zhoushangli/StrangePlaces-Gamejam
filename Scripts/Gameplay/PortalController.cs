using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

public partial class PortalController : Area2D
{
    [Export] private AnimatedSprite2D _anim;

    private bool _triggered;

    private const string LevelPrefix = "LVL_01_0";
    private const int MaxLevelInChapter = 5;

    public override void _Ready()
    {
        BodyEntered += OnBodyEntered;

        _anim.Play("idle");
    }

    private void OnBodyEntered(Node2D body)
    {
        if (_triggered)
            return;

        if (body is not PlayerController player)
            return;

        _triggered = true;
        _ = PlayPassAndTransit(player);
    }

    private async Task PlayPassAndTransit(PlayerController player)
    {
        var anim = player.Anim;

        player.EnterLevelPassState();

        await ToSignal(anim, AnimatedSprite2D.SignalName.AnimationFinished);

        var currentPath = GetTree()?.CurrentScene?.SceneFilePath ?? string.Empty;
        if (!TryBuildNextLevelPath(currentPath, out var nextLevelPath))
        {
            ReturnToMainMenu();
            return;
        }

        _ = Game.Instance.Get<LevelService>().LoadLevel(nextLevelPath);
    }

    private bool TryBuildNextLevelPath(string currentPath, out string nextPath)
    {
        nextPath = string.Empty;

        if (string.IsNullOrWhiteSpace(currentPath))
        {
            GD.PushError("[PortalController] Current scene path is empty.");
            return false;
        }

        var fileName = System.IO.Path.GetFileNameWithoutExtension(currentPath);
        var match = Regex.Match(fileName, @"^LVL_01_0(?<idx>[1-9]\d*)$");
        if (!match.Success)
        {
            GD.PushError($"[PortalController] Scene name is not in LVL_01_0X format: {fileName}");
            return false;
        }

        if (!int.TryParse(match.Groups["idx"].Value, out var currentIndex))
        {
            GD.PushError($"[PortalController] Failed to parse level index from scene name: {fileName}");
            return false;
        }

        if (currentIndex >= MaxLevelInChapter)
        {
            return false;
        }

        var nextIndex = currentIndex + 1;
        nextPath = $"res://Scenes/Gameplay/Levels/{LevelPrefix}{nextIndex}.tscn";
        return true;
    }

    private static void ReturnToMainMenu()
    {
        if (Game.Instance.TryGet<UIService>(out var uiService))
        {
            uiService.CloseTop();
        }

        Game.Instance.Get<GameStateService>().ChangeGameState(GameState.MainMenu);
    }
}
