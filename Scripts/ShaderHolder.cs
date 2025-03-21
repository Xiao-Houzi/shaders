using Godot;
using System;

public partial class ShaderHolder : Node2D
{
    [Export]    public ShaderMaterial SceneShader { get; set; }

    public override void _Ready()
    {
        Vector2 viewportSize = GetTree().Root.Size;
    }
}
