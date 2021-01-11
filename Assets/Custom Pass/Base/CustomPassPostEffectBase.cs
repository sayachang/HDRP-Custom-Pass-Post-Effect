using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace CustomPassPostEffect
{
    public class CustomPassPostEffectBase : CustomPass
    {
        const string BUFFER_TEXTURE = "_BufferTex";
        public LayerMask targetLayer = 0;
        public bool showInSceneView = false;

        [SerializeField, HideInInspector]
        Shader shader;
        Material material;
        RTHandle rtBuffer;

        protected virtual string ShaderName
        {
            get { return ""; }
        }

        protected virtual void ShaderProperty(MaterialPropertyBlock property)
        {
        }

        protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
        {
            shader = Shader.Find(ShaderName);
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
            if (targetLayer.value > 0)
            {
                CoreUtils.SetRenderTarget(customPassContext.cmd, rtBuffer);
                CustomPassUtils.DrawRenderers(customPassContext, targetLayer);
            }

            customPassContext.propertyBlock.SetTexture(BUFFER_TEXTURE, rtBuffer);
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
            get { return showInSceneView; }
        }
    }
}
