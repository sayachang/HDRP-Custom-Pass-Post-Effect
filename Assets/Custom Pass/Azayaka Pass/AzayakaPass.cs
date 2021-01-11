using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace CustomPassPostEffect
{
    public class AzayakaPass : CustomPass
    {
        [Range(0.0f, 0.5f)]
        public float azayakaL = 0.5f;
        [Range(0.5f, 1.0f)]
        public float azayakaR = 0.5f;
        [Range(0, 2)]
        public float value = 2.0f;
        [Range(0, 2)]
        public float vibranceAmount = 1.0f;
        [Range(0, 1)]
        public float mixture = 0.33f;
        [Range(0, 1)]
        public float border = 0.5f;

        const string SHADER_NAME = "FullScreen/AzayakaPass";
        [SerializeField, HideInInspector]
        Shader shader;
        Material material;
        RTHandle rtBuffer;

        private void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetFloat("_AzayakaL", azayakaL);
            property.SetFloat("_AzayakaR", azayakaR);
            property.SetFloat("_Value", value);
            property.SetFloat("_VibranceAmount", vibranceAmount);
            property.SetFloat("_Mixture", mixture);
            property.SetFloat("_Border", border);
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
