//  Methods for placing and routing nodes
//  pathRoute method modified from:
//  http://stackoverflow.com/questions/58306/graph-algorithm-to-find-all-connections-between-two-arbitrary-vertices

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
  
int numXposers(int n) {
  if (n == 1) return 0;
  return n-1+numXposers(n-1);
}

void route(){
  long startTime = System.nanoTime();
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
    //println("destLevel: " + destLevel);
    populateNodes();
    makeXposers();
    for (int i=0; i<xposers.size(); i++){
      Xposer current = xposers.get(i);
      current.linkPumps(controlPumps.get(2*i), controlPumps.get(2*i+1));
    }

    routeFromSource();
  
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
    
    //println("levelDifference = " + levelDifference);
    //println("Order to route inputs " + inputOrder);
  
    //find all paths for each input 
    for (int i=0; i<inputOrder.size(); i++){
      ArrayList<ArrayList<XposerNode>> inputPaths = new ArrayList<ArrayList<XposerNode>>();
      inputPaths = pathSearch(xposernodes.get(findIndex(inputOrder.get(i),0)), xposernodes.get(findIndex(findDestIndex(inputOrder.get(i)), numInputs+1)));
      //create new treenode for each path/input combination
      for (int j=0; j<inputPaths.size(); j++){
	if (inputPaths.isEmpty()) {
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
  
    validPath = matchSetup(rootnodes);
    
    if (!validPath.isEmpty()){
      println("found path");
      routeValidPath(validPath);
    }
    else {
      println("no path found");
    }
  
    //check that all xposers have been touched
    for (Xposer current: xposers) {
      if (current.crossed == null) {
	println("Something is amiss " + current.topLeftNode.label + " is null");
      }
    }
  }
  long endTime = System.nanoTime();
  println("Time to Route: " + ((endTime - startTime)/1000000) +" ms");
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
   

ArrayList<ArrayList<XposerNode>> pathSearch(XposerNode start, XposerNode finish) {
  ArrayList<XposerNode> visited = new ArrayList<XposerNode>();
  ArrayList<ArrayList<XposerNode>> paths = new ArrayList<ArrayList<XposerNode>>();
  XposerNode currentNode = start;
  visited.add(start);
  breadthFirst(finish, visited, paths, currentNode);
  //for (ArrayList<XposerNode> path : paths){
    //for (XposerNode node : path){
      //print(node.label, " ");
    //}
    //println();
  //}
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
