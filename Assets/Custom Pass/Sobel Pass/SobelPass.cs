using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
public class SobelPass : CustomPass
{
    [ColorUsage(false, true)]
    public Color outlineColor = Color.black;
    [ColorUsage(false, true)]
    public Color baseColor = Color.white;
    public float threshold = 1;
    public float thickness = 1;
    public bool senga = false;
    public bool nega = false;
    public bool lines = false;

    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    MaterialPropertyBlock materialProperties;
    ShaderTagId[] shaderTags;
    RTHandle rtBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        shader = Shader.Find("FullScreen/SobelPass");
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

        materialProperties.SetColor("_OutlineColor", outlineColor);
        materialProperties.SetColor("_BaseColor", baseColor);
        materialProperties.SetTexture("_OutlineBuffer", rtBuffer);
        materialProperties.SetFloat("_Threshold", threshold);
        materialProperties.SetFloat("_Thickness", thickness);
        if (senga)
            materialProperties.SetFloat("_Senga", 1);
        if (nega)
            materialProperties.SetFloat("_Nega", 1);
        if (lines)
            materialProperties.SetFloat("_Lines", 1);
        CoreUtils.DrawFullScreen(cmd, material, materialProperties, shaderPassId: 0);
    }
    protected override void Cleanup()
    {
        CoreUtils.Destroy(material);
        rtBuffer.Release();
    }
}
