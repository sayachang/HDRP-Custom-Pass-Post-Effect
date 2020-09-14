Shader "FullScreen/AzayakaPass"
{
HLSLINCLUDE
#pragma vertex Vert
#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    TEXTURE2D_X(_BufferTex);
    float _AzayakaR;
    float _AzayakaL;
    float _Value;
    float _VibranceAmount;
    float _Mixture;
    float _Border;
    static float3 BT601 = float3(0.298912, 0.586611, 0.114478);

    float bt601Lum(float3 c) {
        return dot(c, BT601);
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