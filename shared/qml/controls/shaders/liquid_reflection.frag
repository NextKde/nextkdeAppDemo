#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 surfaceSize;
    float radius;
    float reflectionStrength;
    vec4 rimColor;
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
    // Positive reflected light only: no opposite dark bevel or closed outline.
    float light = pow(max(0.0, dot(normal, normalize(vec2(-.52, -.85)))), 1.8);
    float spatial = .35 + .65 * exp(-pow((uv.x - .28) / .56, 2.0));
    float arc = exp(-pow((depth - 2.6) / 3.3, 2.0)) * light * spatial;
    float rim = exp(-pow((depth - .65) / .85, 2.0)) * light * light * spatial;
    float sheen = exp(-pow((uv.x - .27) / .55, 2.0) - pow((uv.y - .10) / .75, 2.0));
    float colourWeight = clamp(rimColor.a / .30, 0.0, 1.0);
    float alpha = (arc * .068 + rim * .070 + sheen * .012)
        * clamp(reflectionStrength, 0.0, 2.0) * (.55 + .45 * colourWeight)
        * coverage * qt_Opacity;
    vec3 colour = mix(vec3(1.0), rimColor.rgb / max(.0001, rimColor.a), colourWeight * .16);
    fragColor = vec4(colour * alpha, alpha);
}
