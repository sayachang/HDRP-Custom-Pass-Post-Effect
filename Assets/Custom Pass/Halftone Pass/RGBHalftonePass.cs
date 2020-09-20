using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
public class RGBHalftonePass : CustomPass
{
    public float freq = 80;
    public float radM = 2.5f;
    public float radA = 0.5f;
    [ColorUsage(false, true)]
    public Color toneColor = Color.red;
    [Range(0, 1)]
    public float addOriginal = 0.75f;
    [SerializeField, HideInInspector]
    Shader halftoneShader;

    Material fullscreenMaterial;
    MaterialPropertyBlock materialProperties;
    ShaderTagId[] shaderTags;
    RTHandle rtBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        halftoneShader = Shader.Find("FullScreen/RGBHalftonePass");
        fullscreenMaterial = CoreUtils.CreateEngineMaterial(halftoneShader);
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
            useDynamicScale: true, name: "RGBHalftone Buffer"
        );
    }
    void DrawMeshes(ScriptableRenderContext renderContext, CommandBuffer cmd, HDCamera hdCamera, CullingResults cullingResult)
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
        DrawMeshes(renderContext, cmd, hdCamera, cullingResult);

        SetCameraRenderTarget(cmd);

        materialProperties.SetFloat("_Freq", freq);
        materialProperties.SetFloat("_RadM", radM);
        materialProperties.SetFloat("_RadA", radA);
        materialProperties.SetColor("_ToneColor", toneColor);
        materialProperties.SetFloat("_AddOrg", addOriginal);
        CoreUtils.DrawFullScreen(cmd, fullscreenMaterial, materialProperties, shaderPassId: 0);
    }
    protected override void Cleanup()
    {
        CoreUtils.Destroy(fullscreenMaterial);
        rtBuffer.Release();
    }
}
