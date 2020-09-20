Shader "FullScreen/MizutamaTransitionPass"
{
HLSLINCLUDE
#pragma vertex Vert
#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
#include "../HlslInclude/Include.hlsl"

    TEXTURE2D_X(_BufferTex);
    float _Size;
    float3 _MizutamaCol;
    float _Gaming;
    float _Mizutama;
    float _Horizontal;
    float3 transitionCol(float3 col, float hx) {
        float3 hsv = rgb2hsv(col);
        hsv.x += _Gaming * cos(0.5 * hx + _Time.y);
        return hsv2rgb(hsv);
    }
    float3 mizutama(float2 uv, float2 nuv, float3 orgCol) {
        float t = .5 + .5 * cos(_Time.y + PI); // 0.0 - 1.0
        float2 p = _Size * uv;
        p = frac(p)-(.5).xx;
        float len = length(p); // 0.0 - 0.7071
        float sw = step(len, 0.7071 * t);
        return lerp(orgCol, transitionCol(_MizutamaCol, 0.0), sw);
    }
    float3 horizontal(float2 uv, float2 nuv, float3 orgCol) {
        float hx = nuv.x; // 0.0 - 1.0
        float t = -cos(_Time.y); // -1.0 - 1.0
        float2 p = _Size * uv;
        p = 2.0 * (frac(p) - (.5).xx); // -1.0 - 1.0
        float len = length(p); // 0.0 - 1.4142
        float sw = step(len, 1.4142 * (hx + t));
        return lerp(orgCol, transitionCol(_MizutamaCol, hx), sw);
    }
    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        float2 uv = varyings.positionCS.xy / min(_ScreenSize.x, _ScreenSize.y);
        float2 nuv = posInput.positionNDC.xy;
        // Load the camera color buffer at the mip 0 if we're not at the before rendering injection point
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(nuv, 0), 1);

        float3 col = color.rgb;

        float3 mizutamaCol = mizutama(uv, nuv, col);
        float3 horizontalCol = horizontal(uv, nuv, col);

        col = lerp(col, mizutamaCol, _Mizutama);
        col = lerp(col, horizontalCol, _Horizontal);

        color.rgb = col;
        return color;
    }

ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Azayaka Pass"

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