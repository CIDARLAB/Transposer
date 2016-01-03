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

  XposerNode(String _label, int _level, int _stage) {
    label=_label;
    level=_level; 
    stage=_stage;
  }

  void markNode() {
    marked = true; 
  }
}
