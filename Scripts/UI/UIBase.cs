using Godot;

namespace Protogame2D.UI;

/// <summary>
/// UI 基类，所有 UI 窗口继承此类。
/// </summary>
public abstract partial class UIBase : Control
{
    public abstract void OnOpen(object args);
    public abstract void OnClose();
}
