Shader "FullScreen/SobelPass"
{
    HLSLINCLUDE
    #pragma vertex Vert
    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone vulkan metal switch
    #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"

    #define SAMPLES 8
    float4 _OutlineColor;
    float4 _BaseColor;
    float _Threshold;
    float _Thickness;
    float _Senga;
    float _Nega;
    float _Lines;
    float _Lumin;

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

        // Load the camera color buffer at the mip 0 if we're not at the before rendering injection point
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassSampleCameraColor(posInput.positionNDC.xy, 0), 1);

        // When sampling RTHandle texture, always use _RTHandleScale.xy to scale your UVs first.
        float2 uv = posInput.positionNDC.xy;

        float sobel = 0;
        float4 sh = 0, sv = 0;
        for (int i = 0; i < SAMPLES; i++)
        {
            float2 uvN = uv + _ScreenSize.zw * samples[i] * _Thickness;
            float4 neighbour = SamplePix(uvN);
            if (_Senga < 1) {
                sh += min(max(neighbour, 0), 0) * samplec[i].x;
                sv += min(max(neighbour, 0), 0) * samplec[i].y;
            }
            else {
                sh += neighbour * samplec[i].x;
                sv += neighbour * samplec[i].y;
            }
        }

        if (_Senga < 1) {
            sobel = sqrt(sh.r * sh.r + sv.r * sv.r);
        }
        else {
            sobel = sqrt(pow(sh.r * sh.r, 2) + pow(sv.r * sv.r, 2)) * 128;
        }

        if (_Lines >= 1)
            color.rgb = lerp(_BaseColor.rgb, color.rgb, sobel);

        if (_Nega >= 1)
            color.rgb = lerp(_OutlineColor.rgb, color.rgb, sobel);
        else
            color.rgb = lerp(color.rgb, _OutlineColor.rgb,  sobel);
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
