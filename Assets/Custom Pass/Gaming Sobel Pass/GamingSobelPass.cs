using UnityEngine;

namespace CustomPassPostEffect
{
    public class GamingSobelPass : CustomPassPostEffectBase
    {
        public float thickness = 1;
        public bool luminous = false;
        [Range(1, 1024)]
        public float luminousPower = 1;
        public float threshold = 1;
        [ColorUsage(false, true)]
        public Color baseColor = Color.white;

        protected override string ShaderName
        {
            get { return "FullScreen/GamingSobelPass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetColor("_BaseColor", baseColor);
            property.SetFloat("_Thickness", thickness);
            property.SetFloat("_Threshold", threshold);
            property.SetFloat("_SobelPower", luminousPower);
            if (luminous)
            {
                property.SetFloat("_Luminous", 1);
            }
        }
    }
}
