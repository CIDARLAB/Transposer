//Search functions to help find indexes in an array
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

