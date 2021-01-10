using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;

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

    private void ShaderProperty(MaterialPropertyBlock property)
    {
        property.SetInt("_Radius", radius);
        property.SetInt("_RadEx", radExpand);
    }

    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        shader = Shader.Find("FullScreen/KuwaharaPass");
        material = CoreUtils.CreateEngineMaterial(shader);

        rtBuffer = RTHandles.Alloc(
            Vector2.one,
            TextureXR.slices,
            dimension: TextureXR.dimension,
            useDynamicScale: true,
            name: "RTBuffer"
        );
    }
    protected override void Execute(CustomPassContext customPassContext)
    {
        ShaderProperty(customPassContext.propertyBlock);
        CoreUtils.SetRenderTarget(customPassContext.cmd, customPassContext.cameraColorBuffer);
        CoreUtils.DrawFullScreen(customPassContext.cmd, material, customPassContext.propertyBlock, shaderPassId: 0);
    }

    protected override void Cleanup()
    {
        CoreUtils.Destroy(material);
        rtBuffer.Release();
    }
}
