Shader "FullScreen/KuwaharaPass"
{
    HLSLINCLUDE

#pragma vertex Vert

#pragma target 4.5
#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch

#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    int _Radius = 7;
    int _RadEx = 1;
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

        _Radius = clamp(_Radius, 0., 17.);

        float2 uv = posInput.positionNDC.xy;

        float3 mean[4] = {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        };

        float3 sigma[4] = {
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0},
            {0, 0, 0}
        };

        float2 start[4] = { {-_Radius, -_Radius}, {-_Radius, 0}, {0, -_Radius}, {0, 0} };

        float2 pos;
        float3 col;
        for (int k = 0; k < 4; k++) {
            for (int i = 0; i <= _Radius; i++) {
                for (int j = 0; j <= _Radius; j++) {
                    pos = float2(i, j) + start[k];
                    col = CustomPassSampleCameraColor(posInput.positionNDC.xy + float2(pos.x / _ScreenSize.x, pos.y / _ScreenSize.y), 0);
                    mean[k] += col;
                    sigma[k] += col * col;
                }
            }
        }

        float sigma2;
        float n = pow(_Radius + _RadEx, 2);
        float min = 1;

        for (int l = 0; l < 4; l++) {
            mean[l] /= n;
            sigma[l] = abs(sigma[l] / n - mean[l] * mean[l]);
            sigma2 = sigma[l].r + sigma[l].g + sigma[l].b;

            if (sigma2 < min) {
                min = sigma2;
                color.rgb = mean[l].rgb;
            }
        }

        float lum = dot(color.rgb, float3(.1, .7, .2));
        color.rgb *= (.5 + lum);
        return color;
    }

        ENDHLSL

        SubShader
    {
        Pass
        {
            Name "Kuwahara Pass"

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