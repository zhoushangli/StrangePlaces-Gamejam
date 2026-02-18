using System;
using System.Collections.Generic;
using Godot;

public partial class QuantumItem : StaticBody2D
{
    [Export] private Node2D[] _anchors;

    public bool IsObserved { get; private set; }

    private int _anchorIndex = 0;

    public override void _Ready()
    {
        if (QuantumManager.Instance != null)
        {
            QuantumManager.Instance.RegisterItem(this);
        }
        else
        {
            GD.PushWarning($"[QuantumItem] QuantumManager not ready when '{Name}' entered tree.");
        }
    }

    public override void _ExitTree()
    {
        QuantumManager.Instance?.UnregisterItem(this);
    }

    public void SetObserved(bool observed)
    {
        if (IsObserved == observed)
            return;

        var wasObserved = IsObserved;
        IsObserved = observed;

        if (wasObserved && !observed)
            MoveToNextAnchor();
    }

    private void MoveToNextAnchor()
    {
        if (_anchors.Length == 0)
            return;

        _anchorIndex   = (_anchorIndex + 1) % _anchors.Length;
        GlobalPosition = _anchors[_anchorIndex].GlobalPosition;
    }
}
