#version 440
// Native derivation; visual/model reference mkj0kjay/vue-web-liquid-glass@934404c.
// See NOTICE.md; no Vue or displacement-map code is embedded.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 surfaceSize;
    float radius;
    float reflectionStrength;
    vec4 rimColor;
    float edgeWidth;
};
float roundedDistance(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + vec2(r);
    return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - r;
}
vec2 roundedNormal(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + vec2(r);
    vec2 corner = max(q, vec2(0.0));
    if (dot(corner, corner) > .0001) return normalize(corner) * sign(p);
    return q.x > q.y ? vec2(sign(p.x), 0.0) : vec2(0.0, sign(p.y));
}
void main() {
    vec2 uv = qt_TexCoord0;
    vec2 halfSize = surfaceSize * .5;
    float r = clamp(radius, 0.0, min(halfSize.x, halfSize.y));
    vec2 p = (uv - .5) * surfaceSize;
    float d = roundedDistance(p, halfSize, r);
    float aa = max(fwidth(d), .0001);
    float coverage = 1.0 - smoothstep(-aa, 0.0, d);
    float depth = max(0.0, -d);
    vec2 normal = roundedNormal(p, halfSize, r);
    float bezel = min(max(1.0, edgeWidth), min(halfSize.x, halfSize.y) * .72);
    float t = clamp(depth / bezel, .0001, 1.0);
    float u = 1.0 - t;
    float slope = u * u * u / pow(max(.0001, 1.0 - u*u*u*u), .75);
    vec3 n = normalize(vec3(normal * slope, 1.0));
    vec3 light = normalize(vec3(-.55, -.70, .80));
    vec3 halfway = normalize(light + vec3(0.0, 0.0, 1.0));
    float specular = pow(max(0.0, dot(n, halfway)), 42.0);
    float boundary = 1.0 - smoothstep(.70, 1.0, t);
    float fresnel = pow(1.0 - n.z, 3.0) * max(0.0, dot(n, light));
    // A single thin positive glint follows exactly the refracting normal.
    // No opposite dark bevel, closed white rim or unrelated gradient layer.
    float alpha = (specular * .25 + fresnel * .035) * boundary
        * clamp(reflectionStrength, 0.0, 2.0) * coverage * qt_Opacity;
    vec3 colour = mix(vec3(1.0), rimColor.rgb / max(.0001, rimColor.a), .06);
    fragColor = vec4(colour * alpha, alpha);
}
