using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

public class MiscPass : CustomPass
{
    [Range(1, 2048)]
    public int mosaicBlock = 128;
    public bool nega = false;
    [Range(0.1f, 3)]
    public float negaIntensity = 1;
    public bool concentrated = false;

    const string SHADER_NAME = "FullScreen/MiscPass";
    [SerializeField, HideInInspector]
    Shader shader;
    Material material;
    RTHandle rtBuffer;


    protected override bool executeInSceneView {
        get{ return false; }
    }
    

    private void ShaderProperty(MaterialPropertyBlock property)
    {
        property.SetInt("_MosaicBlock", mosaicBlock);
        if (concentrated)
            property.SetInt("_Concentrated", 1);
        if (nega)
            property.SetInt("_Nega", 1);
        property.SetFloat("_NegaIntensity", negaIntensity);
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
}
