
module ashd.core.iengine;


import ashd.core.nodelist : NodeList;
import ashd.core.ifamily  : IFamily;

interface IEngine
{
    public NodeList getNodeList(N)( IFamily delegate() createInstance_a=null );
    public NodeList getNodeList( ClassInfo nodeType_a, IFamily delegate() createInstance_a=null);
}

