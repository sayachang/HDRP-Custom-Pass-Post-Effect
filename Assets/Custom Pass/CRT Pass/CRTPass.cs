namespace CustomPassPostEffect
{
    public class CRTPass : CustomPassPostEffectBase
    {
        protected override string ShaderName
        {
            get { return "FullScreen/CRTPass"; }
        }
    }
}
