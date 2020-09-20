static float3 BT601 = float3(0.298912, 0.586611, 0.114478);

float bt601Lum(float3 c) {
    return dot(c, BT601);
}

float mod(float x, float y) { return x - floor(x / y) * y; }
float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float2 mod289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float3 permute(float3 x) { return mod289(((x * 34.0) + 1.0) * x); }

float snoise(float2 v) {
    const float4 C = float4(0.211324865405187,
        0.366025403784439,
        -0.577350269189626,
        0.024390243902439);

    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    float2 i1 = float2(0.0, 0.0);
    i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float2 x1 = x0.xy + C.xx - i1;
    float2 x2 = x0.xy + C.zz;

    i = mod289(i);
    float3 p = permute(
        permute(i.y + float3(0.0, i1.y, 1.0))
        + i.x + float3(0.0, i1.x, 1.0));

    float3 m = max(0.5 - float3(
        dot(x0, x0),
        dot(x1, x1),
        dot(x2, x2)
        ), 0.0);

    m = m * m;
    m = m * m;

    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

    float3 g = (.0).xxx;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * float2(x1.x, x2.x) + h.yz * float2(x1.y, x2.y);
    return 130.0 * dot(m, g);
}

float remap(float val, float inMin, float inMax, float outMin, float outMax)
{
    return clamp(outMin + (val - inMin) * (outMax - outMin) / (inMax - inMin), outMin, outMax);
}

float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
