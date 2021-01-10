using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

public class GrayscalePass : CustomPass
{
    [Tooltip("-1.0 to +1.0")]
    public Vector2 centre = new Vector2(0.5f, 0.5f);
    [Tooltip("0.0 to +3.0"), Range(0, 3)]
    public float rad = 2;
    public bool overrideColor = false;
    [ColorUsage(false, true)]
    public Color color = Color.gray;

    const string SHADER_NAME = "FullScreen/GrayscalePass";
    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    RTHandle rtBuffer;

    private void ShaderProperty(MaterialPropertyBlock property)
    {
        property.SetVector("_Centre", centre);
        property.SetFloat("_Rad", rad);
        if (overrideColor)
            property.SetFloat("_OverrideCol", 1);
        property.SetColor("_Color", color);
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
