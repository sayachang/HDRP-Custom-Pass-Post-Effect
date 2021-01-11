using UnityEngine;

namespace CustomPassPostEffect
{
    public class OutlinePass : CustomPassPostEffectBase
    {
        [ColorUsage(false, true)]
        public Color outlineColor = Color.black;
        public float threshold = 1;
        public float thickness = 1;

        protected override string ShaderName
        {
            get { return "FullScreen/OutlinePass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetColor("_OutlineColor", outlineColor);
            property.SetFloat("_Threshold", threshold);
            property.SetFloat("_Thickness", thickness);
        }
    }
}
