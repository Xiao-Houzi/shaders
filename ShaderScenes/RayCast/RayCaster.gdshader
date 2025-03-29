shader_type canvas_item;

uniform ivec2 RESOLUTION;

uniform vec3 CameraPos;
uniform vec3 CameraDir;
uniform vec3 CameraUp;
uniform vec3 CameraRight;

uniform vec3 FogColor = vec3(0.3, 0.8, 1.);
uniform float FogDensity = 1.;
uniform float FogStart = 0.1;

uniform int LightCount;
uniform vec3 LightPos[5];
uniform int LightType[5];
uniform vec3 LightColour[10];

uniform int ObjectCount;
uniform vec3 ObjectPos[10];
uniform vec3 ObjectDim[10];
uniform int ObjectType[10];
uniform vec3 ObjectColour[10];

vec3 RayDirection(vec2 uv) {
    // Calculate ray direction based on camera parameters
    vec3 rayDir = normalize(CameraDir + uv.x * CameraRight + uv.y * CameraUp);
    return rayDir;
}

bool RayIntersectsSphere(vec3 rayOrigin, vec3 rayDir, vec3 sphereCenter, float sphereRadius, out float t, out vec3 normal) {
    vec3 oc = rayOrigin - sphereCenter;
    float incidence = 2.0 * dot(oc, rayDir);
    float distanceToSurface = dot(oc, oc) - sphereRadius * sphereRadius;
    float discriminant = incidence * incidence - 4.0 * distanceToSurface;

    if (discriminant > 0.0) {
        t = (-incidence - sqrt(discriminant)) / 2.0; // Closest intersection
        if (t > 0.0) {
            vec3 hitPoint = rayOrigin + t * rayDir;
            normal = normalize(hitPoint - sphereCenter);
            return true;
        }
    }
    return false;
}

bool RayIntersectsPlane(vec3 rayOrigin, vec3 rayDir, vec3 planePoint, vec3 planeNormal, out float t, out vec3 normal) {
    float denominator = dot(rayDir, planeNormal);
    if (abs(denominator) > 1e-6) { // Avoid division by zero (ray parallel to the plane)
        t = dot(planePoint - rayOrigin, planeNormal) / denominator;
        if (t > 0.0) {
            normal = planeNormal; // Normal is constant for a plane
            return true;
        }
    }
    return false;
}

bool IsInShadow(vec3 hitPoint, vec3 lightPos) {
    vec3 shadowRay = normalize(lightPos - hitPoint);
    float tShadow;
    vec3 dummyNormal;

    for (int j = 0; j < ObjectCount; j++) {
        if (ObjectType[j] == 0) { // Sphere
            float radius = ObjectDim[j].x;
            if (RayIntersectsSphere(hitPoint + shadowRay * 1e-3, shadowRay, ObjectPos[j], radius, tShadow, dummyNormal)) {
                // Offset shadow ray origin slightly to avoid self-shadowing
                if (tShadow < length(lightPos - hitPoint)) {
                    return true; // In shadow
                }
            }
        } else if (ObjectType[j] == 1) { // Plane
            vec3 planePoint = ObjectPos[j];
            vec3 planeNormal = normalize(ObjectDim[j]);
            if (RayIntersectsPlane(hitPoint + shadowRay * 1e-3, shadowRay, planePoint, planeNormal, tShadow, dummyNormal)) {
                // Offset shadow ray origin slightly to avoid self-shadowing
                if (tShadow < length(lightPos - hitPoint)) {
                    return true; // In shadow
                }
            }
        }
    }
    return false; // Not in shadow
}

vec3 ComputeLighting(vec3 hitPoint, vec3 normal, vec3 viewDir, vec3 objectColor) {
    vec3 color = vec3(0.1) * objectColor; // Ambient light scaled by object color

    for (int i = 0; i < LightCount; i++) {
        if (LightType[i] == 1) { // Omni light
            vec3 lightDir = normalize(LightPos[i] - hitPoint);

			if (!IsInShadow(hitPoint + normal * 1e-3, LightPos[i])) {

			    float diff = max(dot(normal, lightDir), 0.0);
			    color += objectColor * diff; // Add diffuse light only if not in shadow.
			}

        }
    }

    return color;
}

vec3 Sky(vec2 uv) {
    // Sky gradient colors
    vec3 skyTopColor = vec3(1., 1., 1.); // Light blue for the top of the sky
    vec3 skyBottomColor = vec3(0.6, 0.8, 1.0); // White for the bottom of the sky

    // Interpolate between the top and bottom colors based on the y-coordinate
    float t = uv.y * 0.5 + 0.5; // Map uv.y from [-1, 1] to [0, 1]
    return mix(skyBottomColor, skyTopColor, t);
}

vec3 ApplyFog(vec3 Color, vec3 HitPoint) {
    float Distance = length(HitPoint - CameraPos); // Calculate distance from the camera
    float FogFactor = 1.0 - exp(-FogDensity * (Distance - FogStart)); // Exponential fog formula
    FogFactor = clamp(FogFactor, 0.0, 1.0); // Clamp to [0, 1]
    return mix(Color, FogColor, FogFactor); // Blend color with fog color
}

void fragment() {
    vec2 uv = (FRAGCOORD.xy / vec2(RESOLUTION)) * 2.0 - vec2(1.0);
    uv.x *= float(RESOLUTION.x) / float(RESOLUTION.y); // Correct for aspect ratio
    uv.y = -uv.y;

    vec3 RayOrigin = CameraPos;
    vec3 RayDir = RayDirection(uv);

    vec3 Color = Sky(uv); // Default sky color
    bool Hit = false;
    float ClosestT = 1e6; // Track the closest intersection
    vec3 HitNormal;
    vec3 HitColor;

    for (int I = 0; I < ObjectCount; I++) {
        float T;
        vec3 Normal;

        if (ObjectType[I] == 0) { // Sphere
            float Radius = ObjectDim[I].x;
            if (RayIntersectsSphere(RayOrigin, RayDir, ObjectPos[I], Radius, T, Normal) && T < ClosestT) {
                ClosestT = T;
                Hit = true;
                HitNormal = Normal;
                HitColor = ObjectColour[I];
            }
        } else if (ObjectType[I] == 1) { // Plane
            vec3 PlanePoint = ObjectPos[I];
            vec3 PlaneNormal = normalize(ObjectDim[I]);
            if (RayIntersectsPlane(RayOrigin, RayDir, PlanePoint, PlaneNormal, T, Normal) && T < ClosestT) {
                ClosestT = T;
                Hit = true;
                HitNormal = Normal;
                HitColor = ObjectColour[I];
            }
        }
    }

    if (Hit) {
        vec3 HitPoint = RayOrigin + ClosestT * RayDir;
        vec3 ViewDir = normalize(RayOrigin - HitPoint);
        Color = ComputeLighting(HitPoint, HitNormal, ViewDir, HitColor); // Apply lighting
        Color = ApplyFog(Color, HitPoint); // Apply fog to the color
    } else {
        Color = ApplyFog(Color, RayOrigin + RayDir * 100.0); // Apply fog to sky color
    }

    COLOR = vec4(Color, 1.0);
}
