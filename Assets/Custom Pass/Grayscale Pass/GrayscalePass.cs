using UnityEngine;

namespace CustomPassPostEffect
{
    public class GrayscalePass : CustomPassPostEffectBase
    {
        [Tooltip("-1.0 to +1.0")]
        public Vector2 centre = new Vector2(0.5f, 0.5f);
        [Tooltip("0.0 to +3.0"), Range(0, 3)]
        public float rad = 2;
        public bool overrideColor = false;
        [ColorUsage(false, true)]
        public Color color = Color.gray;

        protected override string ShaderName
        {
            get { return "FullScreen/GrayscalePass"; }
        }

        protected override void ShaderProperty(MaterialPropertyBlock property)
        {
            property.SetVector("_Centre", centre);
            property.SetFloat("_Rad", rad);
            if (overrideColor)
            {
                property.SetFloat("_OverrideCol", 1);
            }
            property.SetColor("_Color", color);
        }
    }
}
