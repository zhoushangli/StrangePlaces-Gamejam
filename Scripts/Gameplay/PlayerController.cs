using System.Collections.Generic;
using Godot;
using Protogame2D.Core;
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
    [Export(PropertyHint.Layers2DPhysics)] public uint platformLayers;
    [Export(PropertyHint.Layers2DPhysics)] public uint pushableBoxLayerMask = 64;

    [ExportGroup("References")]
    [Export] private AnimatedSprite2D _anim;
    [Export] private Godot.Collections.Array<AudioStream> _stepSounds;

    private readonly SimpleStateMachine<PlayerState> _fsm = new();
    private Vector2 _targetPosition;

    public override void _Ready()
    {
        _anim.FrameChanged += StepSound;


        GlobalPosition = GridUtil.SnapToGrid(GlobalPosition, GridSize);
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

                if (dir != Vector2.Zero && TryStartMove(dir))
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

                if (dir == Vector2.Zero || !TryStartMove(dir))
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
    private void StepSound()//每次Frame Change都会调用该函数。如果此时Frame是步伐帧，则播放声音
    {
        
        if (_anim.Animation == "walk")
        {
            if (_anim.Frame == 3)
            {
                Game.Instance.Get<AudioService>().PlaySfx(_stepSounds[0]);
            }
            else if (_anim.Frame == 7)
            {
                Game.Instance.Get<AudioService>().PlaySfx(_stepSounds[1]);
            }
        }


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
        var currentCell = GridUtil.SnapToGrid(GlobalPosition, GridSize);
        var targetPosition = GridUtil.SnapToGrid(currentCell + dir * GridSize, GridSize);

        if (TryFindPushableBoxAt(targetPosition, out var pushableBox))
        {
            if (!pushableBox.TryPush(dir, GridSize, platformLayers))
                return false;
        }
        else if (!GridUtil.HasOnlyPlatformAt(this, targetPosition, platformLayers))
        {
            return false;
        }

        _targetPosition = targetPosition;
        return true;
    }

    private bool TryFindPushableBoxAt(Vector2 targetPosition, out PushableBoxController pushableBox)
    {
        pushableBox = null;

        var space = GetWorld2D().DirectSpaceState;

        var circle = new CircleShape2D { Radius = 4f };
        var query = new PhysicsShapeQueryParameters2D
        {
            Shape = circle,
            Transform = new Transform2D(0, targetPosition),
            CollisionMask = pushableBoxLayerMask,
            CollideWithBodies = true,
            CollideWithAreas = false,
        };

        query.Exclude = new Godot.Collections.Array<Rid> { GetRid() };

        var hits = space.IntersectShape(query, 1);
        if (hits.Count == 0)
            return false;

        var collider = hits[0]["collider"].AsGodotObject();
        pushableBox = collider as PushableBoxController;
        return pushableBox != null;
    }
}
