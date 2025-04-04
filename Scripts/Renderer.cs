using Godot;
using System;

public partial class Renderer : Control
{
    HBoxContainer UIPanel;
    TextureRect ShaderCanvas;
    ShaderHolder ShaderHolder;
    Control ShaderUI;
	override public void _Ready()
    {
        UIPanel = GetNode<HBoxContainer>("UIView/UIPanel");
        ShaderCanvas = GetNode<TextureRect>("ShaderView/TextureRect");
        ShaderHolder = GetNode<ShaderHolder>("Shader");
        ShaderUI = GetNode<Control>("UIView/UIPanel/Panel/MarginContainer/UIParent/ShaderUI");
        
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
        RemoveShaderScene();
        AddShaderScene(shaderScene);

        GD.Print(ShaderHolder.Name + " loaded " + ShaderHolder.GetType().Name);

        SetupShader();
    }

    private void SetupShader()
    {

        ShaderCanvas.Material = ShaderHolder.SceneShader;
        ShaderMaterial sm = ShaderCanvas.Material as ShaderMaterial;
        sm.SetShaderParameter("RESOLUTION", new Vector2(ShaderCanvas.Size.X, ShaderCanvas.Size.Y));
        ShaderHolder.SetParameters();
    }


    private void AddShaderScene(PackedScene shaderScene)
    {
        ShaderHolder = shaderScene.Instantiate() as ShaderHolder;
        AddChild(ShaderHolder);

        ShaderUI.RemoveChild(ShaderUI.GetNode<Control>("ShaderUIContainer"));
        Control ui = ShaderHolder.GetNode<Control>("ShaderUI");
        ShaderHolder.RemoveChild(ui);
        ShaderUI.AddChild(ui);
    }


    private void RemoveShaderScene()
    {
        Control ui = ShaderUI.GetNode<Control>("ShaderUI");
        ShaderUI.RemoveChild(ui);
        PanelContainer pc = new PanelContainer();
        pc.Name = "ShaderUIContainer";
        ShaderHolder.AddChild(pc);

        ShaderHolder.QueueFree();
        RemoveChild(ShaderHolder);
    }

}
