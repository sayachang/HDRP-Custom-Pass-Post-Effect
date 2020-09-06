Shader "FullScreen/OreOrePaniniPass"
{
    HLSLINCLUDE
    #pragma vertex Vert
    #pragma target 4.5
    #pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    float _Panini;
    float _D;
    float2 panini(float2 uv, float d)
    {
        float x = 2.0 * uv.x - 1.0;
        float y = 2.0 * uv.y - 1.0;
        float D = 1.0 + d;
        float sq = x * x + D * D;
        float xd = x * d;
        float sec = sq - xd * xd;

        float cyld = (-xd * x + D * sqrt(sec)) / sq;
        float cyldd = cyld + d;

        return float2(x,y) * (cyldd / D) / (cyldd - d) *.5+.5;

        return float2(x,y);
        
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
        float2 nuv = panini(uv, _D);

        nuv.xy = lerp(uv, nuv.xy, _Panini);
        color.rgb = CustomPassSampleCameraColor(nuv.xy, 0);

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