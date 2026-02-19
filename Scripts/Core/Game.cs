using System;
using System.Collections.Generic;
using Godot;

namespace Protogame2D.Core;

/// <summary>
/// 使用 AutoLoad 实现的全局服务容器，负责管理游戏中的各种服务实例。
/// </summary>
public partial class Game : Node
{
    private static Game _instance;

    public static Game Instance
    {
        get
        {
            if (_instance == null)
            {
                GD.PushError("[Game] Instance is not initialized yet.");
            }

            return _instance;
        }
    }

    private readonly Dictionary<Type, object> _instances = new();
    private readonly List<Type>               _initOrder = new();

    public override void _EnterTree()
    {
        _instance = this;
    }

    public override void _ExitTree()
    {
        ShutdownAll();
        _instance = null;
    }

    public void Register<T>(T instance) where T : class
    {
        if (instance == null)
        {
            throw new ArgumentNullException(nameof(instance));
        }

        var t = typeof(T);
        if (_instances.ContainsKey(t))
        {
            throw new InvalidOperationException($"Service {t.Name} is already registered.");
        }

        _instances[t] = instance;
        _initOrder.Add(t);
    }

    public T Get<T>() where T : class
    {
        if (TryGet<T>(out var service))
        {
            return service;
        }

        throw new InvalidOperationException($"Service {typeof(T).Name} is not registered.");
    }

    public bool TryGet<T>(out T service) where T : class
    {
        var t = typeof(T);
        if (_instances.TryGetValue(t, out var obj) && obj != null)
        {
            service = (T)obj;
            return true;
        }

        service = null;
        return false;
    }

    public void ShutdownAll()
    {
        for (var i = _initOrder.Count - 1; i >= 0; i--)
        {
            var t = _initOrder[i];
            if (_instances.TryGetValue(t, out var obj) && obj is IService svc)
            {
                try
                {
                    svc.Shutdown();
                }
                catch (Exception ex)
                {
                    GD.PushError($"[Game] Shutdown error for {t.Name}: {ex}");
                }
            }
        }

        _instances.Clear();
        _initOrder.Clear();
    }
}