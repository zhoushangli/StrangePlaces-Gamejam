using Godot;
using Protogame2D.Core;

public partial class LVL_01_05 : LVL_Base
{
    [Export] private QuantumObserver _observer;
    [Export] private float _observerToggleInterval = 2f;

    public override void _Ready()
    {
        var tween = CreateTween().SetLoops(); // 无限循环

        tween.TweenCallback(Callable.From(() => _observer.ToggleObserving()));
        tween.TweenInterval(_observerToggleInterval);
    }
}