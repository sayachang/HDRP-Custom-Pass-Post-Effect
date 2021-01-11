using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace CustomPassPostEffect
{
    public class MizutamaTransitionPass : CustomPass
    {
        public float size = 15.0f;
        public Color mizutamaColor = Color.white;
        [Range(0, 1)]
        public float gaming = 0.8f;
        [Range(0, 1)]
        public float outer = 0.8f;
        [Range(0, 1)]
        public float horizontal = 1.0f;

        const string SHADER_NAME = "FullScreen/MizutamaTransitionPass";
        [SerializeField, HideInInspector]
        Shader shader;
        Material material;
        RTHandle rtBuffer;

        private void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetTexture("_BufferTex", rtBuffer);
            property.SetFloat("_Size", size);
            property.SetColor("_MizutamaCol", mizutamaColor);
            property.SetFloat("_Gaming", gaming);
            property.SetFloat("_Mizutama", outer);
            property.SetFloat("_Horizontal", horizontal);
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
