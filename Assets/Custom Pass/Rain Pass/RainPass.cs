using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace CustomPassPostEffect
{
    public class RainPass : CustomPass
    {
        [Range(0, 1)]
        public float rainAmount = 0.5f;
        [Range(0, 1)]
        public float density = 0.5f;
        [Range(0, 3)]
        public float zoom = 1.0f;
        [Range(0, 10)]
        public float speed = 0.25f;

        const string SHADER_NAME = "FullScreen/RainPass";
        [SerializeField, HideInInspector]
        Shader shader;
        Material material;
        RTHandle rtBuffer;

        private void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetTexture("_BufferTex", rtBuffer);
            property.SetFloat("_RainAmount", rainAmount);
            property.SetFloat("_Density", density);
            property.SetFloat("_Zoom", zoom);
            property.SetFloat("_Speed", speed);
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
}
