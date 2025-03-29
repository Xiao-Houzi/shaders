shader_type canvas_item;

uniform ivec2 RESOLUTION;

uniform vec3 CameraPos;
uniform vec3 CameraDir;
uniform vec3 CameraUp;
uniform vec3 CameraRight;

uniform int LightCount;
uniform vec3 LightPos[5];
uniform int LightType[5];

uniform int ObjectCount;
uniform vec3 ObjectPos[10];
uniform vec3 ObjectDim[10];
uniform int ObjectType[10];

void fragment() {
    // Screen UV coordinates
    vec2 uv = FRAGCOORD.xy / vec2(RESOLUTION);

    vec4 color = vec4(0.0, 0.0, 0.0, 1.0); // Default color

    // Visualize CameraPos
    if (uv.x < 0.2) {
        color = vec4(CameraPos, 1.0);
    }
    // Visualize CameraDir
    else if (uv.x < 0.4) {
        color = vec4(CameraDir, 1.0)*vec4(1.0, 1.0, -1.0, 1.0);
    }
    // Visualize CameraUp
    else if (uv.x < 0.6) {
        color = vec4(CameraUp, 1.0);
    }
    // Visualize CameraRight
    else if (uv.x < 0.8) {
        color = vec4(CameraRight, 1.0);
    }
    // Visualize Light Positions
    else if (uv.x < 1.0) {
        int lightIndex = int(uv.y * float(LightCount));
        if (lightIndex < LightCount) {
            color = vec4(LightPos[lightIndex], 1.0);
        }
    }
    // Visualize Object Positions
    else {
        int objectIndex = int(uv.y * float(ObjectCount));
        if (objectIndex < ObjectCount) {
            color = vec4(ObjectPos[objectIndex], 1.0);
        }
    }

    // Output final color
    COLOR = color;
}