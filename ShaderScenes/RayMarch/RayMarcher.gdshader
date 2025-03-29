shader_type canvas_item;

// Uniforms for camera
uniform ivec2 RESOLUTION;
uniform vec3 CameraPos;
uniform vec3 CameraDir;
uniform vec3 CameraUp;
uniform vec3 CameraRight;

// Uniforms for objects (arrays)
uniform int ObjectCount;
uniform vec3 ObjectPos[10];       // Positions of objects
uniform vec3 ObjectDim[10];       // Dimensions (e.g., radius for spheres, normal for planes)
uniform int ObjectType[10];       // Object type (0: sphere, 1: plane)
uniform vec3 ObjectColor[10];     // Colors of objects

// Uniforms for lights (arrays)
uniform int LightCount;
uniform vec3 LightPos[10];        // Positions of lights
uniform vec3 LightColor[10];      // Colors of lights

uniform vec3 SkyColor1 = vec3(0.5, 0.7, 1.0); // Top gradient color
uniform vec3 SkyColor2 = vec3(1.0, 1.0, 1.0); // Bottom gradient color

const int MAX_STEPS = 100; // Maximum iterations for ray marching
const float MIN_DIST = 0.001; // Minimum distance to consider a hit
const float MAX_DIST = 50.0; // Maximum distance before stopping

// Signed distance function for sphere
float SDF_Sphere(vec3 point, vec3 center, float radius) {
    return length(point - center) - radius;
}

// Signed distance function for plane
float SDF_Plane(vec3 point, vec3 planePoint, vec3 planeNormal) {
    return dot(point - planePoint, planeNormal);
}

// Calculate distance to scene objects
float SDF_Scene(vec3 point, out vec3 color) {
    float closestDist = MAX_DIST;
    color = SkyColor2;

    for (int i = 0; i < ObjectCount; i++) {
        float dist;
        if (ObjectType[i] == 0) { // Sphere
            dist = SDF_Sphere(point, ObjectPos[i], ObjectDim[i].x);
        } else if (ObjectType[i] == 1) { // Plane
            dist = SDF_Plane(point, ObjectPos[i], normalize(ObjectDim[i]));
        }else {
            continue; // Unknown object type, skip processing
        }

        if (dist < closestDist) {
            closestDist = dist;
            color = ObjectColor[i]; // Update color of the closest object
        }
    }
    return closestDist;
}

// Ray direction calculation
vec3 RayDirection(vec2 uv) {
    return normalize(CameraDir + uv.x * CameraRight + uv.y * CameraUp);
}

// Ray marching function
float RayMarch(vec3 origin, vec3 rayDir, out vec3 hitPoint, out vec3 hitColor) {
    float totalDist = 0.0;
    for (int i = 0; i < MAX_STEPS; i++) {
        hitPoint = origin + rayDir * totalDist;
        float dist = SDF_Scene(hitPoint, hitColor);
        if (dist < MIN_DIST) {
            return totalDist; // Hit an object
        }
        if (totalDist > MAX_DIST) {
            break; // Exceeded maximum distance
        }
        totalDist += dist; // Move closer along the ray
    }
    return -1.0; // No hit
}

// Sky gradient function
vec3 SkyGradient(vec2 uv) {
    float t = uv.y * 0.5 + 0.5;
    return mix(SkyColor2, SkyColor1, t);
}

void fragment() {
    // UV coordinates and aspect correction
    vec2 uv = ((FRAGCOORD.xy / vec2(RESOLUTION)) * 2.0 - vec2(float(RESOLUTION.x) / float(RESOLUTION.y), 1.0)) * vec2(1.0, -1.0);

    vec3 rayDir = RayDirection(uv);
    vec3 hitPoint;
    vec3 hitColor;
    float dist = RayMarch(CameraPos, rayDir, hitPoint, hitColor);

    vec3 color;
    if (dist > 0.0) {
        // Hit an object
        color = hitColor;
    } else {
        // No hit - sky gradient
        color = SkyGradient(uv);
    }

    COLOR = vec4(color, 1.0);
}