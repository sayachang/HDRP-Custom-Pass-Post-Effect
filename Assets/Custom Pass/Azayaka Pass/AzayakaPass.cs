using UnityEngine;

namespace CustomPassPostEffect
{
    public class AzayakaPass : CustomPassPostEffectBase
    {
        [Range(0.0f, 0.5f)]
        public float azayakaLeft = 0.5f;
        [Range(0.5f, 1.0f)]
        public float azayakaRight = 0.5f;
        [Range(0, 2)]
        public float value = 2.0f;
        [Range(0, 2)]
        public float vibranceAmount = 1.0f;
        [Range(0, 1)]
        public float mixture = 0.33f;
        [Range(0, 1)]
        public float border = 0.5f;

        protected override string ShaderName
        {
            get { return "FullScreen/AzayakaPass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetFloat("_AzayakaL", azayakaLeft);
            property.SetFloat("_AzayakaR", azayakaRight);
            property.SetFloat("_Value", value);
            property.SetFloat("_VibranceAmount", vibranceAmount);
            property.SetFloat("_Mixture", mixture);
            property.SetFloat("_Border", border);
        }
    }
}
