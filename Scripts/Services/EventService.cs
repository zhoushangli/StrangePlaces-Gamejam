using System;
using System.Collections.Generic;
using Godot;
using Protogame2D.Core;

namespace Protogame2D.Services;

/// <summary>
/// 强类型事件总线。同一 handler 重复订阅只触发一次（使用 HashSet 去重）。
/// </summary>
public class EventService : IService
{
    private readonly Dictionary<Type, List<Delegate>> _handlers = new();

    public EventSubscription Subscribe<T>(Func<T, bool> handler)
    {
        if (handler == null)
            return EventSubscription.Empty;

        var t = typeof(T);
        if (!_handlers.TryGetValue(t, out var list))
        {
            list = new List<Delegate>();
            _handlers[t] = list;
        }

        foreach (var d in list)
        {
            if (ReferenceEquals(d.Target, handler.Target) && d.Method == handler.Method)
                return new EventSubscription(this, t, handler);
        }

        list.Add(handler);
        return new EventSubscription(this, t, handler);
    }

    public void Unsubscribe<T>(Func<T, bool> handler)
    {
        if (handler == null) return;

        RemoveHandler(typeof(T), handler);
    }

    public bool Publish<T>(T evt)
    {
        var t = typeof(T);
        if (!_handlers.TryGetValue(t, out var list) || list.Count == 0) return false;

        var snapshot = list.ToArray();

        foreach (var d in snapshot)
        {
            try
            {
                if (((Func<T, bool>)d)(evt))
                    return true;
            }
            catch (Exception ex)
            {
                Godot.GD.PushError($"[EventService] Handler error for {t.Name}: {ex}");
            }
        }

        return false;
    }

    internal void RemoveHandler(Type eventType, Delegate handler)
    {
        if (!_handlers.TryGetValue(eventType, out var list)) return;

        for (var i = list.Count - 1; i >= 0; i--)
        {
            var d = list[i];
            if (ReferenceEquals(d.Target, handler.Target) && d.Method == handler.Method)
                list.RemoveAt(i);
        }

        if (list.Count == 0) _handlers.Remove(eventType);
    }

    public void Init() { }

    public void Shutdown()
    {
        _handlers.Clear();
    }
}

public sealed class EventSubscription
{
    public static readonly EventSubscription Empty = new(null, null, null);

    private readonly EventService _eventService;
    private readonly Type _eventType;
    private readonly Delegate _handler;
    private readonly HashSet<ulong> _boundOwnerIds = new();
    private bool _isDisposed;

    internal EventSubscription(EventService eventService, Type eventType, Delegate handler)
    {
        _eventService = eventService;
        _eventType = eventType;
        _handler = handler;
    }

    public void Unregister()
    {
        if (_isDisposed) return;

        _isDisposed = true;
        if (_eventService == null || _eventType == null || _handler == null) return;
        _eventService.RemoveHandler(_eventType, _handler);
    }

    public EventSubscription UnregisterOnDestroy(Node owner)
    {
        if (_isDisposed) return this;

        if (owner == null)
        {
            GD.PushWarning("[EventService] UnregisterOnDestroy called with null owner.");
            return this;
        }

        var ownerId = owner.GetInstanceId();
        if (!_boundOwnerIds.Add(ownerId)) return this;

        if (!owner.IsInsideTree() || owner.IsQueuedForDeletion())
        {
            Unregister();
            return this;
        }

        var binder = EventAutoUnregisterBinder.GetOrCreate(owner);
        binder.Register(Unregister);
        return this;
    }
}
