using Godot;

public partial class QuantumObserver : Area2D
{
    [Export] private PointLight2D _light;

    public bool IsObserving { get; private set; }

    public override void _Ready()
    {
        if (QuantumManager.Instance != null)
        {
            QuantumManager.Instance.RegisterObserver(this);
        }
        else
        {
            GD.PushWarning($"[QuantumObserver] QuantumManager not ready when '{Name}' entered tree.");
        }

        IsObserving = false;
        _light.Visible = IsObserving;
    }

    public override void _ExitTree()
    {
        QuantumManager.Instance?.UnregisterObserver(this);
    }

    public override void _Process(double delta)
    {
        if (Input.IsActionJustPressed("test"))
        {
            IsObserving = !IsObserving;
            _light.Visible = IsObserving;
        }
    }

    public bool CanObserve(QuantumItem item)
    {
        if (!IsObserving || item == null)
            return false;
        
        return OverlapsBody(item);
    }
}
