Shader "FullScreen/RainPass"
{
    HLSLINCLUDE

#pragma vertex Vert

#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
        
    TEXTURE2D_X(_BufferTex);
    float _RainAmount;
    float _Zoom;
    float _Speed;

    float S(float a, float b, float t) {
        return smoothstep(a, b, t);
    }

    float3 S(float3 a, float3 b, float t) {
        return smoothstep(a, b, t);
    }

    float3 N13(float p) {
        // from DAVE HOSKINS
        float3 p3 = frac(float3(p, p, p) * float3(.1031, .11369, .13787));
        p3 += dot(p3, p3.yzx + 19.19);
        return frac(float3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
    }

    float N(float t) {
        return frac(sin(t * 12345.564) * 7658.76);
    }

    float Saw(float b, float t) {
        return S(0., b, t) * S(1., b, t);
    }

    float2 DropLayer2(float2 uv, float t) {
        float2 UV = uv;

        uv.y += t * 0.75;
        float2 a = float2(6., 1.);
        float2 grid = a * 2.;
        float2 id = floor(uv * grid);

        float colShift = N(id.x);
        uv.y += colShift;

        id = floor(uv * grid);
        float3 n = N13(id.x * 35.2 + id.y * 2376.1);
        float2 st = frac(uv * grid) - float2(.5, 0);

        float x = n.x - .5;

        float y = UV.y * 20.;
        float wiggle = sin(y + sin(y));
        x += wiggle * (.5 - abs(x)) * (n.z - .5);
        x *= .7;
        float ti = frac(t + n.z);
        y = (Saw(.85, ti) - .5) * .9 + .5;
        float2 p = float2(x, y);

        float d = length((st - p) * a.yx);

        float mainDrop = S(.4, .0, d);

        float r = sqrt(S(1., y, st.y));
        float cd = abs(st.x - x);
        float trail = S(.23 * r, .15 * r * r, cd);
        float trailFront = S(-.02, .02, st.y - y);
        trail *= trailFront * r * r;

        y = UV.y;
        float trail2 = S(.2 * r, .0, cd);
        float droplets = max(0., (sin(y * (1. - y) * 120.) - st.y)) * trail2 * trailFront * n.z;
        y = frac(y * 10.) + (st.y - .5);
        float dd = length(st - float2(x, y));
        droplets = S(.3, 0., dd);
        float m = mainDrop + droplets * r * trailFront;

        return float2(m, trail);
    }

    float StaticDrops(float2 uv, float t) {
        uv *= 40.;

        float2 id = floor(uv);
        uv = frac(uv) - .5;
        float3 n = N13(id.x * 107.45 + id.y * 3543.654);
        float2 p = (n.xy - .5) * .7;
        float d = length(uv - p);

        float fade = Saw(.025, frac(t + n.z));
        float c = S(.3, 0., d) * frac(n.z * 10.) * fade;
        return c;
    }

    float2 Drops(float2 uv, float t, float l0, float l1, float l2) {
        float s = StaticDrops(uv, t) * l0;
        float2 m1 = DropLayer2(uv, t) * l1;
        float2 m2 = DropLayer2(uv * 1.85, t) * l2;

        float c = s + m1.x + m2.x;
        c = S(.3, 1., c);

        return float2(c, max(m1.y * l0, m2.y * l1));
    }

    float3 rain(float2 i) {
        float time = _Time.y;
        float rainAmount = _RainAmount;
        float zoom = _Zoom;
        float speed = _Speed;
        float rainTime = 360.;

        float2 uv = ((i * _ScreenSize.xy) - .5 * _ScreenSize.xy) / min(_ScreenSize.x, _ScreenSize.y);
        float2 UV = i;

        float T = time - floor(time / rainTime) * rainTime;
        float t = T * .2;
        t = min(1., T / rainTime); // remap drop time so it goes slower when it freezes
        t = 1. - t;
        t = (1. - t * t) * rainTime;

        // tweak uv, time
        uv *= zoom;
        t *= speed;

        // let the rain fall down
        float staticDrops = S(-.5, 1., rainAmount) * 2.;
        float layer1 = S(.25, .75, rainAmount);
        float layer2 = S(.0, .5, rainAmount);

        float2 c = Drops(uv, t, staticDrops, layer1, layer2);
        float2 e = float2(.001, 0.);
        float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
        float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2).x;
        float2 n = float2(cx - c.x, cy - c.x);

        // load tex
        float2 texCoord = float2(UV.x + n.x, UV.y + n.y);
        float3 col = CustomPassSampleCameraColor(texCoord, 0);

        return col;
    }

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        // Load the camera color buffer at the mip 0 if we're not at the before rendering injection point
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(posInput.positionNDC.xy, 0), 1);

        float2 uv = posInput.positionNDC.xy;
        color.rgb = rain(uv);
        return color;
    }

        ENDHLSL

        SubShader
    {
        Pass
        {
            Name "Rain Pass"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}