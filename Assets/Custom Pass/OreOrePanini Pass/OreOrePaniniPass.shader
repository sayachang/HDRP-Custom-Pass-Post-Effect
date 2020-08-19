Shader "FullScreen/OreOrePaniniPass"
{
    HLSLINCLUDE
    #pragma vertex Vert
    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    float _D;
    float2 oreorePanini(float2 uv, float d)
    {
        float k = uv.x * uv.x / ((d + 1) * (d + 1));
        float dscr = k * k * d * d - (k + 1) * (k * d * d - 1);
        float clon = (-k * d + sqrt(dscr)) / (k + 1);
        float S = (d + 1) / (d + clon);
        float lon = atan2(uv.x, S * clon);
        float lat = atan2(uv.y, S);

        float clat = cos(lat);
        return float2(sin(lon) * clat, sin(lat));
        //cos(lon) * clat;
    }

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(posInput.positionNDC.xy, 0), 1);

        float2 uv = posInput.positionNDC.xy;
        float2 nuv = oreorePanini(uv, _D);
        color.rgb = CustomPassSampleCameraColor(nuv, 0);

        return color;
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "OreOrePanini Pass"

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