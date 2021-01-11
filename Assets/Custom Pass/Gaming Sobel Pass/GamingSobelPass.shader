Shader "FullScreen/GamingSobelPass"
{
    HLSLINCLUDE
    #pragma vertex Vert
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone vulkan metal switch
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
    TEXTURE2D_X(_BufferTex);
    #define SAMPLES 8
    float4 _OutlineColor;
    float _SobelPower;
    float _Threshold;
    float _Thickness;
    float _UseBaseColor;
    float4 _BaseColor;
    float _Luminous;

    static float2 samples[SAMPLES] =
    {
        float2(1, 1),
        float2(0, 1),
        float2(-1, 1),
        float2(-1, 0),
        float2(-1, -1),
        float2(0, -1),
        float2(1, -1),
        float2(1, 0),
    };
    static float2 samplec[SAMPLES] =
    {
        float2(-1, 1),
        float2(0, 2),
        float2(1, 1),
        float2(2, 0),
        float2(1, -1),
        float2(0, -2),
        float2(-1, -1),
        float2(-2, 0),
    };

    float4 SamplePix(float2 uv) {
        return float4(CustomPassSampleCameraColor(uv, 0), 1);
    }

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
         UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);

        float2 uv = posInput.positionNDC.xy;
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(uv, 0), 1);
        color = float4(CustomPassSampleCameraColor(posInput.positionNDC.xy, 0), 1);

        float sobel = 0;
        float4 sh = 0, sv = 0;
        for (int i = 0; i < SAMPLES; i++)
        {
            float2 uvN = uv + _ScreenSize.zw * samples[i] * _Thickness;
            float4 neighbour = SamplePix(uvN);
                sh += neighbour * samplec[i].x;
                sv += neighbour * samplec[i].y;
        }

        if (_Luminous < 1) {
            return float4(sqrt(pow(sh * sh, 2) + pow(sv * sv, 2)).rgb, 1);
        }

        sobel = sqrt(pow(sh.r * sh.r, 2) + pow(sv.r * sv.r, 2)) * _SobelPower;
        sobel *= step(_Threshold, sobel);
        color.rgb = lerp(_BaseColor.rgb, color.rgb, sobel);
        //color pencil
        //color.rgb = 1-color.rgb;
        return color;
    }

    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Sobel Pass"

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
