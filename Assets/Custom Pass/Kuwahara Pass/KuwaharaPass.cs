using UnityEngine;

namespace CustomPassPostEffect
{
    public class KuwaharaPass : CustomPassPostEffectBase
    {
        [Range(0, 16)]
        public int radius = 7;
        public int radExpand = 1;

        protected override string ShaderName
        {
            get { return "FullScreen/KuwaharaPass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetInt("_Radius", radius);
            property.SetInt("_RadEx", radExpand);
        }
    }
}
