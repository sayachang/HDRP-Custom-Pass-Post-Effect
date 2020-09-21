using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
public class MiscPass : CustomPass
{
    [Range(1, 2048)]
    public int mosaicBlock = 128;
    public bool nega = false;
    [Range(0.1f, 3)]
    public float negaIntensity = 1;
    public bool concentrated = false;

    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    MaterialPropertyBlock materialProperties;
    ShaderTagId[] shaderTags;
    RTHandle rtBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        shader = Shader.Find("FullScreen/MiscPass");
        material = CoreUtils.CreateEngineMaterial(shader);
        materialProperties = new MaterialPropertyBlock();
        shaderTags = new ShaderTagId[3]
        {
            new ShaderTagId("Forward"),
            new ShaderTagId("ForwardOnly"),
            new ShaderTagId("SRPDefaultUnlit"),
        };

        rtBuffer = RTHandles.Alloc(
            Vector2.one, TextureXR.slices, dimension: TextureXR.dimension,
            colorFormat: GraphicsFormat.B10G11R11_UFloatPack32,
            useDynamicScale: true, name: "RTBuffer"
        );
    }
    void DrawMeshes(ScriptableRenderContext renderContext, CommandBuffer cmd, HDCamera hdCamera, CullingResults cullingResult)
    {
        var result = new RendererListDesc(shaderTags, cullingResult, hdCamera.camera)
        {
            rendererConfiguration = PerObjectData.LightProbe | PerObjectData.LightProbeProxyVolume | PerObjectData.Lightmaps,
            renderQueueRange = RenderQueueRange.all,
            sortingCriteria = SortingCriteria.BackToFront,
            excludeObjectMotionVectors = false,
            layerMask = 0,
        };

        CoreUtils.SetRenderTarget(cmd, rtBuffer, ClearFlag.Color);
        HDUtils.DrawRendererList(renderContext, cmd, RendererList.Create(result));
    }
    protected override void Execute(ScriptableRenderContext renderContext, CommandBuffer cmd, HDCamera camera, CullingResults cullingResult)
    {
        DrawMeshes(renderContext, cmd, camera, cullingResult);
        SetCameraRenderTarget(cmd);

        materialProperties.SetInt("_MosaicBlock", mosaicBlock);
        if (concentrated)
            materialProperties.SetInt("_Concentrated", 1);
        if (nega)
            materialProperties.SetInt("_Nega", 1);
        materialProperties.SetFloat("_NegaIntensity", negaIntensity);

    CoreUtils.DrawFullScreen(cmd, material, materialProperties, shaderPassId: 0);
    }
    protected override void Cleanup()
    {
        CoreUtils.Destroy(material);
        rtBuffer.Release();
    }
}
