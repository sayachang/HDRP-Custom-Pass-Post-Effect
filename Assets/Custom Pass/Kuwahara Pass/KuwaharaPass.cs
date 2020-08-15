﻿using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering;
public class KuwaharaPass : CustomPass
{
    [Range(0, 16)]
    public int radius = 7;
    public int radExpand = 1;

    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    MaterialPropertyBlock materialProperties;
    ShaderTagId[] shaderTags;
    RTHandle rtBuffer;
    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        shader = Shader.Find("FullScreen/KuwaharaPass");
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
    void DrawOutlineMeshes(ScriptableRenderContext renderContext, CommandBuffer cmd, HDCamera hdCamera, CullingResults cullingResult)
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
    protected override void Execute(ScriptableRenderContext renderContext, CommandBuffer cmd, HDCamera hdCamera, CullingResults cullingResult)
    {
        DrawOutlineMeshes(renderContext, cmd, hdCamera, cullingResult);
        SetCameraRenderTarget(cmd);

        materialProperties.SetInt("_Radius", radius);
        materialProperties.SetInt("_RadEx", radExpand);
        CoreUtils.DrawFullScreen(cmd, material, materialProperties, shaderPassId: 0);
    }
    protected override void Cleanup()
    {
        CoreUtils.Destroy(material);
        rtBuffer.Release();
    }
}
