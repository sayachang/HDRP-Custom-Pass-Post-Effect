﻿using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;

namespace CustomPassPostEffect
{
    public class MonocolorPass : CustomPass
    {
        public Color color = Color.white;

        const string SHADER_NAME = "FullScreen/MonocolorPass";
        [SerializeField, HideInInspector]
        Shader shader;
        Material material;
        RTHandle rtBuffer;

        private void ShaderProperty(MaterialPropertyBlock property)
        {
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
}
