using UnityEngine;

namespace CustomPassPostEffect
{
    public class RainPass : CustomPassPostEffectBase
    {
        [Range(0, 1)]
        public float rainAmount = 0.5f;
        [Range(0, 1)]
        public float density = 0.5f;
        [Range(0, 3)]
        public float zoom = 1.0f;
        [Range(0, 10)]
        public float speed = 0.25f;

        protected override string ShaderName
        {
            get { return "FullScreen/RainPass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetFloat("_RainAmount", rainAmount);
            property.SetFloat("_Density", density);
            property.SetFloat("_Zoom", zoom);
            property.SetFloat("_Speed", speed);
        }
    }
}
