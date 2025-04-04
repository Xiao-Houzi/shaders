using Godot;
using System;

public partial class ShaderSelector : Container
{
    [Export] public String ShaderName { get; set; }
    [Export] public PackedScene ShaderScene { get; set; }

    public override void _Ready()
    {
        GetNode<Label>("Rect/Margin/Label").Text = ShaderName;
        
    }

    public void OnShaderSelected()
    {
        GD.Print("Shader selected: " + ShaderName);
        GetTree().Root.GetNode<Renderer>("Renderer").SetShader(ShaderScene);

    }
}
