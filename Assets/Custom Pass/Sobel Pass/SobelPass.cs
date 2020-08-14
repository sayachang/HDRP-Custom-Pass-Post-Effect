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
    public float senga = 0;
    public float nega = 0;
    public float lines = 0;
    [SerializeField, HideInInspector]
    Shader sobelShader;

    Material fullscreenMaterial;
    MaterialPropertyBlock materialProperties;
    ShaderTagId[] shaderTags;
    RTHandle rtBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        sobelShader = Shader.Find("FullScreen/SobelPass");
        fullscreenMaterial = CoreUtils.CreateEngineMaterial(sobelShader);
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
            useDynamicScale: true, name: "Sobel Buffer"
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
        materialProperties.SetFloat("_Senga", senga);
        materialProperties.SetFloat("_Nega", nega);
        materialProperties.SetFloat("_Lines", lines);
        CoreUtils.DrawFullScreen(cmd, fullscreenMaterial, materialProperties, shaderPassId: 0);
    }
    protected override void Cleanup()
    {
        CoreUtils.Destroy(fullscreenMaterial);
        rtBuffer.Release();
    }
}
