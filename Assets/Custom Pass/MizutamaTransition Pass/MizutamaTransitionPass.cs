using UnityEngine;

namespace CustomPassPostEffect
{
    public class MizutamaTransitionPass : CustomPassPostEffectBase
    {
        public float size = 15.0f;
        public Color mizutamaColor = Color.white;
        [Range(0, 1)]
        public float gaming = 0.8f;
        [Range(0, 1)]
        public float outer = 0.8f;
        [Range(0, 1)]
        public float horizontal = 1.0f;

        protected override string ShaderName
        {
            get { return "FullScreen/MizutamaTransitionPass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetFloat("_Size", size);
            property.SetColor("_MizutamaCol", mizutamaColor);
            property.SetFloat("_Gaming", gaming);
            property.SetFloat("_Mizutama", outer);
            property.SetFloat("_Horizontal", horizontal);
        }
    }
}
