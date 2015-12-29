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

  XposerNode(int _level, int _stage) {
    level=_level; 
    stage=_stage;
  }
}
