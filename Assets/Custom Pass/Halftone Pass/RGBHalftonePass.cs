using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

public class RGBHalftonePass : CustomPass
{
    public float freq = 80;
    public float radM = 2.5f;
    public float radA = 0.5f;
    [ColorUsage(false, true)]
    public Color toneColor = Color.red;
    [Range(0, 1)]
    public float addOriginal = 0.0f;

    const string SHADER_NAME = "FullScreen/RGBHalftonePass";
    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    RTHandle rtBuffer;

    private void ShaderProperty(MaterialPropertyBlock property)
    {
        property.SetFloat("_Freq", freq);
        property.SetFloat("_RadM", radM);
        property.SetFloat("_RadA", radA);
        property.SetColor("_ToneColor", toneColor);
        property.SetFloat("_AddOrg", addOriginal);
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
        ShaderProperty(customPassContext.propertyBlock);
        CoreUtils.SetRenderTarget(customPassContext.cmd, customPassContext.cameraColorBuffer);
        CoreUtils.DrawFullScreen(customPassContext.cmd, material, customPassContext.propertyBlock, shaderPassId: 0);
    }

    protected override void Cleanup()
    {
        CoreUtils.Destroy(material);
        rtBuffer.Release();
    }

    protected override bool executeInSceneView
    {
        get { return false; }
    }
}
