using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
public class AzayakaPass : CustomPass
{
    [Range(-0.1f, 0.1f)]
    public float chromaAdd = 0.05f;
    [Range(0, 2)]
    public float chromaMul = 1.3f;
    [Range(0, 1)]
    public float valueAdd = 0.33f;
    [Range(0, 2)]
    public float valueMul = 2.0f;
    [Range(0, 1)]
    public float border = 0.5f;
    [SerializeField, HideInInspector]
    Shader rainShader;

    Material fullscreenMaterial;
    MaterialPropertyBlock materialProperties;
    ShaderTagId[] shaderTags;
    RTHandle rtBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        rainShader = Shader.Find("FullScreen/AzayakaPass");
        fullscreenMaterial = CoreUtils.CreateEngineMaterial(rainShader);
        materialProperties = new MaterialPropertyBlock();

        // List all the materials that will be replaced in the frame
        shaderTags = new ShaderTagId[3]
        {
            new ShaderTagId("Forward"),
            new ShaderTagId("ForwardOnly"),
            new ShaderTagId("SRPDefaultUnlit"),
        };

        rtBuffer = RTHandles.Alloc(
            Vector2.one, TextureXR.slices, dimension: TextureXR.dimension,
            colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
            useDynamicScale: true, name: "Azayaka Buffer"
        );
    }
    void DrawOutlineMeshes(ScriptableRenderContext renderContext, CommandBuffer cmd, HDCamera hdCamera, CullingResults cullingResult)
    {
        var result = new RendererListDesc(shaderTags, cullingResult, hdCamera.camera)
        {
            // We need the lighting render configuration to support rendering lit objects
            rendererConfiguration = PerObjectData.LightProbe | PerObjectData.LightProbeProxyVolume | PerObjectData.Lightmaps,
            renderQueueRange = RenderQueueRange.all,
            sortingCriteria = SortingCriteria.BackToFront,
            excludeObjectMotionVectors = false,
            layerMask = 0,
        };

        CoreUtils.SetRenderTarget(cmd, rtBuffer, ClearFlag.Color);
        HDUtils.DrawRendererList(renderContext, cmd, RendererList.Create(result));
    }
    protected override void Execute(ScriptableRenderContext renderContext, CommandBuffer cmd, HDCamera hdCamera, CullingResults cullingResult)
    {
        DrawOutlineMeshes(renderContext, cmd, hdCamera, cullingResult);

        SetCameraRenderTarget(cmd);

        materialProperties.SetTexture("_BufferTex", rtBuffer);
        materialProperties.SetFloat("_ChromaAdd", chromaAdd);
        materialProperties.SetFloat("_ChromaMul", chromaMul);
        materialProperties.SetFloat("_ValueAdd", valueAdd);
        materialProperties.SetFloat("_ValueMul", valueMul);
        materialProperties.SetFloat("_Border", border);
        CoreUtils.DrawFullScreen(cmd, fullscreenMaterial, materialProperties, shaderPassId: 0);
    }
    protected override void Cleanup()
    {
        CoreUtils.Destroy(fullscreenMaterial);
        rtBuffer.Release();
    }
}
