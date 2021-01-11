using UnityEngine;

namespace CustomPassPostEffect
{
    public class MonocolorPass : CustomPassPostEffectBase
    {
        public Color color = Color.white;

        protected override string ShaderName
        {
            get { return "FullScreen/MonocolorPass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetColor("_Color", color);
        }
    }
}
