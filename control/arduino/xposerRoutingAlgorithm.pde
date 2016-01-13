/**
 * Simmple graph layout system
 * http://processingjs.nihongoresources.com/graphs
 * This code is in the public domain
 */

/**
 * Flow algorithm that positions nodes by
 * prentending the links are elastic. This
 * is a multiple-step algorithm, and has
 * to be run several times before it's "done".
 */
class XposerRoutingAlgorithm implements FlowAlgorithm
//class XposerRoutingAlgorithm 
{

  boolean reflow(DirectedGraph g)
  {
    ArrayList<Node> nodes = g.getNodes();
    int reset = 0;
    for(Node n: nodes)
    {
      ArrayList<Node> incoming = n.getIncomingLinks();
      ArrayList<Node> outgoing = n.getOutgoingLinks();
      // compute the total push force acting on this node
      int dx = 0;
      int dy = 0;
      for(Node ni: incoming) {
        dx += (ni.x-n.x);
        dy += (ni.y-n.y); }
      float len = sqrt(dx*dx + dy*dy);
      float angle = getDirection(dx, dy);
    }
    return reset==nodes.size();
  }
}
