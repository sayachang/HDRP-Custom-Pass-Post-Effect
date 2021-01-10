using UnityEngine;
using UnityEngine.Rendering.HighDefinition;
using UnityEngine.Rendering;

public class SobelPass : CustomPass
{
    public float thickness = 1;
    public bool luminous = false;
    [Range(1, 1024)]
    public float luminousPower = 1;
    public float threshold = 1;
    [ColorUsage(false, true)]
    public Color baseColor = Color.white;

    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    RTHandle rtBuffer;

    private void ShaderProperty(MaterialPropertyBlock property)
    {
        property.SetColor("_BaseColor", baseColor);
        property.SetFloat("_Thickness", thickness);
        property.SetFloat("_Threshold", threshold);
        property.SetFloat("_SobelPower", luminousPower);
        if (luminous)
            property.SetFloat("_Luminous", 1);
    }

    protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
    {
        shader = Shader.Find("FullScreen/SobelPass");
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
