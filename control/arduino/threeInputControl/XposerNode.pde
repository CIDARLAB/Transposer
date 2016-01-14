// This is a node in the graph visualization 
class XposerNode
{
  int stage;
  int level;
  boolean marked = false;
  String label;
  XposerNode pair;
  XposerNode nextNodeSameLevel;
  XposerNode nextNodeDiffLevel;

  XposerNode(String _label, int _level, int _stage) {
    label=_label;
    level=_level; 
    stage=_stage;
  }

  void markNode() {
    marked = true; 
  }

  void pairNode(XposerNode _pair) {
    pair = _pair;
  }

  void linkStraight(XposerNode _nextNodeSameLevel) {
    nextNodeSameLevel = _nextNodeSameLevel;
  }

  void linkCross(XposerNode _nextNodeDiffLevel) {
    nextNodeDiffLevel = _nextNodeDiffLevel;
  }

  ArrayList<XposerNode> adjacentNodes(XposerNode last){
    ArrayList<XposerNode> adjacent = new ArrayList<XposerNode>();
    //setting adjacent[0] to a straight connection will prioritize the uncrossed connection in the algorithm
    adjacent.add(last.nextNodeSameLevel);
    adjacent.add(last.nextNodeDiffLevel);
    for (XposerNode current : adjacent) {
      if (current != null){
	break;
      }
      else {
	return new ArrayList<XposerNode>();
      }
    }
    return new ArrayList<XposerNode>(adjacent);
  }
}
