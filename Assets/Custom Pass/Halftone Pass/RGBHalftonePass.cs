using UnityEngine;

namespace CustomPassPostEffect
{
    public class RGBHalftonePass : CustomPassPostEffectBase
    {
        public float freq = 80;
        public float radM = 2.5f;
        public float radA = 0.5f;
        [ColorUsage(false, true)]
        public Color toneColor = Color.red;
        [Range(0, 1)]
        public float addOriginal = 0.0f;

        protected override string ShaderName
        {
            get { return "FullScreen/RGBHalftonePass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetFloat("_Freq", freq);
            property.SetFloat("_RadM", radM);
            property.SetFloat("_RadA", radA);
            property.SetColor("_ToneColor", toneColor);
            property.SetFloat("_AddOrg", addOriginal);
        }
    }
}
