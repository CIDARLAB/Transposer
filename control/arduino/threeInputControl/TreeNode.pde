// This is a node in the routing tree 
class TreeNode
{
  int input;
  int level;
  boolean visited = false;
  boolean visiting = false;
  ArrayList<XposerNode> path = new ArrayList<XposerNode>();
  ArrayList<TreeNode> parents = new ArrayList<TreeNode>();
  ArrayList<TreeNode> children = new ArrayList<TreeNode>();

  TreeNode(int _input, ArrayList<XposerNode> _path, int _level) {
    input=_input;
    path=_path; 
    level=_level;
  }

  void visitNode() {
    visiting = true; 
  }

  void addParent(TreeNode parent) {
    parents.add(parent);
  } 

  void finishNode() {
    visiting = false;
    visited = true;
  }

  void addChild(TreeNode child) {
    children.add(child);
  }

  ArrayList<TreeNode> getChildren() {
    return children;
  }

  ArrayList<TreeNode> getParents() {
    return parents;
  }
  
  ArrayList<XposerNode> getPath() {
    return path;
  }
}
