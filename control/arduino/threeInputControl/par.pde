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
  xposernodes.clear();
  nodes.clear();
  g.clearNodes();
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
    populateNodes();
  }
  routingAlgorithm();
}

void routingAlgorithm() {
  currentLevel.clear();
  levelDifference.clear();
  IntList nextLevel = new IntList();
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
      currentMax = levelDifference.max();
      currentMin = levelDifference.min();
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
      //println("currentMax: " + currentMax);
      //println("currentMin: " + currentMin);
      //println("inputToMove: " + inputToMove);
      //println("calculated inputToMove using currentMin: " + findDiffIndex(currentMin));
      //println("levelDifference: " + levelDifference);
      //println("currentLevel: " + currentLevel);
      //println("nextLevel: " + nextLevel);
      //println("levelToMove: " + levelToMove);
      //println("i: " + i);
      
      //If there is no node at the current maximum levelToMove, we must wait until the next stage to route it
      if (findIndex(levelToMove, i) == -1) {
        levelDifference.set(inputToMove, 0);
      }
      //Increment level only if even/odd OR odd/even AND unmarked AND not a source node AND the input needs to move up a level
      else if (((levelToMove%2 == 0 && i%2 == 1) || (levelToMove%2 == 1 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && incrementLevel == true){
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
      else if (((levelToMove%2 == 1 && i%2 == 1) || (levelToMove%2 == 0 && i%2 == 0)) && xposernodes.get(findIndex(levelToMove,i)).marked == false && i != 0 && incrementLevel == false){
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
}
