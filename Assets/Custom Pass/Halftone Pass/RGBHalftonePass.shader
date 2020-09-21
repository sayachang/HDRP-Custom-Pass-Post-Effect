Shader "FullScreen/RGBHalftonePass"
{
HLSLINCLUDE
#pragma vertex Vert
#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone vulkan metal switch
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
#include "../HlslInclude/Include.hlsl"
    float _Freq;
    float _RadM;
    float _RadA;
    float4 _ToneColor;
    float _AddOrg;
    float aastep(float threshold, float value) {
        return step(threshold, value);
    }
    float3 halftone(float3 texcolor, float2 st, float frequency) {
        float n = 0.1 * snoise(st * 200.0); // fracal noise
        n += 0.05 * snoise(st * 400.0);
        n += 0.025 * snoise(st * 800.0);
        n *= _RadM;
        n += _RadA;

        // Perform a rough RGB-to-CMYK conversion
        float4 cmyk;
        cmyk.xyz = 1.0 - texcolor;
        cmyk.w = min(cmyk.x, min(cmyk.y, cmyk.z)); // Create K
        cmyk.xyz -= cmyk.w; // Subtract K equivalent from CMY

        // Distance to nearest point in a grid of
        // (frequency x frequency) points over the unit square
        float2 Kst = frequency * mul(float2x2(0.707, -0.707, 0.707, 0.707) , st);
        float2 Kuv = 2.0 * frac(Kst) - 1.0;
        float k = aastep(0.0, sqrt(cmyk.w) - length(Kuv) + n);
        float2 Cst = frequency * mul(float2x2(0.966, -0.259, 0.259, 0.966) , st);
        float2 Cuv = 2.0 * frac(Cst) - 1.0;
        float c = aastep(0.0, sqrt(cmyk.x) - length(Cuv) + n);
        float2 Mst = frequency * mul(float2x2(0.966, 0.259, -0.259, 0.966) , st);
        float2 Muv = 2.0 * frac(Mst) - 1.0;
        float m = aastep(0.0, sqrt(cmyk.y) - length(Muv) + n);
        float2 Yst = frequency * st; // 0 deg
        float2 Yuv = 2.0 * frac(Yst) - 1.0;
        float y = aastep(0.0, sqrt(cmyk.z) - length(Yuv) + n);

        float3 rgbscreen = 1.0 - 0.9 * float3(c, m, y) + n;
        return lerp(rgbscreen, _ToneColor.rgb, 0.85 * k + 0.3 * n);
    }
    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
         UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float4 org = float4(0.0, 0.0, 0.0, 0.0);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        float2 uv = varyings.positionCS.xy / min(_ScreenSize.x, _ScreenSize.y);
        float2 nuv = posInput.positionNDC.xy;
        // Load the camera color buffer at the mip 0 if we're not at the before rendering injection point
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(nuv, 0), 1);
        org = color;

        color.rgb = halftone(color.rgb, uv, _Freq);
        color.rgb = lerp(color.rgb, org.rgb, _AddOrg);

        return color;
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "RGBHalftone Pass"

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