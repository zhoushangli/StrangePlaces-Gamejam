using Godot;
using Protogame2D.Core;
using System.Collections.Generic;

public partial class ButtonController : Area2D
{
    [Export] private DoorController _door;
    [Export] private AnimatedSprite2D _anim;

    private readonly HashSet<Node2D> _occupants = new();
    private bool _isActive;
    private bool _hasState;

    public override void _Ready()
    {
        BodyEntered += OnBodyEntered;
        BodyExited += OnBodyExited;

        SetActive(false);
    }

    private void OnBodyEntered(Node2D body)
    {
        if (!IsValidActivator(body))
            return;

        _occupants.Add(body);
        RefreshState();
    }

    private void OnBodyExited(Node2D body)
    {
        if (!IsValidActivator(body))
            return;

        _occupants.Remove(body);
        RefreshState();
    }

    private bool IsValidActivator(Node2D body)
    {
        return body is PlayerController || body is PushableBoxController;
    }

    private void RefreshState()
    {
        SetActive(_occupants.Count > 0);
    }

    private void SetActive(bool active)
    {
        if (_hasState && _isActive == active)
            return;

        _hasState = true;
        _isActive = active;

        _anim?.Play(active ? "active" : "deactive");
        _door?.SetActive(active);
    }
}
