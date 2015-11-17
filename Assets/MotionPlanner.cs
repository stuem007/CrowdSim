using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.Events;
using UnityEngine.UI;

public class MotionPlanner : MonoBehaviour {

	public GameObject Goal;
	public GameObject Agent;
    public GameObject StartObj;
	public Collider[] Obstacles;
	public static Vector3 minimum;
	public static Vector3 maximum;
    public GameObject startX;
    public GameObject startY;
    public GameObject goalX;
    public GameObject goalY;
	public static GameObject NodePrefab;
	public GameObject Prefab;
	public static GameObject Lines;
	public GameObject LinesObj;

	public float speed;
	public int pathIndex;
	public List<Node> path;

	void Start () {
        print("Starting");
		NodePrefab = Prefab;
		Lines = LinesObj;
        minimum = new Vector3(-9, 1, -9);
        maximum = new Vector3(9, 1, 9);
        buildConfigSpace();         
    }

    void Update()
    {
        // Get results from Dijkstra's algorithm
        if (Input.GetKeyDown("d"))
        {
			print("Djikstra");
            while (true)
            {
                Graph g = new Graph(40, 5, Obstacles);
                if (g.solnDijkstra.Count > 0)
                {
                    print("Dijkstra's Algorithm returned with path:");
                    for (int i = 0; i < g.solnDijkstra.Count; i++)
                    {
                        print(g.solnDijkstra[i].position);
                    }
					path = g.solnDijkstra;
                    break;
                }
            }
        }
        // Get results from A* algorithm
        else if (Input.GetKeyDown("a"))
        {
			print("A*");
            while (true)
            {
                Graph g = new Graph(40, 5, Obstacles);
                if (g.solnAStar.Count > 0)
                {
                    print("A* returned with path:");
                    for (int i = 0; i < g.solnAStar.Count; i++)
                    {
                        print(g.solnAStar[i].position);
                    }
					path = g.solnAStar;
                    break;
                }
            }
        }
		float step = speed * Time.deltaTime;
		if(path!=null)
		{
			if((Agent.transform.position == path[pathIndex].position) && (pathIndex!=path.Count-1))pathIndex++;
			Agent.transform.position = Vector3.MoveTowards(Agent.transform.position, path[pathIndex].position, step);
		}
    }

    public void updatePos()
    {
        Agent.transform.position = new Vector3(startX.GetComponent<Dropdown>().value - 9, 1, startY.GetComponent<Dropdown>().value - 9);
        Goal.transform.position = new Vector3(goalX.GetComponent<Dropdown>().value - 9, 1, goalY.GetComponent<Dropdown>().value - 9);
        StartObj.transform.position = Agent.transform.position;
    }

    public void buildConfigSpace()
    {
        Bounds a = Agent.GetComponent<Collider>().bounds;
        foreach (Collider c in Obstacles)
        {
            print(c);
            c.bounds.Expand(new Vector3(a.size.x, a.size.y, a.size.z));
        }
    }

    public class Node {
		public Vector3 position;
        public System.Collections.Generic.SortedList<float, Node> neighbors = new System.Collections.Generic.SortedList<float, Node>();
		public int neighborCount = 0;
        private int numNeighbors;
        GameObject NodeLight;

        public Node(){}
		public Node(Vector3 initPos, int k){
			position = initPos;
            //AddNodeLight();
            numNeighbors = k;
        }

		//Creates a node using boundary parameters to generate a random node for use with PRM
		public Node(Vector3 minBound, Vector3 maxBound, int k){
		// the Boundary is represented as a cube designated by the furthest vertices
		// minBound contains the minimum possible coordinates for the coordinate space
		// maxBound contains the maximum possible coordinates for the coordinate space
			position = new Vector3(Random.Range(minBound.x, maxBound.x), 1, Random.Range(minBound.z, maxBound.z));
            //AddNodeLight();
            numNeighbors = k;
		}

        private void AddNodeLight(){
            NodeLight = new GameObject("The Light");
            Light LightComp = NodeLight.AddComponent<Light>();
            LightComp.color = Color.magenta;
            NodeLight.transform.position = position;
            LightComp.range = 10F;
        }
		
		public bool addNeighbor(Node neighborNode, Collider[] obstacles){
			float distance = (neighborNode.position - position).magnitude;
            if (circleCollides(new Vector2(position.x, position.z), new Vector2(neighborNode.position.x, neighborNode.position.z), obstacles))
            {
                return false;
            }
            if (neighborCount < numNeighbors)
            {
                neighbors.Add(distance, neighborNode);
                neighborCount += 1;
            }
            else if (distance < neighbors.Keys[0])
            {
                neighbors.RemoveAt(0);
                neighbors.Add(distance, neighborNode);
            }

			return true;
		}



        public bool circleCollides(Vector2 pos1, Vector2 pos2, Collider[] obstacles)
        {
            float a = pos2.x - pos1.x;
            float b = pos1.y - pos2.y;
            float c = (pos1.x - pos2.x) * pos1.y + (pos2.y - pos1.y) * pos1.x;

            foreach (SphereCollider col in obstacles)
            {
                float xC = col.bounds.center.x;
                float yC = col.bounds.center.z;
                float rad = col.radius;

                float num = Mathf.Abs(a * xC + b * yC + c);
                float den = Mathf.Sqrt(a * a + b * b);

                if ((num / den) <= rad)
                {
                    return true;
                }
            }


            return false;
        }



        public bool willCollide(Vector3 neighborPos, Collider[] obstacles) {
			Ray posToNode = new Ray(position, (neighborPos - position));
			RaycastHit hitInfo;
			float distance = (neighborPos - position).magnitude;
            /*if (Physics.Raycast(position, (neighborPos - position), distance))
            {
                return true;
            }*/
			for(int i = 0; i < obstacles.Length; i++){
				if(obstacles[i].Raycast (posToNode, out hitInfo, distance) ){
					return true;
				}
			}
			return false;	
		}	
	}

	public class Graph {
		public Node[] contents;
		public int lastNode;

        private Node start;
        private Node goal;

        public List<Node> solnDijkstra, solnAStar;

        public Graph(){}
		//Create a graph of N nodes with each node having k nearest neighbors
		public Graph(int n, int k, Collider[] Obstacles){

            start = new Node(GameObject.Find("Start").transform.position, k);
            goal = new Node(GameObject.Find("Goal").transform.position, k);

            contents = new Node[n];
			for(int i = 0; i < n; i++){
				contents[i] = new Node(minimum, maximum, k);
			}
			// in our contents of the graph, we find the k-nearest neighbors for each node
			// we first go through each node
			for(int i = 0; i < n; i++){
                // for each node we go through each other node and add if it is one of our nearest neighbors
                for (int j = 0; j < n; j ++){
                    if (i != j)
                    {
                        contents[i].addNeighbor(contents[j], Obstacles);
                    }
                }
                contents[i].addNeighbor(goal, Obstacles);
			}
            // Find neighbors for starting node
            for (int i = 0; i < n; i++)
            {
                start.addNeighbor(contents[i], Obstacles);
            }
            start.addNeighbor(goal, Obstacles);
					
			for (int i = 0; i < n; i++){
				//Instantiate the node so we have a visual representation
				Instantiate(NodePrefab, contents[i].position, Quaternion.identity);
				Node[] neighbors = contents[i].neighbors.Values.ToArray();
				for (int j = 0; j < k; j++){
					//Create lines from the node to each nearest neighbor
					//Total of i*j*2 elements
					Lines.GetComponent<LineRenderer>().SetPosition((2*(i*neighbors.Length+j)), contents[i].position);
					Lines.GetComponent<LineRenderer>().SetPosition((2*(i*neighbors.Length+j)+1), neighbors[j].position);  
					//Debug.DrawLine(contents[i].position, neighbors[j].position);
				}
			}
			Node[] startNeighbors = start.neighbors.Values.ToArray();
			for (int i = 0; i < k; i++)
			{
                Lines.GetComponent<LineRenderer>().SetPosition((2 * n * k) + 2 * i, startNeighbors[i].position);
                Lines.GetComponent<LineRenderer>().SetPosition((2 * n * k) + 2 * i + 1, start.position);   
			}

            Solve soln = new Solve(start, goal);
            solnDijkstra = soln.Dijkstra();
            solnAStar = soln.AStar();        
        }
	}


    public class Solve
    {
        Node start;
        Node goal;

        public Solve(Node startIn, Node goalIn){
            start = startIn;
            goal = goalIn;
        }

        public List<Node> Dijkstra(){
            List<Path> paths = new List<Path>();
            float curCost;
            float newCost;
            List<Node> curList = new List<Node>();
            List<Node> newList;
            Node curNode;
            Node curNeighbor;
            curList = new List<Node>();
            curList.Add(start);
            paths.Add(new Path(0, curList));

            int maxPaths = 0;

            while (paths.Count > 0 && paths.Count < 300)
            {
                if (paths.Count > maxPaths)
                {
                    maxPaths = paths.Count;
                }
                paths.Sort((x, y) => x.distance.CompareTo(y.distance));
                curCost = paths[0].distance;
                curList = paths[0].list;
                paths.RemoveAt(0);
                curNode = curList[curList.Count - 1];

                if (curNode.neighbors.Count > 0)
                {
                    for (int i = 0; i < curNode.neighbors.Count; i++)
                    {
                        curNeighbor = curNode.neighbors.Values[i];
                        if (!curList.Any(f => f.position == curNeighbor.position)){
                            newCost = curCost + distance(curNode, curNeighbor);
                            newList = new List<Node>();
                            newList.AddRange(curList);
                            newList.Add(curNeighbor);
                            paths.Add(new Path(newCost, newList));
                            if (curNeighbor.position == goal.position)
                            {
                                return newList;
                            }
                        }                
                    }     
                }
            }
            return new List<Node>();
        }



        public List<Node> AStar(){
            List<Path> paths = new List<Path>();
            float curGx;
            float newFx;
            float newGx;
            List<Node> curList = new List<Node>();
            List<Node> newList;
            Node curNode;
            Node curNeighbor;
            curList = new List<Node>();
            curList.Add(start);
            paths.Add(new Path(0, 0, curList));

            int maxPaths = 0;

            while (paths.Count > 0 && paths.Count < 300)
            {
                if (paths.Count > maxPaths)
                {
                    maxPaths = paths.Count;
                }
                paths.Sort((x, y) => x.fx.CompareTo(y.fx));
                curGx = paths[0].gx;
                curList = paths[0].list;
                paths.RemoveAt(0);
                curNode = curList[curList.Count - 1];

                if (curNode.neighbors.Count > 0)
                {
                    for (int i = 0; i < curNode.neighbors.Count; i++)
                    {
                        curNeighbor = curNode.neighbors.Values[i];
                        if (!curList.Any(f => f.position == curNeighbor.position))
                        {
                            newGx = curGx + distance(curNode, curNeighbor);
                            newFx = newGx + distance(curNeighbor, goal);
                            newList = new List<Node>();
                            newList.AddRange(curList);
                            newList.Add(curNeighbor);
                            paths.Add(new Path(newFx, newGx, newList));
                            if (curNeighbor.position == goal.position)
                            {
                                return newList;
                            }
                        }
                    }
                }
            }
            return new List<Node>();
        }

        private float distance(Node n1, Node n2){
            return (n2.position - n1.position).magnitude;
        }

        private class Path{
            public float distance, fx, gx;
            public List<Node> list;

            public Path(float distanceIn, List<Node> listIn){
                distance = distanceIn;
                list = listIn;
            }
            public Path(float fxIn, float gxIn, List<Node> listIn)
            {
                fx = fxIn;
                gx = gxIn;
                list = listIn;
            }
        }
    }
}
