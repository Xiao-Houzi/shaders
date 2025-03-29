using Godot;
using System;

public partial class RayCaster : ShaderHolder
{
    Camera3D Camera;
    Node3D Lights;
    Node3D Objects;

    public override void _Ready()
    {
        Camera = GetNode<Camera3D>("Scene/Camera3D");
        Lights = GetNode<Node3D>("Scene/Lights");
        Objects = GetNode<Node3D>("Scene/Objects");
    }

    private void CalculateCameraParameters()
    {
        // Calculate the forward direction vector from the camera's transform
        Vector3 CameraDir = -Camera.GlobalTransform.Basis.Z;
        Vector3 CameraUp = Camera.GlobalTransform.Basis.Y;
        Vector3 CameraRight = Camera.GlobalTransform.Basis.X;

        SceneShader.SetShaderParameter("CameraPos", Camera.GlobalTransform.Origin);
        SceneShader.SetShaderParameter("CameraDir", CameraDir);
        SceneShader.SetShaderParameter("CameraUp", CameraUp);
        SceneShader.SetShaderParameter("CameraRight", CameraRight);

        GD.Print($"CameraPos: {Camera.GlobalTransform.Origin}");
        GD.Print($"CameraDir: {CameraDir}");
        GD.Print($"CameraUp: {CameraUp}");
        GD.Print($"CameraRight: {CameraRight}");
    }

    public override void SetParameters()
    {
        GD.Print($"Setting RayCaster Parameters for {Camera}");

        // Calculate and set camera parameters
        CalculateCameraParameters();

        // Create an array to store the light positions
        Godot.Collections.Array<Vector3> LightPositions = new Godot.Collections.Array<Vector3>();
        Godot.Collections.Array<int> LightTypes = new Godot.Collections.Array<int>();
        Godot.Collections.Array<Vector3> LightColours = new Godot.Collections.Array<Vector3>(); // Array for object colors

        foreach (Node child in Lights.GetChildren())
        {
            if (child is Light3D light)
            {
                GD.Print($"Light Name: {light.Name}, Type: {light.GetType().Name}");
                LightPositions.Add(light.GlobalTransform.Origin);
                LightColours.Add(new Vector3(light.LightColor.R,light.LightColor.G, light.LightColor.B)); 
                LightTypes.Add(1);
            }
        }

        // Pass the positions to the shader
        SceneShader.SetShaderParameter("LightPos", LightPositions);
        SceneShader.SetShaderParameter("LightType", LightTypes);
        SceneShader.SetShaderParameter("LightColour", LightColours);
        SceneShader.SetShaderParameter("LightCount", LightPositions.Count);

        GD.Print($"LightCount: {LightPositions.Count}");
        for (int i = 0; i < LightPositions.Count; i++)
        {
            GD.Print($"LightPos[{i}]: {LightPositions[i]}, Colour[{i}]: {LightColours[i]}, LightType[{i}]: {LightTypes[i]}");
        }

        // Create arrays to store the object properties
        Godot.Collections.Array<Vector3> ObjectPositions = new Godot.Collections.Array<Vector3>();
        Godot.Collections.Array<Vector3> ObjectDimensions = new Godot.Collections.Array<Vector3>();
        Godot.Collections.Array<int> ObjectTypes = new Godot.Collections.Array<int>();
        Godot.Collections.Array<Vector3> ObjectColours = new Godot.Collections.Array<Vector3>(); // Array for object colors

        foreach (Node child in Objects.GetChildren())
        {
            if (child is CsgPrimitive3D Object)
            {
                GD.Print($"Object Name: {Object.Name}, Type: {Object.GetType().Name}");
                ObjectPositions.Add(Object.GlobalTransform.Origin); // Get the position in world space

                // Retrieve object type and dimensions
                if (Object is CsgSphere3D)
                {
                    ObjectDimensions.Add(Object.GlobalTransform.Basis.Scale); 
                    ObjectTypes.Add(0); // Type 0 for spheres
                    Color color = ((StandardMaterial3D)((CsgSphere3D)Object).Material).AlbedoColor;
                    ObjectColours.Add(new Vector3(color.R, color.G, color.B));
                }
                else if (Object is CsgMesh3D) // Handling Plane objects
                {
                    ObjectDimensions.Add(Object.GlobalTransform.Basis.Z); // Normal vector is along z-axis
                    ObjectTypes.Add(1); // Type 1 for planes
                    Color color = ((StandardMaterial3D)((CsgMesh3D)Object).Material).AlbedoColor;
                    ObjectColours.Add(new Vector3(color.R, color.G, color.B));
                }
            }
        }

        // Pass the positions to the shader
        SceneShader.SetShaderParameter("ObjectPos", ObjectPositions);
        SceneShader.SetShaderParameter("ObjectDim", ObjectDimensions);
        SceneShader.SetShaderParameter("ObjectType", ObjectTypes);
        SceneShader.SetShaderParameter("ObjectColour", ObjectColours);
        SceneShader.SetShaderParameter("ObjectCount", ObjectPositions.Count);

        GD.Print($"ObjectCount: {ObjectPositions.Count}");
        for (int i = 0; i < ObjectPositions.Count; i++)
        {
            GD.Print($"ObjectPos[{i}]: {ObjectPositions[i]}, ObjectDim[{i}]: {ObjectDimensions[i]}, Colour[{i}]: {ObjectColours[i]}, ObjectType[{i}]: {ObjectTypes[i]}");
        }
    }
}