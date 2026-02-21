using Godot;
using Protogame2D.Core;
using System.Collections.Generic;

public partial class QuantumService : Node, IService
{
    private readonly List<QuantumObserver> _observers = new();
    private readonly List<QuantumItem> _items = new();

    public void Init()
    {
    }

    public void Shutdown()
    {
        _observers.Clear();
        _items.Clear();
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
