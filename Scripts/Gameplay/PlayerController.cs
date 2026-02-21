using Godot;
using Protogame2D.Utils;

public partial class PlayerController : CharacterBody2D
{
    private enum PlayerState
    {
        Idle,
        Moving
    }

    [ExportGroup("Configuration")]
    [Export] public int GridSize = 16;
    [Export] public float MoveSpeed = 120f;

    [ExportGroup("References")]
    [Export] private AnimatedSprite2D _anim;

    private readonly SimpleStateMachine<PlayerState> _fsm = new();
    private Vector2 _targetPosition;

    public override void _Ready()
    {
        GlobalPosition = SnapToGrid(GlobalPosition);
        _targetPosition = GlobalPosition;

        _fsm.AddState(
            PlayerState.Idle,
            onEnter: () =>
            {
                _anim.Play("idle");
            },
            onUpdate: _ =>
            {
                Vector2 dir = ReadInputDirection();
                FlipSprite(dir);

                if (dir != Vector2.Zero && TryStartMove(dir) && !IsBlocked(dir))
                {
                    _fsm.ChangeState(PlayerState.Moving);
                }
            });

        _fsm.AddState(
            PlayerState.Moving,
            onEnter: () =>
            {
                _anim.Play("walk");
            },
            onUpdate: delta =>
            {
                float step = MoveSpeed * delta;
                GlobalPosition = GlobalPosition.MoveToward(_targetPosition, step);

                if (GlobalPosition.DistanceTo(_targetPosition) > 0.01f)
                    return;

                GlobalPosition = _targetPosition;

                Vector2 dir = ReadInputDirection();
                FlipSprite(dir);

                if (dir == Vector2.Zero || !TryStartMove(dir) || IsBlocked(dir))
                {
                    _fsm.ChangeState(PlayerState.Idle);
                }
            });

        _fsm.Init(PlayerState.Idle);
    }

    public override void _PhysicsProcess(double delta)
    {
        _fsm.Update((float)delta);
    }

    private Vector2 ReadInputDirection()
    {
        if (Input.IsActionPressed("move_up"))
        {
            return Vector2.Up;
        }
        if (Input.IsActionPressed("move_down"))
        {
            return Vector2.Down;
        }
        if (Input.IsActionPressed("move_left"))
        {
            return Vector2.Left;
        }
        if (Input.IsActionPressed("move_right"))
        {
            return Vector2.Right;
        }
        return Vector2.Zero;
    }

    private void FlipSprite(Vector2 dir)
    {
        if (dir == Vector2.Left)
        {
            _anim.FlipH = true;
        }
        else if (dir == Vector2.Right)
        {
            _anim.FlipH = false;
        }
    }

    private bool TryStartMove(Vector2 dir)
    {
        if (IsBlocked(dir))
            return false;

        _targetPosition = SnapToGrid(GlobalPosition + dir * GridSize);
        return true;
    }

    private bool IsBlocked(Vector2 dir)
    {
        var spaceState = GetWorld2D().DirectSpaceState;

        Vector2 from = GlobalPosition + dir * 0.1f;
        Vector2 to = GlobalPosition + dir * GridSize;
        var query = PhysicsRayQueryParameters2D.Create(from, to);
        query.CollideWithAreas = false;
        query.CollideWithBodies = true;
        query.Exclude = new Godot.Collections.Array<Rid> { GetRid() };

        var result = spaceState.IntersectRay(query);
        return result.Count > 0;
    }

    private Vector2 SnapToGrid(Vector2 pos)
    {
        float x = (Mathf.Floor(pos.X / GridSize) + 0.5f) * GridSize;
        float y = (Mathf.Floor(pos.Y / GridSize) + 0.5f) * GridSize;
        return new Vector2(x, y);
    }
}
