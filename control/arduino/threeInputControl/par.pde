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
  //for (int j=0; j<numInputs; j++){
    //destLevel.append(int(cp5.get(Textfield.class, "Output"+j).getText().trim()));
  //}
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
  println(destLevel);
  routingAlgorithm();
}

void routingAlgorithm() {
  currentLevel.clear();
  IntList nextLevel = new IntList();
  IntList levelDifference = new IntList();
  int currentIndex = -1;
  int currentMax = 0;
  int currentMin = 0;
  //Initialize currentLevel with stage 0 values
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
    //Start searching each node by stage
    for (int j=0; j<numInputs; j++){
      currentIndex = findIndex(j,i);
      if (currentIndex != -1) {
	if (xposernodes.get(currentIndex).marked == false) { 
	  currentMax = levelDifference.max();
	  currentMin = levelDifference.min();
	  while (levelDifference.max() != 0 && levelDifference.min() != 0){
	    for (int k=0; k<numInputs; k++){
	    if (findIndex(k,i) != -1) {
	    println("start");
   	    println("levelDiff inside: " + levelDifference);
	    println("max levelDiff inside: " + levelDifference.max());
	    println("k inside: " + k);
	    println("i inside: " + i);
	    println("k's levelDiff inside: " + levelDifference.get(k));
	    println("numInputs-1:" + (numInputs-1));
	    println("abs(leveldiff k)" + abs(levelDifference.get(k)));
	    println("last level test" + (k == numInputs-1));
	    println("needs to route up test" + (levelDifference.get(k) == levelDifference.min()));
	    println("needs to route down test" + (levelDifference.get(k) == levelDifference.max()));
	    println("marked test" + (xposernodes.get(findIndex(k,i)).marked == false));
	    println("current level" + currentLevel);
	    println("end");
	    //Check for level 0, always route down
	      if (k == 0 && levelDifference.get(k) == currentMax && xposernodes.get(findIndex(k,i)).marked == false) {
		linknode1 = nodes.get(findIndex(k,i));
		linknode2 = nodes.get(findNextIndex(k+1, i+1));
		linknode1f = nodes.get(findIndex(k+1, i));
		linknode2f = nodes.get(findNextIndex(k, i+1));
		g.linkNodes(linknode1, linknode2); 
		g.linkNodes(linknode1f, linknode2f); 
		xposernodes.get(findIndex(k,i)).markNode();
		xposernodes.get(findIndex(k+1, i)).markNode();
		levelDifference.set(k, 0); 
		levelDifference.set(k+1, 0); 
		//currentLevel.set(k, k+1);
		nextLevel.set(k, currentLevel.get(k+1));
		//currentLevel.set(k+1, k);
		nextLevel.set(k+1, currentLevel.get(k));
		println("first level current level k = " + k + "i = " + i + ": " + currentLevel);
	      }
	      //Check for level n-1, always route up
	      else if (k == numInputs-1 && levelDifference.get(k) == currentMin && xposernodes.get(findIndex(k,i)).marked == false) {
		linknode1 = nodes.get(findIndex(k,i));
		linknode2 = nodes.get(findNextIndex(k-1, i+1));
		linknode1f = nodes.get(findIndex(k-1, i));
		linknode2f = nodes.get(findNextIndex(k, i+1));
		g.linkNodes(linknode1, linknode2); 
		g.linkNodes(linknode1f, linknode2f); 
		xposernodes.get(findIndex(k,i)).markNode();
		xposernodes.get(findIndex(k-1, i)).markNode();
		levelDifference.set(k, 0); 
		levelDifference.set(k-1, 0); 
		nextLevel.set(k, currentLevel.get(k-1));
		nextLevel.set(k-1, currentLevel.get(k));
		//currentLevel.set(k, k-1);
		//currentLevel.set(k-1, k);
		  //linknode1 = nodes.get(findIndex(j,i));
		  //linknode2 = nodes.get(findNextIndex(j-1, i+1));
		  //g.linkNodes(linknode1, linknode2); 
		println("last level current level k = " + k + "i = " + i + ": " + currentLevel);
	      }
	      //Then check for even level on an odd stage or odd level on an even stage, route down
	      else if (((k%2 == 0 && i%2 == 1) || (k%2 == 1 && i%2 == 0)) && levelDifference.get(k) == currentMax && xposernodes.get(findIndex(k,i)).marked == false ){
		linknode1 = nodes.get(findIndex(k,i));
		linknode2 = nodes.get(findNextIndex(k+1, i+1));
		linknode1f = nodes.get(findIndex(k+1, i));
		linknode2f = nodes.get(findNextIndex(k, i+1));
		g.linkNodes(linknode1, linknode2); 
		g.linkNodes(linknode1f, linknode2f); 
		xposernodes.get(findIndex(k,i)).markNode();
		xposernodes.get(findIndex(k+1, i)).markNode();
		levelDifference.set(k, 0); 
		levelDifference.set(k+1, 0); 
		nextLevel.set(k, currentLevel.get(k+1));
		nextLevel.set(k+1, currentLevel.get(k));
		//currentLevel.set(k, k+1);
		//currentLevel.set(k+1, k);
		//linknode1 = nodes.get(findIndex(j,i));
		//linknode2 = nodes.get(findNextIndex(j+t, i+1));
		//g.linkNodes(linknode1, linknode2); 
		println("even/odd odd/even current level k = " + k + "i = " + i + ": " + currentLevel);
	      }
	      else if (((k%2 == 0 && i%2 == 0) || (k%2 == 1 && i%2 == 1)) && levelDifference.get(k) == currentMin && xposernodes.get(findIndex(k,i)).marked == false ){
		linknode1 = nodes.get(findIndex(k,i));
		linknode2 = nodes.get(findNextIndex(k-1, i+1));
		linknode1f = nodes.get(findIndex(k-1, i));
		linknode2f = nodes.get(findNextIndex(k, i+1));
		g.linkNodes(linknode1, linknode2); 
		g.linkNodes(linknode1f, linknode2f); 
		xposernodes.get(findIndex(k,i)).markNode();
		xposernodes.get(findIndex(k-1, i)).markNode();
		levelDifference.set(k, 0); 
		levelDifference.set(k-1, 0); 
		nextLevel.set(k, currentLevel.get(k-1));
		nextLevel.set(k-1, currentLevel.get(k));
		//currentLevel.set(k, k-1);
		//currentLevel.set(k-1, k);		//linknode1 = nodes.get(findIndex(j,i));
		//linknode2 = nodes.get(findNextIndex(j-t, i+1));
		//g.linkNodes(linknode1, linknode2); 
		println("even/even odd/odd current level k = " + k + "i = " + i + ": " + currentLevel);
	      }	  
	      else {
		levelDifference.set(k, 0);
	      }
	    }
	    }
	  }
	  //levelDifference is now 0 for all levels
	  //Route straight through unless you're on a terminal node
	  if (i < numInputs+1 && xposernodes.get(findIndex(j,i)).marked == false){
	    linknode1 = nodes.get(currentIndex); 
	    linknode2 = nodes.get(findNextIndex(j, i+1));
	    g.linkNodes(linknode1, linknode2); 
	    xposernodes.get(findIndex(j,i)).markNode();
	    levelDifference.set(j, 0); 
	  }
	}
      }
      else {
        levelDifference.set(j,0);
      }
    }
    //recalculate levelDifference for next stage
    for (int m=0; m<numInputs; m++){
      currentLevel.set(m, nextLevel.get(m));
    }
    for (int l=0; l<numInputs; l++){
      levelDifference.set(l, destLevel.get(l)-currentLevel.get(l));
      //levelDifference.set(l, findDestIndex(l)-findCurrentIndex(l));
    } 
    println("last levelDiff" + levelDifference);
    println("last current level" + currentLevel);
  } 
}
