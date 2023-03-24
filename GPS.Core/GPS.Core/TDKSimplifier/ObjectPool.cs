using Toyota.Common.Lookup;

namespace GPS.Core.TDKSimplifier
{
    // NOTE: this class is extracted from Toyota.Common.Web.Platform.ObjectPool
    public static class ObjectPool
    {
        public static InstanceManager Factory { get; private set; }

        public static IProxyLookup Lookup { get; private set; }

        static ObjectPool()
        {
            Lookup = (IProxyLookup)new SimpleProxyLookup();
            Factory = new InstanceManager();
            Factory.AttachToProxyLookup(Lookup);
        }
    }
}