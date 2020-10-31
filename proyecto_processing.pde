import java.util.ArrayList;
import java.util.Stack;

Maze maze;
Player player;


color hall = #831F83;
color wall = #FF9BFF;
color white = #FFFFFF;
color start = #b870b8;
color end = #2fc461;
color bg = 51;

void setup(){
  size(600,600);
  int columns = floor(500/40);
  int rows = floor(500/40);
 
  
  maze = new Maze(rows,columns);
  player = new Player(288,20);
  maze.generateMaze();
}

void draw(){
  background(bg);
  frameRate(60);
  
  
  maze.display(); 
  player.display();
  
  
  if (player.getFinished()) {
    fill(white);
    rect(100,200,400,200);
    textSize(36);
    fill(0);
    text("¡Ganaste!", 225,310);
    maze.printTimer(maze.getStartedTime());
  }else{
    maze.printTimer();
  }
}

void keyPressed(){
    switch(keyCode){
      case 68:
        if (player.getFinished())break;
        if(!player.willCollideAhead("x")){
          player.moveRight();
        }
        break;
      case 65:
        if (player.getFinished()) break;
        if(!player.willCollideBehind("x")){
          player.moveLeft();
        }
        break;
      case 87:
        if (player.getFinished()) break;
        if(!player.willCollideBehind("y")){
          player.moveUp();
        }
        break;
      case 83:
        if (player.getFinished()) break;
        if (player.getY() == 540-player.getRectWidth()){ 
          player.setFinished(true);
          maze.setStartedTime(millis()/1000);
        }
        if(!player.willCollideAhead("y")){
         player.moveDown();
        }
        break;
      case 114:
      case 82:
        player.setX(288);
        player.setY(20);
        maze.resetTimer();
        player.setFinished(false);
    }
  
}



class Maze {
  private Cell [][] grid;
  private int rows;
  private int columns;
  private Cell current;
  private Stack<Boolean> unvisited;
  private int time;
  
  Maze(int rows, int columns){
    this.rows = rows;
    this.columns = columns;
    this.grid = new Cell[rows][columns];
    this.unvisited = new Stack<Boolean>();
    this.time = millis()/1000;
    
    initialize();
  }
  
  void initialize(){
    for(int j=0; j < rows; ++j) {
      for (int i =0; i < columns; ++i){
        grid[i][j] = new Cell(i,j);
        unvisited.push(true);
      }
    }
    
  }
  
  void generateMaze(){
    // Step 1
    
    this.current = grid[0][0];
    this.current.setVisited(true);
    this.unvisited.pop();
    
    // Step 2
    while(!unvisited.empty()){
      
      // Step 2.1
      Cell next = getRandomNeighbor();
      
      if (next != null){
        // Step 2.2
        if(!next.hasBeenVisited()){
          
          // Step 2.2.1
          removeWalls(this.current, next);
          
          // Step 2.2.2
          next.visited = true;
          this.unvisited.pop();
        }
        
        // Step 3
        this.current = next;
      
      }
    }
  }
 
  
  Cell getRandomNeighbor(){
    ArrayList<Cell> neighbors = new ArrayList<Cell>();
    
    Cell top = getCellByIndex(this.current.getI(), this.current.getJ()-1);
    Cell right = getCellByIndex(this.current.getI()+1,this.current.getJ());
    Cell bottom = getCellByIndex(this.current.getI(),this.current.getJ()+1);
    Cell left = getCellByIndex(this.current.getI()-1,this.current.getJ());
    
    if(top != null) neighbors.add(top);
    if(right !=null) neighbors.add(right);
    if(bottom != null) neighbors.add(bottom);
    if(left != null) neighbors.add(left);
    
    if(neighbors.size() > 0){
      int random = floor(random(0, neighbors.size()));
      return neighbors.get(random);
    }
    
    return null;
  }
  
  void removeWalls(Cell a, Cell b){
    int x = a.getI() - b.getI();
    if(x == 1){
      a.setWall(3, false);
      b.setWall(1, false);
    } else if (x==-1){
      a.setWall(1,false);
      b.setWall(3,false);
    }
    
    int y = a.getJ() - b.getJ();
    if (y == 1){
      a.setWall(0,false);
      b.setWall(2,false);
    } else if(y==-1){
      a.setWall(2,false);
      b.setWall(0,false);
    }
  }
  
  void display(){
    for(int j=0; j < rows; ++j) {
      for (int i =0; i < columns; ++i){
        grid[i][j].show();
      }
    }
    
    noStroke();
    fill(hall);
    // Start location
    rect(265,0,70,61);
    //End location
    fill(end);
    rect(265,540,70,60);
    
    stroke(wall);
    line(265,0,265,60);
    line(335,0,335,60);
    line(265,540,265,600);
    line(335,540,335,600);
    
    textSize(18);
    text("Presiona 'R' para reiniciar", 370, 35);
  }
  
  void printTimer(){
    text("Tiempo: " + (millis()/1000 - this.time), 20,35);
  }
  
  void printTimer(int time){
    fill(white);
    text("Tiempo: " + time, 20,38);
  }
  
  
  void resetTimer(){
    this.time = millis()/1000;
  }
  
  private Cell getCellByIndex(int i, int j){
    if (i<0 || j<0 || i > this.rows - 1 || j > this.columns - 1){
      return null;
    }
    
    return this.grid[i][j];
  }
  
  void setTime(int time){
    this.time = time;
  }
  
  int getTime(){
    return this.time;
  }
  
}

class Cell {
  private int i;
  private int j;
  private int x;
  private int y;
  private int cellWidth;
  private boolean visited;
  private boolean [] walls = {true, true, true, true};
  
  Cell(int i, int j){
    this.i = i;
    this.j = j;
    this.cellWidth = 40;
    this.visited = false;
    
    this.x = this.i*this.cellWidth+60;
    this.y = this.j*this.cellWidth+60;
  }
  
  void setVisited(boolean visited){
    this.visited = visited;
  }
  
  boolean hasBeenVisited(){
    return this.visited;
  }
  
  int getI(){
    return this.i;
  }
  int getJ(){
    return this.j;
  }
  
  void setWall(int index, boolean value){
    this.walls[index] = value;
  }

  void show(){
    stroke(255);
    if(this.walls[0]) line(this.x, this.y, this.x+this.cellWidth, this.y);
    if(this.walls[1]) line(this.x+this.cellWidth, this.y, this.x+this.cellWidth, this.y+this.cellWidth);
    if(this.walls[2]) line(this.x+this.cellWidth, this.y+this.cellWidth, this.x, this.y+this.cellWidth);
    if(this.walls[3]) line(this.x, this.y+this.cellWidth, this.x, this.y);
    
    if (this.visited){
      noStroke();
      fill(255, 0, 255, 100);
      rect(this.x,this.y,this.cellWidth,this.cellWidth);
    }

  }
}

class Player {
  int x;
  int y;
  int speed;
  int rectWidth;
  boolean finished;
  
  Player(int x, int y){
    this.x = x;
    this.y=y;
    this.speed = 1;
    this.rectWidth = 25;
  }
  
  void setX(int x){
    this.x = x;
  }
  
  void setY(int y){
    this.y=y;
  }
 
  int getX(){
    return this.x;
  }
  
  int getY(){
    return this.y;
  }
  
  int getRectWidth(){
    return this.rectWidth;
  }
  
  void display(){
    fill(255,255,255);
    noStroke();
    rect(this.x,this.y,this.rectWidth,this.rectWidth);
  }
  
  void moveRight(){
    this.x = this.x + 1 * this.speed;
  }
  
  void moveLeft(){
    this.x = this.x - 1 * speed;
  }
  
  void moveUp(){
    this.y = this.y - 1 * speed;
  }
  
  void moveDown(){
    this.y = this.y + 1 * speed;
  }
  
  boolean willCollideAhead(String direction){
    if (direction == "x"){
      for(int i=0; i<rectWidth; ++i){
        if (hex(get(this.x+this.rectWidth,this.y+i)).equals(hex(wall))
            || hex(get(this.x+this.rectWidth,this.y+i)).equals(hex(white))){
          return true;
        }
      }
    } else {
      for(int i=0; i<rectWidth; ++i){
        if (hex(get(this.x+i, this.y+this.rectWidth)).equals(hex(wall))
        || hex(get(this.x+i,this.y+this.rectWidth)).equals(hex(white))){
          return true;
        }
      }
    }
   return false;
  }
  
  boolean willCollideBehind(String direction){
    if (direction == "x"){
      for(int i=0; i<rectWidth; ++i){
        if (hex(get(this.x-1,this.y+i)).equals(hex(wall))
        || hex(get(this.x-1, this.y+i)).equals(hex(white))){
          return true;
        }
      }
    } else {
      for(int i=0; i<rectWidth; ++i){
        if (hex(get(this.x+i, this.y-1)).equals(hex(wall))
          || hex(get(this.x+i,this.y-1)).equals(hex(white))){
          return true;
        }
      }
    }
   return false;
  }
  
  boolean getFinished(){
    return this.finished;
  }
  
 void setFinished(boolean finished){
   this.finished = finished;
 }
}
