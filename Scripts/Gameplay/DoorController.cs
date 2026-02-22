using Godot;
using Protogame2D.Core;

public partial class DoorController : StaticBody2D
{
    [Export] private AnimatedSprite2D _anim;
    [Export] private CollisionShape2D _collisionShape;

    private bool _isActive;
    private bool _hasState;

    public override void _Ready()
    {
        SetActive(false);
    }

    public void SetActive(bool active)
    {
        if (_hasState && _isActive == active)
            return;

        _hasState = true;
        _isActive = active;

        _anim?.Play(active ? "active" : "deactive");
        if (_collisionShape != null)
        {
            _collisionShape.CallDeferred("set_disabled", active);
        }
    }
}
