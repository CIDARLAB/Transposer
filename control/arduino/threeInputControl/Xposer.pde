//topLeftNode must always fall on even levels/odd stages or odd stages/even levels

public class Xposer {
  Boolean crossed;
  Pump outside;
  Pump inside;
  XposerNode topLeftNode;

  Xposer(XposerNode _topLeftNode) {
    topLeftNode = _topLeftNode;
  }

  void actuateCross(int uStepsMoveO, int uStepsMoveI) {
    outside.dispense(uStepsMoveO, true);
    inside.dispense(uStepsMoveI, false);
  }
////
  void actuateStraight(int uStepsMoveO, int uStepsMoveI) {
    outside.dispense(uStepsMoveO, false);
    inside.dispense(uStepsMoveI, true);
  }

  //void actuateCross(int uStepsMove) {
    //outside.dispense(uStepsMove, true);
    //inside.dispense(uStepsMove, false);
  //}
//
  //void actuateStraight(int uStepsMoveO) {
    //outside.dispense(uStepsMove, false);
    //inside.dispense(uStepsMove, true);
  //}

  boolean getCrossedStatus() { return crossed; }

  void linkPumps(Pump _outside, Pump _inside){
    outside = _outside;
    inside = _inside;
  }

  void cross() {
    Node linknode1;
    Node linknode2;
    Node linknode1p;
    Node linknode2p;
    linknode1 = nodes.get(findIndex(topLeftNode.level,topLeftNode.stage));
    linknode2 = nodes.get(findNextIndex(topLeftNode.level+1,topLeftNode.stage+1));
    linknode1p = nodes.get(findIndex(topLeftNode.level+1,topLeftNode.pair.stage));
    linknode2p = nodes.get(findNextIndex(topLeftNode.level,topLeftNode.stage+1));
    g.linkNodes(linknode1, linknode2);
    g.linkNodes(linknode1p, linknode2p); 
    crossed = true;
  }
  
  void straight() {
    Node linknode1;
    Node linknode2;
    Node linknode1p;
    Node linknode2p;
    linknode1 = nodes.get(findIndex(topLeftNode.level,topLeftNode.stage));
    linknode2 = nodes.get(findNextIndex(topLeftNode.level,topLeftNode.stage+1));
    linknode1p = nodes.get(findIndex(topLeftNode.level+1,topLeftNode.stage));
    linknode2p = nodes.get(findNextIndex(topLeftNode.level+1,topLeftNode.stage+1));
    g.linkNodes(linknode1, linknode2); 
    g.linkNodes(linknode1p, linknode2p); 
    crossed = false;
  }
}  
