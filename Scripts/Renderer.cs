using Godot;
using System;

public partial class Renderer : Control
{
    HBoxContainer UIPanel;
    TextureRect ShaderCanvas;
    ShaderHolder ShaderHolder;
	
	override public void _Ready()
    {
        UIPanel = GetNode<HBoxContainer>("UIView/UIPanel");
        ShaderCanvas = GetNode<TextureRect>("ShaderView/TextureRect");
        ShaderHolder = GetNode<ShaderHolder>("Shader");

        ShaderCanvas.Material = ShaderHolder.Material;
        ShaderMaterial sm = ShaderCanvas.Material as ShaderMaterial;
        sm.SetShaderParameter("RESOLUTION", new Vector2(ShaderCanvas.Size.X, ShaderCanvas.Size.Y));
    }

    public override void _Input(InputEvent @event)
    {
        base._Input(@event);

        if (Input.IsActionPressed("se_exit"))
        {
            GetTree().Quit();
        }
        if (Input.IsActionPressed("se_panel"))
        {
           
            UIPanel.Visible = !UIPanel.Visible;
        }
    }

    public void SetShader(PackedScene shaderScene)
    {

        ShaderHolder = shaderScene.Instantiate() as ShaderHolder;
        ShaderCanvas.Material = ShaderHolder.SceneShader;
        ShaderMaterial sm = ShaderCanvas.Material as ShaderMaterial;
        sm.SetShaderParameter("RESOLUTION", new Vector2(ShaderCanvas.Size.X, ShaderCanvas.Size.Y));
    }
}
