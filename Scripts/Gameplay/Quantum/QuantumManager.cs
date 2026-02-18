using System.Collections.Generic;
using Godot;

public partial class QuantumManager : Node
{
    private static QuantumManager _instance;
    public static QuantumManager Instance => _instance;

    private readonly List<QuantumObserver> _observers = new();
    private readonly List<QuantumItem> _items = new();

    public override void _EnterTree()
    {
        if (_instance != null && _instance != this)
        {
            GD.PushError("[QuantumManager] Multiple instances detected.");
            QueueFree();
            return;
        }

        _instance = this;
    }

    public override void _ExitTree()
    {
        if (_instance == this)
            _instance = null;
    }

    public override void _Ready()
    {
    }

    public void RegisterObserver(QuantumObserver observer)
    {
        if (!GodotObject.IsInstanceValid(observer))
            return;

        if (!_observers.Contains(observer))
            _observers.Add(observer);
    }

    public void UnregisterObserver(QuantumObserver observer)
    {
        _observers.Remove(observer);
    }

    public void RegisterItem(QuantumItem item)
    {
        if (!GodotObject.IsInstanceValid(item))
            return;

        if (!_items.Contains(item))
            _items.Add(item);
    }

    public void UnregisterItem(QuantumItem item)
    {
        _items.Remove(item);
    }

    public override void _Process(double delta)
    {
        foreach (var item in _items)
        {
            var observedNow = false;

            foreach (var observer in _observers)
            {
                if (observer.CanObserve(item))
                {
                    observedNow = true;
                    break;
                }
            }

            item.SetObserved(observedNow);
        }
    }
}
