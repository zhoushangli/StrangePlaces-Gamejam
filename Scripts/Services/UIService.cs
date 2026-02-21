using System;
using System.Collections.Generic;
using Godot;
using Protogame2D.Core;
using Protogame2D.UI;

namespace Protogame2D.Services;

/// <summary>
/// UI 服务。Prefab 路径: res://Scenes/UI/{ClassName}.tscn
/// </summary>
public partial class UIService : CanvasLayer, IService
{
    private const string UIPrefabBase = "res://Prefabs/UI/";

    private Control _popupLayer;
    private readonly List<UIBase> _stack = new();

    public void Init()
    {
        Name = "UIRoot";

        _popupLayer = GetNode<Control>("PopupLayer");

        TreeExiting += () =>
        {
            _stack.Clear();
        };
    }

    public T Open<T>(object args = null) where T : UIBase
    {
        var path = $"{UIPrefabBase}{GetPrefabName(typeof(T))}.tscn";

        var packed = GD.Load<PackedScene>(path);
        if (packed == null)
        {
            GD.PushError($"[UIService] UI prefab not found: {path}");
            return null;
        }

        var inst = packed.Instantiate<T>();
        _popupLayer.AddChild(inst);

        OpenInstance(inst, args);
        return inst;
    }

    public Node Open(PackedScene scene, object args = null)
    {
        if (scene == null)
        {
            GD.PushError("[UIService] Open called with null PackedScene.");
            return null;
        }

        var instance = scene.Instantiate();
        if (instance == null)
        {
            GD.PushError("[UIService] Failed to instantiate UI scene.");
            return null;
        }

        _popupLayer.AddChild(instance);

        if (instance is UIBase ui)
        {
            OpenInstance(ui, args);
        }
        else
        {
            GD.PushWarning(
                $"[UIService] Open(PackedScene) instantiated '{instance.GetType().Name}', not UIBase. Not stacked."
            );
        }

        return instance;
    }

    private void OpenInstance(UIBase inst, object args)
    {
        var t = inst.GetType();

        // 清理无效引用 + 同类型去重
        for (var i = _stack.Count - 1; i >= 0; i--)
        {
            var existing = _stack[i];
            if (existing == null || !IsInstanceValid(existing))
            {
                _stack.RemoveAt(i);
                continue;
            }

            if (existing.GetType() != t) continue;

            _stack.RemoveAt(i);
            existing.OnClose();
            existing.QueueFree();
            break;
        }

        inst.OnOpen(args);
        _stack.Add(inst);
    }

    public void Close<T>() where T : UIBase
    {
        var t = typeof(T);
        for (var i = _stack.Count - 1; i >= 0; i--)
        {
            var ui = _stack[i];
            if (ui.GetType() != t) continue;

            _stack.RemoveAt(i);
            ui.OnClose();
            ui.QueueFree();
            return;
        }
    }

    public void CloseTop()
    {
        if (_stack.Count == 0) return;

        var ui = _stack[^1];
        _stack.RemoveAt(_stack.Count - 1);
        ui.OnClose();
        ui.QueueFree();
    }

    public bool IsOpen<T>() where T : UIBase
    {
        var t = typeof(T);
        for (var i = _stack.Count - 1; i >= 0; i--)
        {
            if (_stack[i].GetType() == t)
                return true;
        }

        return false;
    }

    public void Shutdown()
    {
        _stack.Clear();
    }

    private string GetPrefabName(Type t)
    {
        var name = t.Name;

        if (name.EndsWith("UI"))
            name = name[..^2];

        return $"UI_{name}";
    }

}
