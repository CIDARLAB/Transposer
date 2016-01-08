/**
 * Simmple graph layout system
 * http://processingjs.nihongoresources.com/graphs
 * This code is in the public domain
 */

// This is a generic node in a graph
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
}
