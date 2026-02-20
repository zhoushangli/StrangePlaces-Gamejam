using Godot;
using Protogame2D.Core;
using Protogame2D.Services;

public partial class PostProcessService : CanvasLayer, IService
{
    [Export] private ColorRect _colorRect;

    public void Init()
    {
        var mat = _colorRect.Material as ShaderMaterial;
        if (mat == null)
        {
            GD.PushError("ColorRect 没有 ShaderMaterial");
            return;
        }
    }

    public void Shutdown()
    {
        
    }
}