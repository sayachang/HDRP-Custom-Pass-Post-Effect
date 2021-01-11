Shader "FullScreen/CRTPass"
{
HLSLINCLUDE
#pragma vertex Vert
#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
TEXTURE2D_X(_BufferTex);
    float2 barrel(float2 uv) {
        float s1 = 0.99, s2 = 0.125;
        float2 centre = 2.0 * uv - 1.0;
        float barrel = min(1.0 - length(centre) * s1, 1.0) * s2;
        return uv - centre * barrel;
    }

    float2 CRT(float2 uv)
    {
        float2 nuv = 2.0 * uv - 1.0;
        float2 offset = abs(nuv.yx) / float2(_ScreenSize.x, _ScreenSize.y);
        nuv += nuv * offset * offset;
        return nuv;
    }

    float scanline(float2 uv)
    {
        float scanline = clamp(0.95 + 0.05 * cos(PI * (uv.y + 0.008 * floor(_Time.y * 15.0) / 15.0) * 240.0), 0.0, 1.0);
        float grille = 0.85 + 0.15 * clamp(1.5 * cos(PI * uv.x * 640.0 * 1.0), 0.0, 1.0);
        return clamp(scanline * grille * 0.85, 0.0, 1.0);
    }

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        float2 uv = posInput.positionNDC.xy;
        // Load the camera color buffer at the mip 0 if we're not at the before rendering injection point
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(uv, 0), 1);

        // barrel distortion
        float2 p = barrel(uv);
        float3 col = CustomPassSampleCameraColor(p, 0);
        col = clamp(col, .0, 1.);

        // color grading
        col *= float3(1.25, 0.95, 0.7);

        // scanline
        col.rgb *= scanline(uv);

        // crt monitor
        float2 crt = CRT(uv);
        crt = abs(crt);
        crt = pow(crt, 15.0);
        col.rgb = lerp(col.rgb, (0.0).xxx, crt.x + crt.y);

        color.rgb = col;
        return color;
    }

ENDHLSL

    SubShader
    {
        Pass
        {
            Name "CRT Pass"

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