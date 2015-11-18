ArrayList<Node> Nodes = new ArrayList<Node>();
ArrayList<Node> Obstacles = new ArrayList<Node>();
ArrayList<Node> Actors = new ArrayList<Node>();
Node Goal;
//ArrayList<Particle> fountainParticles = new ArrayList<Particle>();
//ArrayList<Particle> expired = new ArrayList<Particle>();
float lastTime;
float currentTime;
float dT;
float camX;
float camY;
float camZ;
float ctrX;
float ctrY;
float ctrZ;
float timeCount = 0;

void setup()
{  
  size(500, 500, P2D);
  surface.setTitle("Evan Stuempfig Alex Westby Assignment 5");
  
  createGoal();
  createObstacles();
  createActors();
  createNodes();
  
  camX = width / 2.0;
  camY = height / 2.0;
  camZ = (height / 2.0) / tan(PI * 30.0 / 180.0);
  
  ctrX = width / 2.0;
  ctrY = height / 2.0;
  ctrZ = 0;
  
  lastTime = millis();
}

void createGoal()
{ 
  PShape cir = createShape(ELLIPSE, 480, 480, 20, 20);
  cir.setFill(color(255, 0, 0));
  cir.setStroke(255);
  Goal = new Node(new PVector(480, 480), 20, cir);   
}

void createObstacles()
{
  float x, y, rad;
  for (int i = 0; i < 5; i ++)
  {
    x = random(100, 400);
    y = random(100, 400);
    rad = random(50, 100);
    
    PShape cir = createShape(ELLIPSE, x, y, rad, rad);
    cir.setFill(color(0, 255, 0));
    cir.setStroke(255);
    
    Obstacles.add(new Node(new PVector(x, y), rad, cir)); 
  }
}

void createActors()
{
  PShape cir = createShape(ELLIPSE, 20, 20, 20, 20);
  cir.setFill(color(0, 0, 255));
  cir.setStroke(255);
  Actors.add(new Node(new PVector(20, 20), 20, cir));   
}

void createNodes()
{
  float x, y;
  PVector pos;
  int ct = 0;
  boolean valid;
  while (ct < 100)
  {
    valid = true;
    x = random(10, 490);
    y = random(10, 490);
    
    PShape cir = createShape(ELLIPSE, x, y, 10, 10);
    cir.setFill(color(255, 165, 0));
    cir.setStroke(255);
    pos = new PVector(x, y);
    
    for (Node ob : Obstacles)
    {  
      if (PVector.sub(pos, ob.pos).mag() < ob.rad)
      {
        valid = false;
      }
    }
    
    for (Node act : Actors)
    {  
      if (PVector.sub(pos, act.pos).mag() < act.rad)
      {
        valid = false;
      }
    }
    
    if (PVector.sub(pos, Goal.pos).mag() < Goal.rad)
    {
      valid = false;
    }
    
    if (valid)
    {
      ct ++;
      Nodes.add(new Node(pos, 10, cir));  
    }
  }
}

void draw()
{
  
  background(70, 70, 70); 
  
  //createRuntimeObjects();
  
  currentTime = millis();
  dT = (currentTime - lastTime) / 1000;
  surface.setTitle((1 / dT) + " FPS");
  lastTime = currentTime;
  //updateBallObjects(2 * dT);
 // updateFountainObjects(2 * dT);
  
  /*for (Particle p : ballParticles)
  {
    shape(p.shape);
  }
  
  for (Particle p: fountainParticles)
  {
    shape(p.shape); 
  }*/
  
  shape(Goal.shape); 
  
  for (Node n : Obstacles)
  {
    shape(n.shape);
  }
  
  for (Node n : Actors)
  {
    shape(n.shape); 
  }
  
  for (Node n : Nodes)
  {
    shape(n.shape); 
  }
   
}



class Node
{
  PVector pos;
  float rad;
  PShape shape;
  
  public Node(PVector posIn, float radIn, PShape shapeIn)
  {
    pos = posIn;
    rad = radIn;
    shape = shapeIn;
  }  
  
}