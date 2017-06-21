import controlP5.*;

ControlP5 cp5;
//run button
Toggle run;
//reset button
Button reset;
//init cell ramdomly
Button randomize;
//update speed
Slider speed;
//on - periodic boundary, off - fixed(0) boundary
Toggle periodic;
//the size of grid
Slider gridn;


//cell array
int[][] cell;


void setup() {
  size(800, 800, P3D);
  background(0);
  
  cp5 = new ControlP5(this);
  run = cp5.addToggle("RUN").setPosition(20, 20).setSize(20, 30);
  reset = cp5.addButton("RESET").setPosition(20, 80).setSize(20, 30);
  randomize = cp5.addButton("RANDOMISE").setPosition(20, 140).setSize(20, 30);
  speed = cp5.addSlider("SPEED").setPosition(20, 200).setRange(1, 60).setValue(1);
  periodic = cp5.addToggle("PERIODIC").setPosition(20, 240).setSize(20, 30);
  gridn = cp5.addSlider("N").setPosition(20, 300).setRange(1, 200).setValue(40);
  
  cell_init(40);
}


//initialize cell with the size of n
void cell_init(int n) {
  cell = new int[n][n];
  for(int i = 0; i < n; i++) {
    for(int j = 0; j < n; j++) {
      cell[i][j] = 0;
    }
  }
}
//change the size of cell, ni - height, nj - width
int[][] cell_changegrid(int[][] cell, int ni, int nj) {
  int[][] cell_n = new int[ni][nj];
  for(int i = 0; i < ni; i++) {
    if(i >= cell.length) {
      for(int j = 0; j < nj; j++) {
        cell_n[i][j] = 0;
      }
    }
    else {     
      for(int j = 0; j < nj; j++) {
        if(j >= cell[0].length) {
          cell_n[i][j] = 0;
        }
        else {
          cell_n[i][j] = cell[i][j];
        }
      }
    }
  }
  return cell_n;
}


int get_cell(int[][] cell, int i, int j, int btype) {
  if(btype == 1) {
    if(i < 0) {
      i = cell.length - 1;
    }
    else if(i >= cell.length) {
      i = 0;
    }
    if(j < 0) {
      j = cell[0].length - 1;
    }
    else if(j >= cell[0].length) {
      j = 0;
    }
    return cell[i][j];
  }
  else if(btype == 2) {
    if(i < 0) {
      i = 0;
    }
    else if(i >= cell.length) {
      i = cell.length - 1;
    }
    if(j < 0) {
      j = 0;
    }
    else if(j >= cell[0].length - 1) {
      j = cell[0].length - 1;
    }
    return cell[i][j];
  }
  else {
    if(i < 0 || i >= cell.length || j < 0 || j >= cell[0].length) {
      return 0;
    }
    else {
      return cell[i][j];
    }
  }
}


//btype boundary condition 1-periodic, 2-reflective, 3-fixed
int cell_count(int[][] cell, int i, int j, int btype) {
  int left = get_cell(cell, i, j - 1, btype);
  int leftup = get_cell(cell, i - 1, j - 1, btype);
  int leftdown = get_cell(cell, i + 1, j - 1, btype);
  int right = get_cell(cell, i, j + 1, btype);
  int rightup = get_cell(cell, i - 1, j + 1, btype);
  int rightdown = get_cell(cell, i + 1, j + 1, btype);
  int up = get_cell(cell, i - 1, j, btype);
  int down = get_cell(cell, i + 1, j, btype);
  return left + leftup + leftdown + right + rightdown + rightup + up + down;
}


//update cell
void cell_update(int[][] cell, int btype) {
  int[][] cell_n = new int[cell.length][cell[0].length];
  for(int i = 0; i < cell.length; i++) {
    for(int j = 0; j < cell[0].length; j++) {
      cell_n[i][j] = cell[i][j];
    }
  }
  
  for(int i = 0; i < cell.length; i++) {
    for(int j = 0; j < cell[0].length; j++) {
      int c = cell_count(cell, i, j, btype);
      if(c == 3) {
        cell_n[i][j] = 1;
      }
      else if(c == 2) {
        cell_n[i][j] = cell[i][j];
      }
      else {
        cell_n[i][j] = 0;
      }
    }
  }
  
  for(int i = 0; i < cell.length; i++) {
    for(int j = 0; j < cell[0].length; j++) {
      cell[i][j] = cell_n[i][j];
    }
  }
}


//draw cell
void cell_draw(int[][] cell) {
  for(int i = 0; i < cell.length; i++) {
    float y = (float)i * height/cell.length;
    for(int j = 0; j < cell[0].length; j++) {
      float x = (float)j * width/cell[0].length;
      if(cell[i][j] == 1) {
        fill(color(0, 255, 0));
      }
      else {
        fill(color(0, 0, 0));
      }
      stroke(color(100, 100, 100, 255));
      rect(x, y, (float)width/cell[0].length, (float)height/cell.length);
    }
  }
}


//draw cell[i][j]
void cell_draw_pos(int[][] cell, int i, int j) {
  if(cell[i][j] == 1) {
    fill(color(0, 255, 0));
  }
  else {
    fill(color(0, 0, 0));
  }
  float x = (float)j * width/cell.length;
  float y = (float)i * height/cell.length;
  stroke(100);
  rect(x, y, (float)width/cell[0].length, (float)height/cell.length);
}


//previous value of N
int gridn_pre = 40;


void draw() {
  int N = (int)gridn.getValue();
  if(N != gridn_pre) {
    cell = cell_changegrid(cell, N, N);
    background(0);
    cell_draw(cell);
  }
  gridn_pre = (int)gridn.getValue();
  if(run.getState()) {
    if(frameCount%(int)(60.0/speed.getValue()) == 0) {
      background(0);
      cell_draw(cell);
      if(periodic.getState()) {
        cell_update(cell, 1);
      }
      else {
        cell_update(cell, 3);
      }
    }
  }
  if(reset.isPressed()) {
    for(int i = 0; i < cell.length; i++) {
      for(int j = 0; j < cell[0].length; j++) {
        cell[i][j] = 0;
      }
    }
    background(0);
    cell_draw(cell);
  }
  if(randomize.isPressed()) {
    for(int i = 0; i < cell.length; i++) {
      for(int j = 0; j < cell[0].length; j++) {
        cell[i][j] = (int)random(0, 2);
      }
    }
    background(0);
    cell_draw(cell);
  }
  run.getState();
}


void mousePressed() {
  int i = floor((float)mouseY/height * cell.length);
  int j = floor((float)mouseX/width * cell[0].length);
  if(i < 0 || i >= cell.length || j < 0 || j >= cell[0].length) {
    return;
  }
  
  if(mouseButton == LEFT) {
    cell[i][j] = 1;
  }
  else if(mouseButton == RIGHT) {
    cell[i][j] = 0;
  }
  cell_draw_pos(cell, i, j);
}
void mouseDragged() {
  int i = floor((float)mouseY/height * cell.length);
  int j = floor((float)mouseX/width * cell[0].length);
  if(i < 0 || i >= cell.length || j < 0 || j >= cell[0].length) {
    return;
  }
  
  if(mouseButton == LEFT) {
    cell[i][j] = 1;
  }
  else if(mouseButton == RIGHT) {
    cell[i][j] = 0;
  }
  cell_draw_pos(cell, i, j);
}