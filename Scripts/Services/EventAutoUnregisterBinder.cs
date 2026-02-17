using System;
using System.Collections.Generic;
using Godot;

namespace Protogame2D.Services;

public partial class EventAutoUnregisterBinder : Node
{
    private const string BinderName = "__EventAutoUnregisterBinder";

    private readonly List<Action> _actions = new();
    private bool _executed;

    public static EventAutoUnregisterBinder GetOrCreate(Node owner)
    {
        var existing = owner.GetNodeOrNull<EventAutoUnregisterBinder>(BinderName);
        if (existing != null) return existing;

        var binder = new EventAutoUnregisterBinder
        {
            Name = BinderName
        };
        owner.AddChild(binder);
        return binder;
    }

    public void Register(Action action)
    {
        if (action == null) return;
        if (_executed)
        {
            action();
            return;
        }

        _actions.Add(action);
    }

    public override void _EnterTree()
    {
        TreeExiting += ExecuteAndClear;
    }

    public override void _ExitTree()
    {
        TreeExiting -= ExecuteAndClear;
    }

    private void ExecuteAndClear()
    {
        if (_executed) return;
        _executed = true;

        for (var i = 0; i < _actions.Count; i++)
        {
            try
            {
                _actions[i]?.Invoke();
            }
            catch (Exception ex)
            {
                GD.PushError($"[EventService] Auto unregister action failed: {ex}");
            }
        }

        _actions.Clear();
    }
}
