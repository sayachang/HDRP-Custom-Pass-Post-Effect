using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

public class OutlinePass : CustomPass
{
    public LayerMask outlineLayer = 0;
    [ColorUsage(false, true)]
    public Color outlineColor = Color.black;
    public float threshold = 1;
    public float thickness = 1;

    const string SHADER_NAME = "FullScreen/OutlinePass";
    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    RTHandle rtBuffer;

    private void ShaderProperty(MaterialPropertyBlock property)
    {
        property.SetColor("_OutlineColor", outlineColor);
        property.SetTexture("_OutlineBuffer", rtBuffer);
        property.SetFloat("_Threshold", threshold);
        property.SetFloat("_Thickness", thickness);
    }

    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        shader = Shader.Find(SHADER_NAME);
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
        CoreUtils.SetRenderTarget(customPassContext.cmd, rtBuffer);
        CustomPassUtils.DrawRenderers(customPassContext, outlineLayer);
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
