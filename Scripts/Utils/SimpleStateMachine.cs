using System;
using System.Collections.Generic;
using Godot;

namespace Protogame2D.Utils;

public class SimpleStateMachine<TState>
{
    private sealed class StateHooks
    {
        public Action OnEnter;
        public Action OnExit;
    }

    private readonly Dictionary<TState, StateHooks> _states = new();

    public bool HasState { get; private set; }
    public TState CurrentState { get; private set; }

    public void AddState(TState state, Action onEnter = null, Action onExit = null)
    {
        _states[state] = new StateHooks
        {
            OnEnter = onEnter,
            OnExit = onExit
        };
    }

    public bool ChangeState(TState nextState)
    {
        if (!_states.TryGetValue(nextState, out var next))
        {
            GD.PushError($"[SimpleStateMachine] State not configured: {nextState}");
            return false;
        }

        if (!HasState)
        {
            CurrentState = nextState;
            HasState = true;
            next.OnEnter?.Invoke();
            return true;
        }

        if (EqualityComparer<TState>.Default.Equals(CurrentState, nextState))
            return false;

        var prevState = CurrentState;
        if (_states.TryGetValue(prevState, out var prev))
            prev.OnExit?.Invoke();

        CurrentState = nextState;
        next.OnEnter?.Invoke();
        return true;
    }
}
