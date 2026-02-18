using Godot;

public partial class PlayerController : CharacterBody2D
{
    [Export] public int GridSize = 16;
    [Export] public float MoveSpeed = 120f;

    private bool _isMoving;
    private Vector2 _targetPosition;

    public override void _Ready()
    {
        GlobalPosition = SnapToGrid(GlobalPosition);
        _targetPosition = GlobalPosition;
    }

    public override void _PhysicsProcess(double delta)
    {
        if (_isMoving)
        {
            float step = MoveSpeed * (float)delta;
            GlobalPosition = GlobalPosition.MoveToward(_targetPosition, step);

            if (GlobalPosition.DistanceTo(_targetPosition) <= 0.01f)
            {
                GlobalPosition = _targetPosition;
                _isMoving = false;
            }

            return;
        }

        Vector2 dir = ReadInputDirection();
        if (dir != Vector2.Zero)
        {
            TryStartMove(dir);
        }
    }

    private Vector2 ReadInputDirection()
    {
        if (Input.IsActionPressed("move_up"))
            return Vector2.Up;
        if (Input.IsActionPressed("move_down"))
            return Vector2.Down;
        if (Input.IsActionPressed("move_left"))
            return Vector2.Left;
        if (Input.IsActionPressed("move_right"))
            return Vector2.Right;

        return Vector2.Zero;
    }

    private void TryStartMove(Vector2 dir)
    {
        if (IsBlocked(dir))
            return;

        _targetPosition = SnapToGrid(GlobalPosition + dir * GridSize);
        _isMoving = true;
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
