using UnityEngine;

namespace CustomPassPostEffect
{
    public class MiscPass : CustomPassPostEffectBase
    {
        [Range(1, 2048)]
        public int mosaicBlock = 128;
        public bool nega = false;
        [Range(0.1f, 3)]
        public float negaIntensity = 1;
        public bool concentrated = false;

        protected override string ShaderName
        {
            get { return "FullScreen/MiscPass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetInt("_MosaicBlock", mosaicBlock);
            if (concentrated)
            {
                property.SetInt("_Concentrated", 1);
            }
            if (nega)
            {
                property.SetInt("_Nega", 1);
            }
            property.SetFloat("_NegaIntensity", negaIntensity);
        }
    }
}
