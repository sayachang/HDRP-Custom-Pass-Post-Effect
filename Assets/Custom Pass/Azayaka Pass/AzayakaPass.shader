Shader "FullScreen/AzayakaPass"
{
HLSLINCLUDE
#pragma vertex Vert
#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
#include "../HlslInclude/Include.hlsl"

    TEXTURE2D_X(_BufferTex);
    float _AzayakaR;
    float _AzayakaL;
    float _Value;
    float _VibranceAmount;
    float _Mixture;
    float _Border;

    float3 azayaka(float3 col) {
        float valueMul = _Value;

        float lum = bt601Lum(col);
        float3 hsv = rgb2hsv(col);
        
        if (hsv.y >= _AzayakaR)
            hsv.y = remap(hsv.y, _AzayakaR, 1., .5, 1.);
        else if (hsv.y < _AzayakaL)
            hsv.y = remap(hsv.y, 0., _AzayakaL, 0., .5);
        else hsv.y = .5;

        hsv.z *= (1. + valueMul * lum);

        return hsv2rgb(hsv);
    }

    float3 vibrance(float3 col) {
        float amount = _VibranceAmount;

        float lum = bt601Lum(col);
        float3 mask = (col - lum.xxx);
        mask = clamp(mask, 0.0, 1.0);
        float lumMask = bt601Lum(mask);
        return lerp(lum.xxx, col, 1.0 + amount * (1.0 - lumMask));
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
        float3 col = azayaka(color.rgb);
        float3 col2 = vibrance(color.rgb);
        col = lerp(col, col2, _Mixture);
        
        col = lerp(color.rgb, col, step(0., uv.x - _Border));
        if (abs(uv.x - _Border) < .005 && _Border > 0 && _Border < 1) col = float3(1., 1., 0.);
        
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