﻿Shader "FullScreen/GrayscalePass"
{
    HLSLINCLUDE

#pragma vertex Vert

#pragma target 4.5
#pragma only_renderers d3d11 playstation xboxone vulkan metal switch

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
    float2 _Centre;
    float _Rad;
    float _OverrideCol;
    float3 _Color;
    float3 clipGray(float3 col, float3 gray, float2 uv, float2 center, float rad)
    {
        float nrad = clamp(rad, 0., 1.);
        float d = distance(uv, center) / rad;

        d = clamp(d, 0., 1.);
        return lerp(gray, col, d);
    }
    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
         UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float2 uv = posInput.positionNDC.xy;
        float4 color = float4(0.0, 0.0, 0.0, 0.0);
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(uv, 0), 1);

        float3 gray = dot(color.rgb, float3(0.2126, 0.7152, 0.0722)).xxx;
        gray = lerp(gray, _Color, _OverrideCol);
        color.rgb = clipGray(color.rgb, gray, uv, _Centre, _Rad);
        return color;
    }

        ENDHLSL

        SubShader
    {
        Pass
        {
            Name "Grayscale Pass"

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