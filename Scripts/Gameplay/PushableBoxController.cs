using Godot;
using Protogame2D.Core;
using Protogame2D.Utils;

public partial class PushableBoxController : StaticBody2D
{
    [ExportGroup("Movement")]
    [Export] public float PushMoveSpeed = 120f;

    private Vector2 _targetPosition;
    private bool _isMoving;

    public override void _Ready()
    {
        GlobalPosition = GridUtil.SnapToGrid(GlobalPosition, 16);
        _targetPosition = GlobalPosition;
    }

    public override void _PhysicsProcess(double delta)
    {
        if (!_isMoving)
            return;

        float step = PushMoveSpeed * (float)delta;
        GlobalPosition = GlobalPosition.MoveToward(_targetPosition, step);

        if (GlobalPosition.DistanceTo(_targetPosition) > 0.01f)
            return;

        GlobalPosition = _targetPosition;
        _isMoving = false;
    }

    public bool TryPush(Vector2 dir, int gridSize, uint platformLayerMask)
    {
        if (_isMoving)
            return false;

        var currentCell = GridUtil.SnapToGrid(GlobalPosition, gridSize);
        var nextCell = GridUtil.SnapToGrid(currentCell + dir * gridSize, gridSize);

        if (!GridUtil.HasOnlyPlatformAt(this, nextCell, platformLayerMask))
            return false;

        if (HasOtherBoxAt(nextCell))
            return false;

        GlobalPosition = currentCell;
        _targetPosition = nextCell;
        _isMoving = true;
        return true;
    }

    private bool HasOtherBoxAt(Vector2 position)
    {
        var space = GetWorld2D().DirectSpaceState;
        var circle = new CircleShape2D { Radius = 4f };

        var query = new PhysicsShapeQueryParameters2D
        {
            Shape = circle,
            Transform = new Transform2D(0, position),
            CollisionMask = CollisionLayer,
            CollideWithBodies = true,
            CollideWithAreas = false,
        };

        query.Exclude = new Godot.Collections.Array<Rid> { GetRid() };

        var hits = space.IntersectShape(query, 2);
        return hits.Count > 0;
    }
}
