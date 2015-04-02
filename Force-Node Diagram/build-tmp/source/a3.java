import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class a3 extends PApplet {

int screenWidth = 1000;
int screenHeight = 1000;

Parser parser;
Node root;
Graph graph;

public void setup() {
    // PUT INPUT FILE NAME HERE
    String file = "data.csv";
    
    frameRate(20);
    
    size(screenWidth, screenHeight);
    if (frame != null) {
      frame.setResizable(true);
    }
  
    parser = new Parser();
    graph = parser.parse(file);
}

public void draw() {
    background(255);
    graph.calc_forces();
    graph.draw_graph();
}

public void mouseMoved() {
    graph.intersect(mouseX, mouseY);
}

public void mouseDragged() {
    graph.drag(mouseX, mouseY);
}

class Graph {
   Node[] nodes;
   Rels[] relations;
   float k_h, k_c, k_damp;
   float thresh;
   boolean start;
   
   Graph() { 
      k_h = .01f;
      k_c = 100*k_h;
      k_damp = .5f;
      thresh = 0;
      start = true;
   }
   public void draw_graph() {
       float total_KE = calc_KE();     
       if(total_KE > thresh || start) {
           //print("hello\n");
           update_with_forces();
           start = false;
       } else {
           print("you hit the threshold!\n");
       }
       draw_edges();
       draw_nodes();
   }

   //finds total coulumb and hooke's forces for all nodes
    public void calc_forces() {
        initialize_forces();
        //find_coulumb();
        find_hooke();
    }
   
   public float calc_KE() {
       float total = 0;
       for(int i = 0; i < nodes.length; i++) {
           total += nodes[i].KE;
       }
       print("total: ", total, "\n");
       return total;
   }
   
   public void update_with_forces() {
     for (int i = 0; i < nodes.length; i++) {
           //print(nodes[i].x, ", ", nodes[i].y, "\n");
           nodes[i].update_position(k_damp);
           //print(nodes[i].x, ", ", nodes[i].y, "\n");
       }
       
       for (int k = 0; k < relations.length; k++) {
           Node n1 = lookup(relations[k].node1);
           Node n2 = lookup(relations[k].node2);
           
           relations[k].update_act(n1.x, n1.y, n2.x, n2.y);
       }
   }
   
   public void draw_nodes() {
       int size = 0;
       for (int i = 0; i < nodes.length; i++) {
          stroke(0, 102, 153);
          if (nodes[i].intersect) {
          	fill(0);
          	textAlign(CENTER);
          	String label = "ID: " + nodes[i].id + ", MASS: " + nodes[i].mass;
          	text(label, nodes[i].x, nodes[i].y - nodes[i].mass);
          	fill (255, 0, 0);
          } else {
          	fill(16, 220, 250);
          }
          ellipse(nodes[i].x, nodes[i].y, 2*nodes[i].mass, 2*nodes[i].mass);
       }
     
   }
   
   public void draw_edges() {
     stroke(0, 102, 153);
     Node n1, n2;
     for (int i = 0; i < relations.length; i++) {
           n1 = lookup(relations[i].node1);
           n2 = lookup(relations[i].node2);
           line(n1.x, n1.y, n2.x, n2.y);
       }
   }
   
   public Node lookup(int id) {
       Node toret = null;
       for (int i = 0; i < nodes.length; i++) {
           if (nodes[i].id == id) {
              toret = nodes[i]; 
           }
       }
       return toret;
   }

    public void initialize_forces() {
       for(int i = 0; i < nodes.length; i++) {
          nodes[i].fx = 0;
          nodes[i].fy = 0;
       }
    }

    //for all nodes, finds coulumb forces from other nodes
    public void find_coulumb() {
        for (int i = 0; i < nodes.length; i++) {
            accumulate_coulumb(nodes[i]);
        }
    }

    //for a single node, find coulumb forces from other nodes
    public void accumulate_coulumb(Node n) {
        for (int i = 0; i < nodes.length; i++) {
            if (nodes[i].id != n.id) {
            	// restricts nodes from landing on top of each other
            	if (n.x == nodes[i].x) { n.x = n.x - 1; } 
            	if (n.y == nodes[i].y) { n.y = n.y + 1; }
            	n.fx += calc_coulumb(n.x, nodes[i].x);
            	n.fy += calc_coulumb(n.y, nodes[i].y); 
            }
        }
    }
    
    public float calc_coulumb(float target, float pusher) {
        int dir = check_dir(target, pusher);
        float force_c = dir * k_c / ((pusher - target));
        return force_c;
    }

    // for all edges, finds hooke force effects for both affected nodes
    public void find_hooke() {
        //print("finding hooke\n");
        Node n1, n2;
        for (int i = 0; i < relations.length; i++) {
           n1 = lookup(relations[i].node1);
           n2 = lookup(relations[i].node2);
           
           float ex = relations[i].act_edge_x;
           float rex = relations[i].r_edge_x;
           float ey = relations[i].act_edge_y;
           float rey = relations[i].r_edge_x;

           n1.fx += calc_hooke(n1.x, n2.x, ex, rex);
           n1.fy += calc_hooke(n1.y, n2.y, ey, rey);
           n2.fx += calc_hooke(n2.x, n1.x, ex, rex);
           n2.fy += calc_hooke(n2.y, n1.y, ey, rey);
           //print("in hooke: ", n1.fx, " ", n1.fy, "\n");
        }
    }
    
    public float calc_hooke(float target, float pusher, float e, float re) {
        int dir = check_dir(target, pusher);
        float force_h = -dir * k_h * (e - re);
        return force_h;
    }
    
    public int check_dir (float target, float pusher) {
        if (target < pusher) {
           return -1; 
        } else {
          return 1;
        }
    }

    public void intersect(int mousex, int mousey) {
    	for(int i = 0; i < nodes.length; i++) {
    		nodes[i].intersect(mousex, mousey);
    	}

    }

    public void drag(int mousex, int mousey) {
    	for (int i = 0; i < nodes.length; i++) {
    		nodes[i].drag(mousex, mousey);
    	}
    }
    
}
class Node {
   int id;
   float mass;
   Node parent;
   float dist_to_parent;
   float resting_dist;
   int num_children;
   float x, y;
   float fx, fy;
   float vx, vy;
   float ax, ay;
   float KE;
   boolean intersect;
   boolean drag;
   
   Node() {
       id = 0;
       mass = 0;
       dist_to_parent = 0;
       num_children = 0;
       resting_dist = 0;
       x = random(10, width-10);
       y = random(10, height-10);
       // x = height/2;
       // y = width/2;
       fx = 0;
       fy = 0;
       vx = 0;
       vy = 0;
       ax = 0;
       ay = 0;
       KE = 0;
       intersect = false;
       drag = false;
   }
   
   Node(int i, float mas) {
       id = i;
       mass = mas;
       dist_to_parent = 0;
       num_children = 0;
       resting_dist = 0;
       x = random(10, width-10);
       y = random(10, height-10);
       // x = height/2;
       // y = width/2;
   }
   
   public void update_position(float damp_const) {
      //assuming t = 1 frame
      float t = 1;
      
      //print(fx, ",", fy, "\n");
      //x
      ax = fx/mass;
      x = x + vx*t + .5f*ax*(t*t);
      vx = damp_const * (vx + ax*t);
      //print("x: ", x, "\n");
    
      //y
      ay = fy/mass;
      y = y + vy*t + .5f*ay*(t*t);
      vy = damp_const * (vy + ay*t);
      //print("y: ", y, "\n");
      
      KE = .5f * mass * ((vx*vx) + (vy*vy));
      //print("KE is ", KE, "\n");
      
      // if (x < 10) { x = 10; }
      // if (y < 10) { y = 10; }
      // if (x > width-10) { x = width - 10; }
      // if (y > height-10) { y = height - 10; }
    }
   
    public void intersect (int mousex, int mousey) {
    	float distance;
    	distance = sqrt(((mousex - x) * (mousex - x)) + ((mousey - y) * (mousey - y)));
    	if (distance < mass) { 
    		intersect = true; 
    	} else {
    		intersect = false;
    	}
    }

    public void drag (int mousex, int mousey) {
    	if (intersect) {
    		drag = true;
    		x = PApplet.parseFloat(mousex);
    		y = PApplet.parseFloat(mousey);
    	}
    }
}
class Parser {
  Node[] nodes;
  Rels[] relations;
  Graph graph;
  int f_place;
  int ult_root;
  
 public Graph parse(String file) {
       String[] lines = loadStrings(file);
       String[] split_line;
       graph = new Graph();
       
       find_nodes(lines);
       find_rels(lines);
       //attach_nodes();
       
       //print_rels();
       
       graph.nodes = nodes;
       graph.relations = relations;
       
       return graph;
  }
  
    
    public void find_nodes(String[] lines) {
      String[] split_line;
      split_line = splitTokens(lines[0], ",");
      int num_nodes = PApplet.parseInt(split_line[0]);
      nodes = new Node[num_nodes];

      for(f_place = 1; f_place <= num_nodes; f_place++) {
           nodes[f_place-1] = new Node();
           split_line = splitTokens(lines[f_place], ",");
           nodes[f_place-1].id = PApplet.parseInt(split_line[0]);
           nodes[f_place-1].mass = PApplet.parseFloat(split_line[1]);
       }

    }
    
    public void find_rels(String[] lines) { 
      String[] split_line;
      split_line = splitTokens(lines[f_place++], ",");
      int num_rels = PApplet.parseInt(split_line[0]);     
      int j = 0;  
      relations = new Rels[num_rels];

      for(; f_place < lines.length; f_place++) {
         relations[j] = new Rels();
         split_line = splitTokens(lines[f_place], ",");
         relations[j].node1 = PApplet.parseInt(split_line[0]);
         relations[j].node2  = PApplet.parseInt(split_line[1]);
         relations[j].rest_edge = PApplet.parseFloat(split_line[2]);
         relations[j].update_act(lookup(relations[j].node1).x, lookup(relations[j].node1).y, lookup(relations[j].node2).x, lookup(relations[j].node2).y);
         j++;
       }
    }
    
    public Node lookup(int id) {
       Node toret = null;
       for (int i = 0; i < nodes.length; i++) {
           if (nodes[i].id == id) {
              toret = nodes[i]; 
           }
       }
       return toret;
    }
  /*  
    void attach_nodes() {
       for (int i = 0; i < relations.length; i++) {
          for (int j = 0; j < nodes.length; j++) {
             if (relations[i].node1 == nodes[j].id) {
                relations[i].node1 = nodes[j].id;
             }
             if (relations[i].node2 == nodes[j].id) {
                relations[i].node2 = nodes[j];
             }
          }
       }
    }
  
    void print_rels() {
        for (int i = 0; i < relations.length; i++) {
            print("node1 = ", relations[i].node1.id, "node2 = ", relations[i].node2.id, "spring = ", relations[i].edge, "\n");
        }
    }
   */ 
}
class Rels {
  int node1;
  int node2;
  float rest_edge;
  float act_edge;
  float r_edge_x, r_edge_y;
  float act_edge_x, act_edge_y;
  
  public void update_act(float n1x, float n1y, float n2x, float n2y) {
      act_edge_x = abs(n1x - n2x);
      act_edge_y = abs(n1y - n2y);
      act_edge = sqrt((act_edge_x*act_edge_x) + (act_edge_y*act_edge_y));
      update_r();
  }
  
  public void update_r() {
    //act_edge should be updated
    if (act_edge_x == 0) {
      r_edge_x = 0;
      r_edge_y = rest_edge;
    } else {
      float theta_rad = atan(act_edge_y / act_edge_x);
      r_edge_x = rest_edge * cos(theta_rad);
      r_edge_y = rest_edge * sin(theta_rad);
    }

    /*if(rest_edge > act_edge) { print("expanding\n"); }
    else if (rest_edge < act_edge) { print("compressing\n"); }
    else { print("SAME!!!!!!!\n"); }
    print("REST: ", rest_edge, "\n");
    print("ACTUAL: ", act_edge, "\n");*/

    
    //print("REST: ", r_edge_x, ", ", r_edge_y, "\n");
    //print("ACTUAL: ", act_edge_x, ", ", act_edge_y, "\n");
  }
}

/*
int check_dir (float target, float pusher) {
    if (target < pusher) {
        return -1; 
    } else {
        return 1;
    }
}

- initialization function to calculate x and y values for edge and resting edge

- calculate new position before new velocity (first t, then a, then s, then v)

*/
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "a3" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
