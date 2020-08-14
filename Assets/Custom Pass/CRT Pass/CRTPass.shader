Shader "FullScreen/CRTPass"
{
    HLSLINCLUDE

#pragma vertex Vert

#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    float2 barrel(float2 uv) {
        float s1 = .99, s2 = .125;
        float2 centre = 2. * uv - 1.;
        float barrel = min(1. - length(centre) * s1, 1.0) * s2;
        return uv - centre * barrel;
    }

    float2 CRT(float2 uv)
    {
        float2 nu = uv * 2. - 1.;
        float2 offset = abs(nu.yx) / float2(6.4, 4.8);
        nu += nu * offset * offset;
        return nu;
    }

    float Scanline(float2 uv)
    {
        float scanline = clamp(0.95 + 0.05 * cos(3.14 * (uv.y + 0.008 * floor(_Time.y * 15.) / 15.) * 240.0 * 1.0), 0.0, 1.0);
        float grille = 0.85 + 0.15 * clamp(1.5 * cos(3.14 * uv.x * 640.0 * 1.0), 0.0, 1.0);
        return clamp(scanline * grille * .85, .0, 1.);
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

        // barrel distortion
        float2 p = barrel(posInput.positionNDC.xy);
        float3 col = CustomPassSampleCameraColor(p, 0);
        col = clamp(col, .0, 1.);

        // color grading
        col *= float3(1.25, 0.95, 0.7);

        // scanline
        col.rgb *= Scanline(posInput.positionNDC.xy);

        // crt monitor
        float2 crt = CRT(posInput.positionNDC.xy);
        crt = abs(crt);
        crt = pow(crt, 15.);
        col.rgb = lerp(col.rgb, (.0).xxx, crt.x + crt.y);

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