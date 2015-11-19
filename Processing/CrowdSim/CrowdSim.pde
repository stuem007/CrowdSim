ArrayList<Node> Nodes = new ArrayList<Node>();
ArrayList<Node> Obstacles = new ArrayList<Node>();
ArrayList<Node> Agents = new ArrayList<Node>();
ArrayList<Node> Starts = new ArrayList<Node>();
Node Goal;
ArrayList<ArrayList<Node>> paths = new ArrayList<ArrayList<Node>>();
float lastTime;
float currentTime;
float dT;
float timeCount = 0;
int nodeCt = 100;
float agentSpeed = 70;

void setup()
{  
  size(500, 500, P2D);
  surface.setTitle("Evan Stuempfig Alex Westby Assignment 5");
  
  createGoal();
  createObstacles();
  createAgents();
  createNodes();
  
  findNeighbors();
  
  Node[] graph = new Node[nodeCt + 2];
  for (int i = 0; i < nodeCt; i ++)
  {
    graph[i + 1] = Nodes.get(i); 
  }
  graph[nodeCt + 1] = Goal;
  
  for (Node st : Starts)
  {
    graph[0] = st;
    paths.add(Dijkstra(graph, st));
    print("path found:\n");
    for (Node n : paths.get(paths.size() - 1))
    {
      print(n.pos + "\n"); 
    }
  }
  
  lastTime = millis();
}

void createGoal()
{ 
  PShape cir = createShape(ELLIPSE, 480, 480, 20, 20);
  cir.setFill(color(255, 0, 0));
  cir.setStroke(255);
  Goal = new Node(new PVector(480, 480), 20, cir, nodeCt + 1);   
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
    
    Obstacles.add(new Node(new PVector(x, y), rad, cir, 0)); 
  }
}

void createAgents()
{
  PShape cir = createShape(ELLIPSE, 20, 20, 20, 20);
  cir.setFill(color(0, 0, 255));
  cir.setStroke(255);
  Agents.add(new Node(new PVector(20, 20), 20, cir, 0));
  cir = createShape(ELLIPSE, 20, 20, 20, 20);
  cir.setFill(color(0, 0, 125));
  cir.setStroke(255);
  Starts.add(new Node(new PVector(20, 20), 20, cir, 0));   
  
  cir = createShape(ELLIPSE, 220, 20, 20, 20);
  cir.setFill(color(0, 0, 255));
  cir.setStroke(255);
  Agents.add(new Node(new PVector(220, 20), 20, cir, 0));
  cir = createShape(ELLIPSE, 220, 20, 20, 20);
  cir.setFill(color(0, 0, 125));
  cir.setStroke(255);
  Starts.add(new Node(new PVector(220, 20), 20, cir, 0));
  
  cir = createShape(ELLIPSE, 300, 20, 20, 20);
  cir.setFill(color(0, 0, 255));
  cir.setStroke(255);
  Agents.add(new Node(new PVector(300, 20), 20, cir, 0));
  cir = createShape(ELLIPSE, 300, 20, 20, 20);
  cir.setFill(color(0, 0, 125));
  cir.setStroke(255);
  Starts.add(new Node(new PVector(300, 20), 20, cir, 0));
  
  cir = createShape(ELLIPSE, 400, 20, 20, 20);
  cir.setFill(color(0, 0, 255));
  cir.setStroke(255);
  Agents.add(new Node(new PVector(400, 20), 20, cir, 0));
  cir = createShape(ELLIPSE, 400, 20, 20, 20);
  cir.setFill(color(0, 0, 125));
  cir.setStroke(255);
  Starts.add(new Node(new PVector(400, 20), 20, cir, 0));
  
  cir = createShape(ELLIPSE, 450, 20, 20, 20);
  cir.setFill(color(0, 0, 255));
  cir.setStroke(255);
  Agents.add(new Node(new PVector(450, 20), 20, cir, 0));
  cir = createShape(ELLIPSE, 450, 20, 20, 20);
  cir.setFill(color(0, 0, 125));
  cir.setStroke(255);
  Starts.add(new Node(new PVector(450, 20), 20, cir, 0));
}

void createNodes()
{
  float x, y;
  PVector pos;
  int ct = 0;
  boolean valid;
  while (ct < nodeCt)
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
    
    for (Node ag : Agents)
    {  
      if (PVector.sub(pos, ag.pos).mag() < ag.rad)
      {
        valid = false;
      }
    }
    
    if (PVector.sub(pos, Goal.pos).mag() < Goal.rad + 10)
    {
      valid = false;
    }
    
    if (valid)
    {
      ct ++;
      Nodes.add(new Node(pos, 10, cir, ct));  
    }
  }
}

void findNeighbors()
{
  int sz = Nodes.size();
  Node nI, nJ;
  for (int i = 0; i < sz; i ++)
  {
    nI = Nodes.get(i);
    for (int j = 0; j < sz; j ++)
    {     
      nJ = Nodes.get(j);
      if (i != j && PVector.sub(nI.pos, nJ.pos).mag() < 100 && !circleCollides(nI.pos, nJ.pos))
      {
        nI.neighbors.add(nJ);
      }
    }
    for (Node st : Starts)
    {
      if (PVector.sub(st.pos, nI.pos).mag() < 100 && !circleCollides(st.pos, nI.pos))
      {
        st.neighbors.add(nI);
      }
    }
    if (PVector.sub(nI.pos, Goal.pos).mag() < 100 && !circleCollides(nI.pos, Goal.pos))
      {
        nI.neighbors.add(Goal);
      }
  }
}

boolean circleCollides(PVector pos1, PVector pos2)
{
    /*float a = pos2.x - pos1.x;
    float b = pos1.y - pos2.y;
    float c = (pos1.x - pos2.x) * pos1.y + (pos2.y - pos1.y) * pos1.x;

    for (Node ob : Obstacles)
    {
        float xO = ob.pos.x;
        float yO = ob.pos.y;
        float rad = ob.rad + 10;

        float num = Math.abs(a * xO + b * yO + c);
        float den = (float)Math.sqrt(a * a + b * b);

        if ((num / den) <= rad)
        {
            return true;
        }
    }*/
    return false;
}

void draw()
{
  
  background(70, 70, 70); 

  currentTime = millis();
  dT = (currentTime - lastTime) / 1000;
  surface.setTitle((1 / dT) + " FPS");
  lastTime = currentTime;
  updateAgents(dT);
  
  shape(Goal.shape); 
  
  for (Node n : Obstacles)
  {
    shape(n.shape);
  }
  
  for (Node n : Agents)
  {
    shape(n.shape);
  }
  
  stroke(125);
  for (Node n : Starts)
  {
    shape(n.shape);
    for (Node nb : n.neighbors)
    {
       line(n.pos.x, n.pos.y, nb.pos.x, nb.pos.y);
    }
  }
  
  for (Node n : Nodes)
  {
    shape(n.shape); 
    for (Node nb : n.neighbors)
    {
       line(n.pos.x, n.pos.y, nb.pos.x, nb.pos.y);
    }
  }
  
  stroke(0);
  for (ArrayList<Node> p : paths)
  {
    for (int i = 0; i < p.size() - 1; i ++)
    {
      line(p.get(i).pos.x, p.get(i).pos.y, p.get(i + 1).pos.x, p.get(i + 1).pos.y); 
    }
  }
}




void updateAgents(float dT)
{
  for (int i = 0; i < Agents.size(); i ++)
  {
    Node ag = Agents.get(i);
    
    if (!ag.finished)
    {  
      Node goal = paths.get(i).get(ag.goal);
      
      PVector change = PVector.mult(PVector.sub(goal.pos, ag.pos).normalize(), agentSpeed * dT);
      
      for (int j = 0; j < Agents.size(); j++)
      {
        if (i != j)
        {
          Node cmp = Agents.get(j);
          PVector dir = PVector.sub(cmp.pos, ag.pos);
          if (!cmp.finished && dir.mag() < 20)
          {
            PVector diff = PVector.mult(PVector.mult(dir.normalize(), -1), 7 / dir.mag()); 
            change.add(diff);
          }        
        }
      }
      
      ag.pos.add(change);
      ag.shape.translate(change.x, change.y);
      
      if (PVector.sub(goal.pos, ag.pos).mag() < 5)
      {
        if (ag.goal < paths.get(i).size() - 1)
        {
          ag.goal ++;
        }
        else if (PVector.sub(goal.pos, ag.pos).mag() < 0.5)
        {
          ag.finished = true; 
        }
      }
    }
  }  
}



class Node
{
  PVector pos;
  float rad;
  PShape shape;
  ArrayList<Node> neighbors = new ArrayList<Node>();
  int ind;
  int goal = 0;
  boolean finished = false;
  
  public Node(PVector posIn, float radIn, PShape shapeIn, int indIn)
  {
    pos = posIn;
    rad = radIn;
    shape = shapeIn;
    ind = indIn;
  }   
}

ArrayList<Node> Dijkstra(Node[] graph, Node agent)
{ 
  int len = graph.length;
  ArrayList<Node> Q = new ArrayList<Node>();
  float[] dist = new float[len];
  int[] prev = new int[len];
  
  for (int i = 0; i < len; i ++)
  {
    Q.add(graph[i]);
    dist[i] = 10000;
    prev[i] = -1;
  }
  
  dist[0] = 0;
  
  Node cur;
  float alt;
  int target = 0;
  
  print("entering 'while' loop with Q size " + Q.size() + "\n");
  while (Q.size() > 0)
  {
    float minVal = 10000;
    int qIndex = 0;
    int graphIndex = 0;
    for (int i = 0; i < Q.size(); i ++)
    {
      if (dist[Q.get(i).ind] < minVal)
      {
          minVal = dist[Q.get(i).ind];
          qIndex = i;
      }
    }
    print("Min dist is: " + minVal + "\n");
    cur = Q.get(qIndex);
    graphIndex = cur.ind;
    if (graphIndex == nodeCt + 1)
    {
      print("breaking early\n");
      target = graphIndex;
      break;  
    }
    Q.remove(qIndex);
    
    for (Node nb : cur.neighbors)
    {
      alt = dist[graphIndex] + PVector.sub(cur.pos, nb.pos).mag();
      print("alt is " + alt + ", old alt is " + dist[nb.ind] + "\n");
      if (alt < dist[nb.ind])
      {
        dist[nb.ind] = alt;
        prev[nb.ind] = graphIndex;
      }
    }    
  }
  
  ArrayList<Node> path = new ArrayList<Node>();
  if (target != 0)
  {
    path.add(graph[target]);
    while (prev[target] != -1)
    {
      path.add(0, graph[prev[target]]);
      target = prev[target];
    }
  }
  return path;
}