Shader "FullScreen/MiscPass"
{
    HLSLINCLUDE
    #pragma vertex Vert
    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    int _MosaicBlock;
    int _Concentrated;
    int _Nega;
    float _NegaIntensity;

    float concentrated(float2 p)
    {
        float2 uv = 2. * p - 1.;
        float r = length(uv);
        r = 0.7 * r - 0.7;
        float a = atan2(uv.y, uv.x);
        a = abs(cos(50. * a) + sin(20. * a));
        float d = a - r;
        float n = smoothstep(0.1, 0.4, saturate(d));
        return n;
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
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(nuv, 0), 1);
        else {
            //color = CustomPassSampleBufferColor();
        }

        // Mosaic
        float mosaicFactor = 1.0 / float(_MosaicBlock);
        float2 mosaicUV = 0.5 * (ceil(nuv / mosaicFactor) + floor(nuv / mosaicFactor)) * mosaicFactor;
        float3 mosaicCol = CustomPassSampleCameraColor(mosaicUV, 0);
        color.rgb = mosaicCol;

        // Nega
        if (_Nega > 0)
            color.rgb = _NegaIntensity - color.rgb;

        // Concentrated
        if (_Concentrated > 0) {
            float concentratedCol = concentrated(nuv);
            color.rgb *= concentratedCol;
        }

        return color;
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Misc Pass"

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