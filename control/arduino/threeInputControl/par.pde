//  Methods for placing and routing nodes

void populateNodes() {
  int count=0;

  //Populate xposer nodes
  //Determine number of nodes per level
  for (int j=0; j<numInputs; j++){
    //Populate all nodes in each level
    for (int i=0; i<numInputs+2; i++){
      //First check for source and terminal node
      if (i == 0) { 
	xposernodes.add(new XposerNode("S"+j, j, i));
      }
      else if (i == (numInputs+2) - 1) { 
	xposernodes.add(new XposerNode("T"+j, j, i));
      }
      else {
  //Then check for odd stage on level 0
  if (j == 0 && i%2 == 1){
    xposernodes.add(new XposerNode("D" + count, j, i));
    count++;
  }
  //Then check for odd stage on level n-1 if n is even
  else if (j == numInputs - 1 && numInputs%2 == 0 && i%2 == 1){
    xposernodes.add(new XposerNode("D" + count, j, i));
    count++;
  }
  //Then check for even stage on level n-1 if n is odd
  else if (j == numInputs - 1 && numInputs%2 == 1 && i%2 == 0){
    xposernodes.add(new XposerNode("D" + count, j, i));
    count++;
  }
  else if (j != 0 && j != numInputs - 1){
    xposernodes.add(new XposerNode("D" + count, j, i));
    count++;
  }    
      } 
    }
  }

  float totalWidth = width - 50;
  float totalHeight = height - 150;
  float canvasWidthIncrements_fl = (totalWidth)/(2.0+numInputs);
  int canvasWidthIncrements = round(canvasWidthIncrements_fl);
  float canvasHeightIncrements_fl = (totalHeight)/(numInputs);
  int canvasHeightIncrements = floor(canvasHeightIncrements_fl);


  //Give xposer nodes a position
  for(XposerNode currentNode: xposernodes) {
    nodes.add(new Node(currentNode.label, 25+(currentNode.stage * canvasWidthIncrements), 75+(canvasHeightIncrements * (currentNode.level)))); 
  }
 
  // add nodes to graph
  for (int j=0; j<nodes.size(); j++){
    Node addnode = nodes.get(j);
    g.addNode(addnode);
  }
}

void makeXposers() {
  for (int j=0; j<numInputs; j++){
    int t = 1;
    XposerNode linknode1x;
   //Populate all nodes in each level
    for (int i=0; i<numInputs+1; i++){
      //First check for source and terminal node
      if (i != 0 && i!= (numInputs+1)) {
	//Then check for odd stage on level 0 and increment the level
	if (j == 0){
	  if (findIndex(j,i)!=-1){
	    linknode1x = xposernodes.get(findIndex(j,i));
	    linknode1x.pairNode(xposernodes.get(findNextIndex(j+1, i)));
	    xposers.add(new Xposer(linknode1x));
	    linknode1x.linkCross(xposernodes.get(findNextIndex(j+1, i+1)));
	    linknode1x.linkStraight(xposernodes.get(findNextIndex(j, i+1)));
	  }
	}
	//Then check for odd stage on level n-1 if n is even and decrement the level
	else if (j == numInputs - 1){
	  if (findIndex(j,i)!=-1){
	    linknode1x = xposernodes.get(findIndex(j,i));
	    linknode1x.pairNode(xposernodes.get(findNextIndex(j-1, i)));
	    linknode1x.linkCross(xposernodes.get(findNextIndex(j-1, i+1)));
	    linknode1x.linkStraight(xposernodes.get(findNextIndex(j, i+1)));
	  }
	}
	//Then check for even stage on level n-1 if n is odd
	else if (j%2 == 0){
	  linknode1x = xposernodes.get(findIndex(j,i));
	  linknode1x.linkCross(xposernodes.get(findNextIndex(j+t, i+1)));
	  linknode1x.pairNode(xposernodes.get(findNextIndex(j+t, i)));
	  linknode1x.linkStraight(xposernodes.get(findNextIndex(j, i+1)));
	  if (t == 1){
	    xposers.add(new Xposer(linknode1x));
	  }
	  t *= -1; 
	}
	else if (j%2 == 1){
	  linknode1x = xposernodes.get(findIndex(j,i));
	  linknode1x.linkCross(xposernodes.get(findNextIndex(j-t, i+1)));
	  linknode1x.pairNode(xposernodes.get(findNextIndex(j-t, i)));
	  linknode1x.linkStraight(xposernodes.get(findNextIndex(j, i+1)));
	  if (t == -1){
	    xposers.add(new Xposer(linknode1x));
	  }
	  t *= -1; 
	}	  
      } 
    }
  }
  //println("calculated number of xposers " + numXposers(numInputs));
  //println("actual number of xposers " + xposers.size());
}

void makeXposerGraph(){
  for (int j=0; j<xposernodes.size(); j++){
    XposerNode currentNode = xposernodes.get(j);
    Node linknode1 = nodes.get(j);
    Node linknode2;
    XposerNode linknode2x;
    //If stage is 0, we are on a source node. Connect to first decision node
    if (currentNode.label.contains("S")){
      currentNode.linkStraight(xposernodes.get(j+1));
      linknode2x = currentNode.nextNodeSameLevel;
      linknode2 = nodes.get(findIndex(linknode2x.level, linknode2x.stage));
      g.linkNodes(linknode1, linknode2);
    }
  }  
 
  for (Xposer current: xposers) {
    current.cross();
    current.straight();
  }
}


//void makeGraphXposerNodes()
//{
  //// link nodes horizontally
  //for (int j=0; j<xposernodes.size(); j++){
    //XposerNode currentNode = xposernodes.get(j);
    //Node linknode1 = nodes.get(j);
    //Node linknode2;
    //XposerNode linknode2x;
    ////If stage is 0, we are on a source node. Connect to first decision node
    //if (currentNode.label.contains("S") || currentNode.label.contains("D")){
      //currentNode.linkStraight(xposernodes.get(j+1));
      //linknode2x = currentNode.nextNodeSameLevel;
      //linknode2 = nodes.get(findIndex(linknode2x.level, linknode2x.stage));
      //g.linkNodes(linknode1, linknode2);
    //}
  //}    
  //
//
  //// link nodes vertically
  //for (int j=0; j<numInputs; j++){
    //int t = 1;
    //Node linknode1;
    //Node linknode2;
    //XposerNode linknode1x;
    //XposerNode linknode2x;
   ////Populate all nodes in each level
    //for (int i=0; i<numInputs+2; i++){
      ////First check for source and terminal node
      //if (i != 0 && i!= (numInputs+2) - 1) {
	////Then check for odd stage on level 0 and increment the level
	//if (j == 0){
	  //if (findIndex(j,i)!=-1){
	    //linknode1x = xposernodes.get(findIndex(j,i));
	    //linknode1x.pairNode(xposernodes.get(findNextIndex(j+1, i)));
	    //xposers.add(new Xposer(linknode1x));
	    //linknode1x.linkCross(xposernodes.get(findNextIndex(j+1, i+1)));
	    //linknode2x = linknode1x.nextNodeDiffLevel;
	    //linknode1 = nodes.get(findIndex(linknode1x.level,linknode1x.stage));
	    //linknode2 = nodes.get(findNextIndex(linknode2x.level, linknode2x.stage));
	    //g.linkNodes(linknode1, linknode2); 
	  //}
	//}
	////Then check for odd stage on level n-1 if n is even and decrement the level
	//else if (j == numInputs - 1){
	  //if (findIndex(j,i)!=-1){
	    //linknode1x = xposernodes.get(findIndex(j,i));
	    //linknode1x.pairNode(xposernodes.get(findNextIndex(j-1, i)));
	    //linknode1x.linkCross(xposernodes.get(findNextIndex(j-1, i+1)));
	    //linknode2x = linknode1x.nextNodeDiffLevel;
	    //linknode1 = nodes.get(findIndex(linknode1x.level,linknode1x.stage));
	    //linknode2 = nodes.get(findNextIndex(linknode2x.level, linknode2x.stage));
	    //g.linkNodes(linknode1, linknode2); 
	  //}
	//}
	////Then check for even stage on level n-1 if n is odd
	//else if (j%2 == 0){
	  //linknode1x = xposernodes.get(findIndex(j,i));
	  //linknode1x.linkCross(xposernodes.get(findNextIndex(j+t, i+1)));
	  //linknode1x.pairNode(xposernodes.get(findNextIndex(j+t, i)));
	  ////println(linknode1x.label + " is paired with " + linknode1x.pair.label);
	  //linknode2x = linknode1x.nextNodeDiffLevel;
	  //linknode1 = nodes.get(findIndex(linknode1x.level,linknode1x.stage));
	  //linknode2 = nodes.get(findNextIndex(linknode2x.level, linknode2x.stage));
	  //t *= -1; 
	  //g.linkNodes(linknode1, linknode2); 
	//}
	//else if (j%2 == 1){
	  //linknode1x = xposernodes.get(findIndex(j,i));
	  //linknode1x.linkCross(xposernodes.get(findNextIndex(j-t, i+1)));
	  ////linknode1x.pairNode(xposernodes.get(findNextIndex(j-t, i)));
	  //linknode2x = linknode1x.nextNodeDiffLevel;
	  //linknode1 = nodes.get(findIndex(linknode1x.level,linknode1x.stage));
	  //linknode2 = nodes.get(findNextIndex(linknode2x.level, linknode2x.stage));
	  //t *= -1; 
	  //g.linkNodes(linknode1, linknode2); 
	//}	  
      //} 
    //}
  //}

  //Test all decision nodes for pair
  //for (XposerNode currentNode : xposernodes) {
    //if (currentNode.label.contains("D")){
      //if (currentNode.pair == null){
	//println("No valid pair for " + currentNode.label);
      //}
    //}
  //}
//}

 
void makeGraph()
{
  // link nodes horizontally
  for (int j=0; j<xposernodes.size(); j++){
    XposerNode currentNode = xposernodes.get(j);
    Node linknode1 = nodes.get(j);
    Node linknode2;
    //If stage is 0, we are on a source node. Connect to first decision node
    if (currentNode.label.contains("S") || currentNode.label.contains("D")){
      linknode2 = nodes.get(j+1);
      g.linkNodes(linknode1, linknode2);
    }
  }    
  

  // link nodes vertically
  for (int j=0; j<numInputs; j++){
    int t = 1;
    Node linknode1;
    Node linknode2;
   //Populate all nodes in each level
    for (int i=0; i<numInputs+2; i++){
      //First check for source and terminal node
      if (i != 0 && i!= (numInputs+2) - 1) {
	//Then check for odd stage on level 0
	if (j == 0){
	  if (findIndex(j,i)!=-1){
	    linknode1 = nodes.get(findIndex(j,i));
	    linknode2 = nodes.get(findNextIndex(j+1, i+1));
	    g.linkNodes(linknode1, linknode2); 
	  }
	}
	//Then check for odd stage on level n-1 if n is even
	else if (j == numInputs - 1){
	  if (findIndex(j,i)!=-1){
	    linknode1 = nodes.get(findIndex(j,i));
	    linknode2 = nodes.get(findNextIndex(j-1, i+1));
	    g.linkNodes(linknode1, linknode2); 
	  }
	}
	//Then check for even stage on level n-1 if n is odd
	else if (j%2 == 0){
	  linknode1 = nodes.get(findIndex(j,i));
	  linknode2 = nodes.get(findNextIndex(j+t, i+1));
	  t *= -1; 
	  g.linkNodes(linknode1, linknode2); 
	}
	else if (j%2 == 1){
	  linknode1 = nodes.get(findIndex(j,i));
	  linknode2 = nodes.get(findNextIndex(j-t, i+1));
	  t *= -1; 
	  g.linkNodes(linknode1, linknode2); 
	}	  
      } 
    }
  }
}

int findInputForValue(int margin) {
  int index=-1;
  for (int i = 0; i < inputDiff.size(); i++){
    if (inputDiff.get(i) == margin) {
      index = i;
      break;
    }
  }
  return index;
}

int findDiffIndex(int level) {
  int index=-1;
  for (int i = 0; i < levelDifference.size(); i++){
    if (levelDifference.get(i) == level) {
      index = i;
      break;
    }
  }
  return index;
}

int findCurrentIndex(int level) {
  int index=-1;
  for (int i = 0; i < currentLevel.size(); i++){
    if (currentLevel.get(i) == level) {
      index = i;
      break;
    }
  }
  return index;
}

int findDestIndex(int level) {
  int index=-1;
  for (int i = 0; i < destLevel.size(); i++){
    if (destLevel.get(i) == level) {
      index = i;
      break;
    }
  }
  return index;
}

int findXposer(XposerNode topLeftNode) {
  int index=-1;
  for (int i = 0; i < xposers.size(); i++) {
    if (xposers.get(i).topLeftNode == topLeftNode) {
      index = i;
      break;
    }
  }
  return index;
}

int findIndex(int level, int stage) {
  int index=-1;
  for (int i = 0; i < xposernodes.size(); i++){
    if (xposernodes.get(i).level == level && xposernodes.get(i).stage == stage) {
      index = i;
      break;
    }
  }
  return index;
}

int findNextIndex(int level, int stage) {
  int index=-1;
  for (int i = 0; i < xposernodes.size(); i++){
    if (xposernodes.get(i).level == level && xposernodes.get(i).stage == stage) {
      index = i;
      break;
    }
    else if (xposernodes.get(i).level == level && xposernodes.get(i).stage == stage+1) {
      index = i;
      break;
    }
  }
  return index;
}
  
int numXposers(int n) {
  if (n == 1) return 0;
  return n-1+numXposers(n-1);
}

void route(){
  destLevel.clear();
  levelDifference.clear();
  inputOrder.clear();
  inputDiff.clear();
  xposernodes.clear();
  xposers.clear();
  nodes.clear();
  rootnodes.clear();
  treenodes.clear();
  g.clearNodes();

  for (int i=0; i<numInputs; i++){
    levelDifference.append(0);
  }

  for (String str : inputList){
    String[] list = split(str, " ");
    destLevel.append(int(list[1]));
  }
  for (int j=0; j<numInputs; j++){
    if (!destLevel.hasValue(j)){
      missingOutput = j;
      error = true;
      break;
    }
    error = false;
  }
  if (!error){
    println("destLevel: " + destLevel);
    populateNodes();
    makeXposers();
  }

  routeFromSource();


  //Test input paths method
  //for (int i=0; i<inputPaths.get(0).size(); i++){
    //println(inputPaths.get(0).get(i).label);
  //}
  //println(inputPaths.get(0).get(2).label);

  //Order the inputs to be routed by highest level difference
  for (int l=0; l<numInputs; l++){
    levelDifference.set(l, findDestIndex(l)-l);
    inputDiff.append(abs(levelDifference.get(l)));
  } 

  boolean[] ordered = new boolean[numInputs];

  for (int l=0; l<numInputs; l++){
    int diffMax = inputDiff.max();
    if (ordered[findInputForValue(diffMax)] == false){
      inputOrder.append(findInputForValue(diffMax));
      ordered[findInputForValue(diffMax)] = true;
      inputDiff.set(findInputForValue(diffMax), 0); 
    }
  }

  for (int l=0; l<numInputs; l++){
    if (ordered[l] == false){
      inputOrder.append(l);
    }
  }
  println("levelDifference = " + levelDifference);
  println("Order to route inputs " + inputOrder);

  //test for adjacent nodes method
  //for (XposerNode hippo : xposernodes){
    //ArrayList<XposerNode> chickDuck = hippo.adjacentNodes(hippo);
    //String[] adjacent = new String[2];
    //if (chickDuck != null){ 
      //for (int i=0; i<chickDuck.size(); i++){
	//if (chickDuck.get(i) == null) {
	  //adjacent[i] = "null";
	//}
	//else {
	//adjacent[i] = chickDuck.get(i).label;
	//}	
      //}
    //}
    //println("Node " + hippo.label + " is adjacent to " + adjacent[0] + " " + adjacent[1]);
  //}

  //find all paths for each input 
  for (int i=0; i<inputOrder.size(); i++){
    ArrayList<ArrayList<XposerNode>> inputPaths = new ArrayList<ArrayList<XposerNode>>();
    inputPaths = pathSearch(xposernodes.get(findIndex(inputOrder.get(i),0)), xposernodes.get(findIndex(findDestIndex(inputOrder.get(i)), numInputs+1)));
    //create new treenode for each path/input combination
    for (int j=0; j<inputPaths.size(); j++){
      if (inputPaths == null) {
	println("no paths found");
	break;
      }
      else{
	treenodes.add(new TreeNode(inputOrder.get(i), inputPaths.get(j), i));
      }
    }
  }

  for (TreeNode current : treenodes) {
    if (current.level == 0){
      rootnodes.add(current);
    }
    for (int i=0; i<inputOrder.size(); i++){
      if (current.level == i && current.level != inputOrder.size()-1){
	for (TreeNode nextLevel : treenodes) {
	  if (nextLevel.level == i+1) {
	    current.addChild(nextLevel);
	  }
	}
      }
      if (current.level == i && current.level != 0){
	for (TreeNode prevLevel : treenodes) {
	  if (prevLevel.level == i-1) {
	    current.addParent(prevLevel);
	  }
	}
      }
    }
  }


  //for (TreeNode current : rootnodes) {
    //ArrayList<TreeNode> visited = new ArrayList<TreeNode>();
    //ArrayList<ArrayList<XposerNode>> pathsToCheck = new ArrayList<ArrayList<XposerNode>>();
    //visited.add(current);
    //validPath = pathMatch(current, pathsToCheck, visited);
    //if (validPath != null){
      //break;
    //}
  //}

  validPath = matchSetup(rootnodes);
  
  if (!validPath.isEmpty()){
    println("found path");
    routeValidPath(validPath);
    //for (ArrayList<XposerNode> currentPath : validPath){
      //for (XposerNode currentNode : currentPath){
	//print(currentNode.label, " ");
      //}
      //println();
    //}
  }
  else {
    println("no path found");
  }


  //print out tree structure
  //for (TreeNode current : treenodes){
    //ArrayList<TreeNode> currentParents = current.getParents();
    //ArrayList<TreeNode> currentChildren = current.getChildren();
    //println("current level " + current.level);
    //println("current input " + current.input);
    //println("current children: ");
    //for (int i=0; i<currentChildren.size(); i++){
      //println("child " + i + " is on level " + currentChildren.get(i).level + " and contains paths for input " + currentChildren.get(i).input);
    //}
    //println("current parents: ");
    //for (int i=0; i<currentParents.size(); i++){
      //println("parent " + i + " is on level " + currentParents.get(i).level + " and contains paths for input " + currentParents.get(i).input);
    //}
  //}


  //inputPaths = pathSearch(xposernodes.get(findIndex(inputOrder.get(0),0)), xposernodes.get(findIndex(findDestIndex(inputOrder.get(0)), numInputs+1)));


  //route inputs in order
  //for (int k=0; k<numInputs; k++) {
    //routeInput(inputOrder.get(k));
  //}
  
  //xposers.get(findXposer(xposernodes.get(findIndex(2, 7))));

  //check that all xposers have been touched
  for (Xposer current: xposers) {
    if (current.crossed == null) {
      println("Something is amiss " + current.topLeftNode.label + " is null");
    }
  }
}

void routeValidPath(ArrayList<ArrayList<XposerNode>> pathRoutes){
  for (ArrayList<XposerNode> path : pathRoutes){
    for (int i=0; i<path.size(); i++){
      XposerNode node = path.get(i);
      if (findXposer(node) != -1) {
	if (path.get(i+1) == node.nextNodeSameLevel){
	  xposers.get(findXposer(node)).straight();
	}
	else if (path.get(i+1) == node.nextNodeDiffLevel){
	  xposers.get(findXposer(node)).cross();
	}
      }
    }
  }
}

ArrayList<ArrayList<XposerNode>> matchSetup(ArrayList<TreeNode> roots){
  cease = false;
  ArrayList<ArrayList<XposerNode>> pathsToCheck = new ArrayList<ArrayList<XposerNode>>();
  for (TreeNode current : roots) {
    ArrayList<TreeNode> visited = new ArrayList<TreeNode>();
    visited.add(current);
    println("new root node");
    pathMatch(current, pathsToCheck, visited);
    if (!pathsToCheck.isEmpty()){
      break;
    }
    else {
      pathsToCheck.clear();
      continue;
    }
  }
  return pathsToCheck;
}

void pathMatch(TreeNode startNode, ArrayList<ArrayList<XposerNode>> pathToCheck, ArrayList<TreeNode> visited){
  ArrayList<XposerNode> matchNodes = new ArrayList<XposerNode>();
  ArrayList<TreeNode> startChildren = startNode.getChildren();
  //if i'm at the bottom of the routing tree, check paths for duplicate nodes
  if (startChildren.isEmpty()) {
    matchNodes = startNode.getPath();
    pathToCheck.add(new ArrayList(matchNodes));
    ArrayList<XposerNode> matchList = new ArrayList<XposerNode>();
    for (ArrayList<XposerNode> pathLine : pathToCheck){
      matchList.addAll(pathLine);
    }
    Set<XposerNode> matchSet = new HashSet<XposerNode>(matchList);
    if (matchSet.size() < matchList.size()){
      pathToCheck.remove(matchNodes);
    }
    else {
      println("good path found!");
      cease = true;
    }
  }
  else {
    for (TreeNode node : startChildren){
      if (visited.contains(node)){
	pathToCheck.remove(matchNodes);
	continue;
      }
      else {
	ArrayList<TreeNode> temp = new ArrayList<TreeNode>();
	temp.addAll(visited);
	temp.add(node);
        matchNodes = startNode.getPath();
        pathToCheck.add(new ArrayList(matchNodes));
        pathMatch(node, pathToCheck, temp);
        if (cease == false){
          pathToCheck.remove(matchNodes);
        }
	else {
	  return;
	}
      }
    }	
  }
}
 

void routeFromSource(){
  //Route source nodes to first decision node
  for (int j=0; j<xposernodes.size(); j++){
    XposerNode currentNode = xposernodes.get(j);
    Node linknode1 = nodes.get(j);
    Node linknode2;
    XposerNode linknode2x;

    //If stage is 0, we are on a source node. Connect to first decision node
    if (currentNode.label.contains("S")){
      currentNode.linkStraight(xposernodes.get(j+1));
      linknode2x = currentNode.nextNodeSameLevel;
      linknode2 = nodes.get(findIndex(linknode2x.level, linknode2x.stage));
      g.linkNodes(linknode1, linknode2);
    }
  }  
}

void routeInput(int input) {
  int goalLevel = findDestIndex(input);
  println("input: " + input);
  println("goal Level: " + goalLevel);
  int currentMargin;
  int currentLevel = input;
  int lastDecisionStage;
  boolean crossedState;
  Xposer lastDecisionXposer = null;


  //Start at stage 1 since we've already routed from the source to first decision node
  for (int i=1; i<numInputs+1; i++){ 
    currentMargin = goalLevel - currentLevel;
    //Check to see if the result of the last move resulted in an unrouteable situation 
    //i.e., (the current margin is greater than the number stages we have left)
    if ((numInputs+1 - i) < currentMargin) {
      //UNROUTABLE
      println("input " + input + " can't be routed!");
      break;
    }
    //If a node exists where I am
    if (findIndex(currentLevel, i) != -1) {
      //If I can increment my level and need to
      if ( ((currentLevel%2==0 && i%2==1) || (currentLevel%2==1 && i%2==0)) ){
	//Check to see if the xposer associated with the current node has been set
	if (xposers.get(findXposer(xposernodes.get(findIndex(currentLevel, i)))).crossed != null) {
	  //Then check to see if it's crossed or straight. If it's crossed, increment level and move on
	  if (xposers.get(findXposer(xposernodes.get(findIndex(currentLevel, i)))).crossed == true) {
	    currentLevel += 1; 
	    currentMargin = goalLevel - currentLevel;
	  }
	}
	else {
	  lastDecisionXposer = xposers.get(findXposer(xposernodes.get(findIndex(currentLevel, i))));
	  if (currentMargin > 0) {
	    //xposers.get(findXposer(xposernodes.get(findIndex(currentLevel, i)))).cross();
	    lastDecisionXposer.cross();
	    currentLevel += 1;
	    currentMargin = goalLevel - currentLevel;
	    lastDecisionStage = i;
	    crossedState = true;
	  }
	  else {
	    //xposers.get(findXposer(xposernodes.get(findIndex(currentLevel, i)))).straight();
	    lastDecisionXposer.straight();
	    crossedState = false;
	    lastDecisionStage = i;
	  }
	}
      }
      //If I can decrement my level and need to. CHECK THIS, using else instead of else if to test for even/even odd/odd case
      else {
	if (xposers.get(findXposer(xposernodes.get(findIndex(currentLevel-1, i)))).crossed != null) {
	  //Then check to see if it's crossed or straight. If it's crossed, decrement level and move on
	  if (xposers.get(findXposer(xposernodes.get(findIndex(currentLevel-1, i)))).crossed == true) {
	    currentLevel -= 1; 
	    currentMargin = goalLevel - currentLevel;
	  }
	}
	else {
	  lastDecisionXposer = xposers.get(findXposer(xposernodes.get(findIndex(currentLevel-1, i))));
	  if (currentMargin < 0) {
	    //xposers.get(findXposer(xposernodes.get(findIndex(currentLevel-1, i)))).cross();
	    lastDecisionXposer.cross();
	    currentLevel -= 1;
	    currentMargin = goalLevel - currentLevel;
	    lastDecisionStage = i;
	    crossedState = true;
	  }
	  else {
	    //xposers.get(findXposer(xposernodes.get(findIndex(currentLevel-1, i)))).straight();
	    lastDecisionXposer.straight();
	    crossedState = false;
	    lastDecisionStage = i;
	  }
	}
      }
    }
  }
  if (goalLevel != currentLevel) {
    println("Input " + input + " doesn't match goal level");
  }
}

void routingAlgorithm() {
  currentLevel.clear();
  levelDifference.clear();
  IntList nextLevel = new IntList();
  IntList check = new IntList();
  boolean incrementLevel = false;
  int currentMax = 0;
  int currentMin = 0;
  int inputAtNode = 0;
  int inputToMove = 0;
  int levelToMove = 0;

  //Initialize currentLevel with stage 0 values and initialize levelDifference at 0 for all levels since all levels will route straight through
  for (int i=0; i<numInputs; i++){
    currentLevel.append(i);
    levelDifference.append(0);
  }
  for (int i=0; i<numInputs; i++){
    nextLevel.set(i, currentLevel.get(i));
  }

  //j = level; i = stage
  //Start scanline on stage 0
  for (int i=0; i<numInputs+1; i++){
    Node linknode1;
    Node linknode2;
    Node linknode1f; //forced routing nodes
    Node linknode2f; //forced routing nodes

    currentMax = levelDifference.max();
    currentMin = levelDifference.min();

    while (currentMax != 0 || currentMin != 0) {
      if (abs(currentMax)>abs(currentMin)) {
	inputToMove = findDiffIndex(currentMax);
	incrementLevel = true;
      }
      else {
	inputToMove = findDiffIndex(currentMin);
	incrementLevel = false;
      }
      levelToMove = findCurrentIndex(inputToMove);

      //debugging messages
      println("currentMax: " + currentMax);
      println("currentMin: " + currentMin);
      println("inputToMove: " + inputToMove);
      println("calculated inputToMove using currentMin: " + findDiffIndex(currentMin));
      println("levelDifference: " + levelDifference);
      println("currentLevel: " + currentLevel);
      println("nextLevel: " + nextLevel);
      println("levelToMove: " + levelToMove);
      println("i: " + i);
      println("numInputs+1 " + (numInputs+1));
      println("next forced stage " + xposernodes.get(findNextIndex(levelToMove, i+1)).stage);
      //println("destination for forced node " + findDestIndex(currentLevel.get(levelToMove+1)));
      //println("next level for forced node if taken " + (currentLevel.get(levelToMove+1)-1));

      //If there is no node at the current maximum levelToMove, we must wait until the next stage to route it
      if (findIndex(levelToMove, i) == -1) {
        levelDifference.set(inputToMove, 0);
      }
      //Increment level only if even/odd OR odd/even AND unmarked AND not a source node AND the input needs to move up a level
      else if (((levelToMove%2 == 0 && i%2 == 1) || (levelToMove%2 == 1 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && incrementLevel == true && ((numInputs+1)-xposernodes.get(findNextIndex(levelToMove, i+1)).stage) >= (findDestIndex(currentLevel.get(levelToMove+1)) - (levelToMove+1-1))){
        linknode1 = nodes.get(findIndex(levelToMove,i));
        linknode2 = nodes.get(findNextIndex(levelToMove+1, i+1));
        linknode1f = nodes.get(findIndex(levelToMove+1, i));
        linknode2f = nodes.get(findNextIndex(levelToMove, i+1));
        g.linkNodes(linknode1, linknode2); 
        g.linkNodes(linknode1f, linknode2f); 
        xposernodes.get(findIndex(levelToMove,i)).markNode();
        xposernodes.get(findIndex(levelToMove+1, i)).markNode();
        levelDifference.set(inputToMove, 0); 
        //levelDifference.set(inputToMove+1, 0); 
        levelDifference.set(currentLevel.get(levelToMove+1), 0); 
        nextLevel.set(levelToMove, currentLevel.get(levelToMove+1));
        nextLevel.set(levelToMove+1, currentLevel.get(levelToMove));
      }
      //Decrement level only if even/even OR odd/odd AND unmarked AND not a source node AND the input needs to move down a level
      else if (((levelToMove%2 == 1 && i%2 == 1) || (levelToMove%2 == 0 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && incrementLevel == false && ((numInputs+1)-xposernodes.get(findNextIndex(levelToMove, i+1)).stage) >= abs(findDestIndex(currentLevel.get(levelToMove-1)) - (levelToMove-1+1))){
        linknode1 = nodes.get(findIndex(levelToMove,i));
        linknode2 = nodes.get(findNextIndex(levelToMove-1, i+1));
        linknode1f = nodes.get(findIndex(levelToMove-1, i));
        linknode2f = nodes.get(findNextIndex(levelToMove, i+1));
        g.linkNodes(linknode1, linknode2); 
        g.linkNodes(linknode1f, linknode2f); 
        xposernodes.get(findIndex(levelToMove,i)).markNode();
        xposernodes.get(findIndex(levelToMove-1, i)).markNode();
        levelDifference.set(inputToMove, 0); 
        //levelDifference.set(inputToMove-1, 0); 
        levelDifference.set(currentLevel.get(levelToMove-1), 0); 
        nextLevel.set(levelToMove, currentLevel.get(levelToMove-1));
        nextLevel.set(levelToMove-1, currentLevel.get(levelToMove));
      }
      //If none of the conditions above are satisfied, the node has to move but is unroutable at this stage
      else {
	levelDifference.set(inputToMove, 0);
      }
      currentMax = levelDifference.max();
      currentMin = levelDifference.min();
    }
    //If no more crossing is required, route straight through for all unmarked nodes in the current stage
    for (int j=0; j<numInputs; j++) {
      if (findIndex(j,i) != -1) { 
	if (xposernodes.get(findIndex(j,i)).marked == false){
	  linknode1 = nodes.get(findIndex(j,i)); 
	  linknode2 = nodes.get(findNextIndex(j, i+1));
	  g.linkNodes(linknode1, linknode2); 
	  xposernodes.get(findIndex(j,i)).markNode();
	}
      }
    }
    //Set nextLevel to currentLevel to prepare for next scan line stage
    for (int m=0; m<numInputs; m++){
      currentLevel.set(m, nextLevel.get(m));
    }
    //Recalculate levelDifference for next scan line stage
    for (int l=0; l<numInputs; l++){
      levelDifference.set(l, findDestIndex(l)-findCurrentIndex(l));
    } 
  }
  for (int i=0; i<numInputs; i++){
    if (destLevel.get(i) == currentLevel.get(i)){
      check.append(1);
    }
    else {
      check.append(0);
    }
  }
  if (check.min() == 0) {
    println("Routing Failed for " + destLevel);
    println("Attempting Patient Algorithm");
    greedyFail = true;
    route();
  }
  else {
    println("Routing Successful for " + destLevel);
  }
}

void patientAlgorithm() {
  currentLevel.clear();
  levelDifference.clear();
  IntList nextLevel = new IntList();
  IntList check = new IntList();
  boolean incrementLevel = false;
  int currentMax = 0;
  int currentMin = 0;
  int inputAtNode = 0;
  int inputToMove = 0;
  int levelToMove = 0;
  int longestDistance = 0;
  int secondaryDistance = 0;

  greedyFail = false;

  //Initialize currentLevel with stage 0 values and initialize levelDifference at 0 for all levels since all levels will route straight through
  for (int i=0; i<numInputs; i++){
    currentLevel.append(i);
    levelDifference.append(0);
  }
  for (int i=0; i<numInputs; i++){
    nextLevel.set(i, currentLevel.get(i));
  }

  //j = level; i = stage
  //Start scanline on stage 0
  for (int i=0; i<numInputs+1; i++){
    Node linknode1;
    Node linknode2;
    Node linknode1f; //forced routing nodes
    Node linknode2f; //forced routing nodes

    currentMax = levelDifference.max();
    currentMin = levelDifference.min();
    longestDistance = max(abs(currentMax), abs(currentMin));

    if (longestDistance == abs(currentMin) && longestDistance != 0){
      //search levelDifference for differences that match the longest
      for (int p=0; p<numInputs; p++){
	if (levelDifference.get(p) == currentMin){
	  inputToMove = p;
	  levelToMove = findCurrentIndex(inputToMove);
          //Decrement level 
	  if (((levelToMove%2 == 1 && i%2 == 1) || (levelToMove%2 == 0 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && ((numInputs+1)-xposernodes.get(findNextIndex(levelToMove, i+1)).stage) >= abs(findDestIndex(currentLevel.get(levelToMove-1)) - (levelToMove-1+1)) && (levelDifference.get(currentLevel.get(levelToMove-1)) != currentMin)){
	    linknode1 = nodes.get(findIndex(levelToMove,i));
	    linknode2 = nodes.get(findNextIndex(levelToMove-1, i+1));
	    linknode1f = nodes.get(findIndex(levelToMove-1, i));
	    linknode2f = nodes.get(findNextIndex(levelToMove, i+1));
	    g.linkNodes(linknode1, linknode2); 
	    g.linkNodes(linknode1f, linknode2f); 
	    xposernodes.get(findIndex(levelToMove,i)).markNode();
	    xposernodes.get(findIndex(levelToMove-1, i)).markNode();
	    nextLevel.set(levelToMove, currentLevel.get(levelToMove-1));
	    nextLevel.set(levelToMove-1, currentLevel.get(levelToMove));
	  }	  
	}
      }
      for (int p=0; p<numInputs; p++){
	if (levelDifference.get(p) == currentMax){
	  inputToMove = p;
	  levelToMove = findCurrentIndex(inputToMove);
	  //Increment level
	  if (((levelToMove%2 == 0 && i%2 == 1) || (levelToMove%2 == 1 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && ((numInputs+1)-xposernodes.get(findNextIndex(levelToMove, i+1)).stage) >= (findDestIndex(currentLevel.get(levelToMove+1)) - (levelToMove+1-1)) && (levelDifference.get(currentLevel.get(levelToMove+1)) != currentMax)){
	    linknode1 = nodes.get(findIndex(levelToMove,i));
	    linknode2 = nodes.get(findNextIndex(levelToMove+1, i+1));
	    linknode1f = nodes.get(findIndex(levelToMove+1, i));
	    linknode2f = nodes.get(findNextIndex(levelToMove, i+1));
	    g.linkNodes(linknode1, linknode2); 
	    g.linkNodes(linknode1f, linknode2f); 
	    xposernodes.get(findIndex(levelToMove,i)).markNode();
	    xposernodes.get(findIndex(levelToMove+1, i)).markNode();
	    nextLevel.set(levelToMove, currentLevel.get(levelToMove+1));
	    nextLevel.set(levelToMove+1, currentLevel.get(levelToMove));
	  }
	}
      }
    }
    else if (longestDistance == currentMax && longestDistance != 0){
      for (int p=0; p<numInputs; p++){
	if (levelDifference.get(p) == currentMax){
	  inputToMove = p;
	  levelToMove = findCurrentIndex(inputToMove);
	  //Increment level
	  if (((levelToMove%2 == 0 && i%2 == 1) || (levelToMove%2 == 1 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && ((numInputs+1)-xposernodes.get(findNextIndex(levelToMove, i+1)).stage) >= (findDestIndex(currentLevel.get(levelToMove+1)) - (levelToMove+1-1)) && (levelDifference.get(currentLevel.get(levelToMove+1)) != currentMax)){
	    linknode1 = nodes.get(findIndex(levelToMove,i));
	    linknode2 = nodes.get(findNextIndex(levelToMove+1, i+1));
	    linknode1f = nodes.get(findIndex(levelToMove+1, i));
	    linknode2f = nodes.get(findNextIndex(levelToMove, i+1));
	    g.linkNodes(linknode1, linknode2); 
	    g.linkNodes(linknode1f, linknode2f); 
	    xposernodes.get(findIndex(levelToMove,i)).markNode();
	    xposernodes.get(findIndex(levelToMove+1, i)).markNode();
	    nextLevel.set(levelToMove, currentLevel.get(levelToMove+1));
	    nextLevel.set(levelToMove+1, currentLevel.get(levelToMove));
	  }
	}
      }
      for (int p=0; p<numInputs; p++){
	if (levelDifference.get(p) == currentMin){
	  inputToMove = p;
	  levelToMove = findCurrentIndex(inputToMove);
	  //Decrement level 
	  if (((levelToMove%2 == 1 && i%2 == 1) || (levelToMove%2 == 0 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && ((numInputs+1)-xposernodes.get(findNextIndex(levelToMove, i+1)).stage) >= abs(findDestIndex(currentLevel.get(levelToMove-1)) - (levelToMove-1+1)) && (levelDifference.get(currentLevel.get(levelToMove-1)) != currentMin)){
	    linknode1 = nodes.get(findIndex(levelToMove,i));
	    linknode2 = nodes.get(findNextIndex(levelToMove-1, i+1));
	    linknode1f = nodes.get(findIndex(levelToMove-1, i));
	    linknode2f = nodes.get(findNextIndex(levelToMove, i+1));
	    g.linkNodes(linknode1, linknode2); 
	    g.linkNodes(linknode1f, linknode2f); 
	    xposernodes.get(findIndex(levelToMove,i)).markNode();
	    xposernodes.get(findIndex(levelToMove-1, i)).markNode();
	    nextLevel.set(levelToMove, currentLevel.get(levelToMove-1));
	    nextLevel.set(levelToMove-1, currentLevel.get(levelToMove));
	  }	  
	}
      }
    }
    for (int j=0; j<numInputs; j++) {
      if (findIndex(j,i) != -1) { 
	if (xposernodes.get(findIndex(j,i)).marked == false){
          linknode1 = nodes.get(findIndex(j,i)); 
          linknode2 = nodes.get(findNextIndex(j, i+1));
          g.linkNodes(linknode1, linknode2); 
          xposernodes.get(findIndex(j,i)).markNode();
        }
      }
    }
    //Set nextLevel to currentLevel to prepare for next scan line stage
    for (int m=0; m<numInputs; m++){
      currentLevel.set(m, nextLevel.get(m));
    }
    //Recalculate levelDifference for next scan line stage
    for (int l=0; l<numInputs; l++){
      levelDifference.set(l, findDestIndex(l)-findCurrentIndex(l));
    } 
  }
  for (int i=0; i<numInputs; i++){
    if (destLevel.get(i) == currentLevel.get(i)){
      check.append(1);
    }
    else {
      check.append(0);
    }
  }
  if (check.min() == 0) {
    println("Patient Algorithm Failed for " + destLevel);
    println("Darn");
  }
  else {
    println("Patient Algorithm Successful for " + destLevel);
  }
}      

ArrayList<ArrayList<XposerNode>> pathSearch(XposerNode start, XposerNode finish) {
  ArrayList<XposerNode> visited = new ArrayList<XposerNode>();
  ArrayList<ArrayList<XposerNode>> paths = new ArrayList<ArrayList<XposerNode>>();
  XposerNode currentNode = start;
  visited.add(start);
  breadthFirst(finish, visited, paths, currentNode);
  for (ArrayList<XposerNode> path : paths){
    for (XposerNode node : path){
      print(node.label, " ");
    }
    println();
  }
  return paths;
}    	

void breadthFirst(XposerNode finish, ArrayList<XposerNode> visited, ArrayList<ArrayList<XposerNode>> paths, XposerNode currentNode) {
  if (currentNode == finish){
    paths.add(new ArrayList(visited));
    return;
  }
  else {
    ArrayList<XposerNode> nodes = currentNode.adjacentNodes(currentNode);
    for (XposerNode node : nodes) {
      if (node != null) {
	if (visited.contains(node)) {
	  continue;
	}
	ArrayList<XposerNode> temp = new ArrayList<XposerNode>();
	temp.addAll(visited);
	temp.add(node);
	breadthFirst(finish, temp, paths, node);
      }
    }
  }
}
