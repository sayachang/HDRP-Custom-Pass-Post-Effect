using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
public class GrayscalePass : CustomPass
{
    [Tooltip("-1.0 to +1.0")]
    public Vector2 centre = new Vector2(0, 0);
    [Tooltip("0.0 to +3.0"), Range(0, 3)]
    public float rad = 1;
    public bool overrideColor = false;
    [ColorUsage(false, true)]
    public Color color = Color.white;
    [SerializeField, HideInInspector]
    Shader shader;

    Material fullscreenMaterial;
    MaterialPropertyBlock materialProperties;
    ShaderTagId[] shaderTags;
    RTHandle rtBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        shader = Shader.Find("FullScreen/GrayscalePass");
        fullscreenMaterial = CoreUtils.CreateEngineMaterial(shader);
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
            useDynamicScale: true, name: "Gray Buffer"
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

        materialProperties.SetVector("_Centre", centre);
        materialProperties.SetFloat("_Rad", rad);
        if (overrideColor)
            materialProperties.SetFloat("_OverrideCol", 1);
        materialProperties.SetColor("_Color", color);
        CoreUtils.DrawFullScreen(cmd, fullscreenMaterial, materialProperties, shaderPassId: 0);
    }
    protected override void Cleanup()
    {
        CoreUtils.Destroy(fullscreenMaterial);
        rtBuffer.Release();
    }
}
