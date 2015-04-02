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

public class a4 extends PApplet {

//This is the controller pretty much

int screenWidth = 800;
int screenHeight = 800;
Data data;
Heatmap heatmap;
Message message;
Cat_View categ;
ForceGraph graph;
int heatmap_x1, heatmap_x2;
int heatmap_y1, heatmap_y2;
float cat_x1, cat_x2;
float cat_y1, cat_y2;
int graph_x1, graph_x2;
int graph_y1, graph_y2;
int press_x, press_y;
Rect[] rects;
Rect curr;
int curr_section;

public void setup() {
  size(screenWidth, screenHeight);
  if (frame != null) {
    frame.setResizable(true);
  }
  data = new Data();
  data.parse("data_aggregate.csv");

  graph_x1 = 0;
  graph_x2 = 2 * width/3 - 20;
  graph_y1 = 0;
  graph_y2 = 2 * height/3 - 75;

  graph = new ForceGraph(data, graph_x2 - graph_x1, graph_y2 - graph_y1);
  heatmap = new Heatmap(data);
  categ = new Cat_View(data);
  message = new Message();
  rects = new Rect[0];
  press_x = -1;
  press_y = -1;
}

public void draw() {
  background(255, 255, 255);

  heatmap_x1 = 0;
  heatmap_x2 = width;
  heatmap_y1 = 2 * height/3;
  heatmap_y2 = height;

  cat_x1 = 2 * width/3;
  cat_x2 = width;
  cat_y1 = height/6;
  cat_y2 = 2 * height/3;

  graph_x1 = 0;
  graph_x2 = 2 * width/3;
  graph_y1 = 0;
  graph_y2 = 2 * height/3;
  graph.calc_forces();

  message = heatmap.draw_heatmap(heatmap_x1, heatmap_x2, heatmap_y1, heatmap_y2, message, rects);
  message = graph.draw_graph(graph_x1, graph_x2, graph_y1, graph_y2, message, rects);
  //fill(0, 0, 0);
  message = categ.draw_cat_view(cat_x1, cat_x2, cat_y1, cat_y2, message, rects);
  
  draw_rects();
}

public void mouseMoved() {
  graph.intersect(mouseX, mouseY);
}

public void mouseClicked(MouseEvent e) {
  if (e.getButton() == RIGHT) {
    rects = new Rect[0];
    message = new Message();
  }
}

public void mousePressed(MouseEvent e) {
  if (e.getButton() == RIGHT) {
    rects = new Rect[0];
    message = new Message();
  }
  press_x = mouseX;
  press_y = mouseY;
  curr_section = which_section(press_x, press_y);
  //print(curr_section);

  curr = new Rect(press_x, mouseX, press_y, mouseY);
  rects = (Rect[])append(rects, curr);
}

public void mouseDragged(MouseEvent e) {
  if (e.getButton() == RIGHT) {
    rects = new Rect[0];
    message = new Message();
    return;
  }
  int bounded_x, bounded_y;
  if ((press_x != -1) && (press_y != -1)) {
    if (curr_section == which_section(mouseX, mouseY)) {
        curr.set_dim(press_x, mouseX, press_y, mouseY);
    } else {
        bounded_x = mouseX;
        bounded_y = mouseY;
        if (curr_section == 0) {
           if (mouseX > cat_x1) {
             bounded_x = PApplet.parseInt(cat_x1);
           }
           if (mouseY > heatmap_y1) {
             bounded_y = heatmap_y1;
           }
        } else if (curr_section == 1) {
           if (mouseX < cat_x1) {
             bounded_x = PApplet.parseInt(cat_x1);
           }
           if (mouseY > heatmap_y1) {
             bounded_y = heatmap_y1;
           }
        } else {
           if (mouseY < heatmap_y1) {
             bounded_y = heatmap_y1;
           }
        }
      
        curr.set_dim(press_x, bounded_x, press_y, bounded_y);
    }
  }

  //graph.drag(mouseX, mouseY);
}

public void draw_rects() {
  for (int i = 0; i < rects.length; i++) {
    rects[i].draw_rect();
  }
}

public int which_section(int x, int y) {
    if (y < heatmap_y1) {
      if (x < cat_x1) {
          return 0;
      } else {
          return 1;
      }
    } else {
      return 2;
    }
}

class Cat_Bar {
  String title;
  Event[] data_big;
  String[] data;
  int num_points;
  int index_key;

  float xl, xr;
  float yt, yb;
  float wid, hgt;

  int num_fields;
  String[] fields;

  int highlight_mouse;
  int highlight_message;

  Cat_Bar(Event[] parsed, String category, int _key) {
    xl = 0;
    xr = 0;
    yt = 0;
    yb = 0;
    wid = 0;
    hgt = 0;
    highlight_mouse = color(255, 200, 0);
    highlight_message = color(255, 170, 0);

    data_big = parsed;
    title = category;
    index_key = _key;

    num_points = data_big.length;
    data = new String[num_points];
    extract_data();

    num_fields = 0;
    fields = new String[0];
    find_fields();
  }

  public void extract_data() {
    switch(index_key) {
    case 5: //Syslog priority
      for (int i = 0; i < num_points; i++) {
        data[i] = data_big[i].priority;
      }
      break;
    case 6: //Operation
      for (int i = 0; i < num_points; i++) {
        data[i] = data_big[i].operation;
      }
      break;
    case 7: //Protocol
      for (int i = 0; i < num_points; i++) {
        data[i] = data_big[i].protocol;
      }
      break;
    default:
      print("ERROR: Data headings not in expected format");
    }
  }

  public void find_fields() {
    for (int i = 0; i < num_points; i++) {
      if (!member(data[i], fields)) {
        fields = append(fields, data[i]);
        num_fields++;
      }
    }
  }

  public boolean member(String data, String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (data.equals(array[i])) {
        return true;
      }
    } 
    return false;
  }

  public void draw_graph(float xl, float xr, float yt, float yb, Message msg, Rect[] rs) {
    make_canvas(xl, xr, yt, yb); 
    print_header();
    draw_bars(msg, rs);
  }

  public void make_canvas(float _xl, float _xr, float _yt, float _yb) {
    yt = _yt;
    yb = _yb;
    xl = _xl;
    xr = _xr;

    wid = xr - xl;
    hgt = yb - yt;
  }

  public void print_header() {
    textSize(10);
    fill(200, 0, 0);
    text(title, ((xl + xr) / 2), (yt - 12));
  }

  public void draw_bars(Message msg, Rect[] rs) {
    float run_top = yt;
    float temp_h = 0;

    for (int i = 0; i < num_fields; i++) {
      float field_percent = (count_occurrence(fields[i], data) / num_points);    
      temp_h = field_percent * hgt;

      //draw original rectangle
      if (num_fields == 1) {
        fill(0, 195, 255);
      } else {
        fill(map(i, 0, num_fields - 1, 0, 255), map(i, 0, num_fields - 1, 195, 0), map(i, 0, num_fields - 1, 255, 0));
      }

      rect(xl, run_top, wid, temp_h);

      //draw highlight rectangle on top          
      if (intersect(xl, xl + wid, run_top, run_top + temp_h)) {
        fill(highlight_mouse);
        //add to message
        rect(xl, run_top, wid, temp_h);
      } else {
        fill(highlight_message);
        float highlight_percent = find_highlight(msg, fields[i]);
        float highlight_top = (1 - highlight_percent) * (temp_h) + run_top;
        rect(xl, highlight_top, wid, highlight_percent * temp_h);
      }

      //add chunk label
      fill(0, 0, 0);
      if (temp_h < 10) {
        text(fields[i], (xl + xr) / 2, run_top - 6);
      } else {
        text(fields[i], (xl + xr) / 2, run_top + (temp_h / 2));
      }

      //update for next chunk
      run_top += temp_h;
    }
  }

  public float find_highlight(Message msg, String field) {
    int[] hl_ind = new int[0];
    int hl_count = 0;
    float chunk_count = count_occurrence(field, data);

    for (int i = 0; i < num_points; i++) {
      //determine if point even falls into chunk
      switch(index_key) {
      case 5: //Syslog priority
        if (field.equals(data_big[i].priority)) {
          hl_ind = append(hl_ind, i);
        }
        break;
      case 6: //Operation
        if (field.equals(data_big[i].operation)) {
          hl_ind = append(hl_ind, i);
        }
        break;
      case 7: //Protocol
        if (field.equals(data_big[i].protocol)) {
          hl_ind = append(hl_ind, i);
        }
        break;
      }
    } 
    
    //if in chunk, check if in message
    if (hl_ind.length > 0) {
      /*
      for(int i = 0; i < hl_ind.length; i++) {
        if (is_in_array_flt(data_big[hl_ind[i]].time, msg.time)) {
          hl_count++;
        } else if (is_in_array(data_big[hl_ind[i]].src_ip, msg.src_ip)) {
          hl_count++;
        } else if (is_in_array(data_big[hl_ind[i]].src_port, msg.src_port)) {
          hl_count++;
        } else if (is_in_array(data_big[hl_ind[i]].dest_ip, msg.dest_ip)) {
          hl_count++;
        } else if (is_in_array(data_big[hl_ind[i]].dest_port, msg.dest_port)) {
          hl_count++;
        } else if (is_in_array(data_big[hl_ind[i]].priority, msg.priority)) {
          hl_count++;
        } else if (is_in_array(data_big[hl_ind[i]].operation, msg.operation)) {
          hl_count++;
        } else if (is_in_array(data_big[hl_ind[i]].protocol, msg.protocol)) {
          hl_count++;
        }
      }
      */
    }
    return hl_count / chunk_count;
  }
  
  public boolean is_in_array_flt(float val, float[] arr) {
    for(int i = 0; i < arr.length; i++) {
      if(val == arr[i]) {
        return true;
      }
    }
    return false; 
  }
  
  public boolean is_in_array(String val, String[] arr) {
    for(int i = 0; i < arr.length; i++) {
      if(val.equals(arr[i])) {
        return true;
      }
    }
    return false;
  }

  public float count_occurrence(String s, String[] array) {
    float count = 0;
    for (int i = 0; i < num_points; i++) {
      if (s.equals(array[i])) {
        count++;
      }
    } 

    return count;
  }

  public boolean intersect(float xl, float xr, float yt, float yb) {
    if ((mouseX > xl) && (mouseX < xr)) {
      if ((mouseY > yt) && (mouseY < yb)) {
        return true;
      }
    }

    return false;
  }
}

class Cat_View {
  Data data;
  Cat_Bar[] graphs;
  int num_graphs;
  
  float xl, yt;
  float canvas_w, canvas_h;
  
  Cat_View(Data parsed) {
    num_graphs = 3;
    graphs = new Cat_Bar[num_graphs];
    data = parsed;
    
    for(int i = 0; i < num_graphs; i++) {
      graphs[i] = new Cat_Bar(data.events, data.header[5 + i], 5 + i);
    }
  }
  
  public Message draw_cat_view(float x1, float x2, float y1, float y2, Message msg, Rect[] rs) {
    xl = x1;
    yt = y1;
    canvas_w = x2 - x1;
    canvas_h = y2 - y1;
    
    int num_chunks = 2 * num_graphs + 1;
    float spacing = (1.0f / num_chunks) * canvas_w;

    for(int i = 0; i < num_graphs; i++) {
      int mag_num = 2 * i + 1;
      
      graphs[i].draw_graph(x1 + (mag_num * spacing),
                           x1 + ((mag_num * spacing) + spacing),
                           y1 + 20,
                           y2,
                           msg, rs );
    }     
    
    return msg;
  }  
}

class Data { 
  String[] header;
  int num_cols;
  Event[] events;

  //Modularity: Could've taken in delimeters
  public void parse(String file) {
    String[] lines = loadStrings(file);
    String[] split_line;

    readHeader(lines[0]);

    events = new Event[lines.length - 1];
    for (int i = 1; i < lines.length; i++) {
      split_line = splitTokens(lines[i], ",");
      events[i - 1] = new Event(convert_time(split_line[0]), split_line[1], split_line[2], 
      split_line[3], split_line[4], split_line[5], 
      split_line[6], split_line[7]);
    }
  }

  public void readHeader(String line1) {
    header = new String[8];

    //given CSV has header delimited by ',' & ' '
    header = splitTokens(line1, ",");
    /*print("Headers: \n");
     printArray(header);
     print('\n');*/
  }

  public float convert_time(String input) {
    float hours, minutes, seconds;

    if (input.charAt(1) == ':') {
      hours = new Float(input.substring(0, 1));
      minutes = new Float(input.substring(2, 4));
      seconds = new Float(input.substring(5, 7));
    } else {
      hours = new Float(input.substring(0, 2));
      minutes = new Float(input.substring(3, 5));
      seconds = new Float(input.substring(6, 8));
    }

    float total = 3600 * hours + 60 * minutes + seconds;

    //print(hour, " ", minutes, " ", seconds, " ", total);

    return total;
  }
}

class Event {
     float time;
     String src_ip;
     String src_port;
     String dest_ip;
     String dest_port;
     String priority;
     String operation;
     String protocol;
     
     Event(float t, String sip, String sport, String dip, 
           String deport, String prior, String op, String proto) {
         time = t;
         src_ip = sip;
         src_port = sport;
         dest_ip = dip;
         dest_port = deport;
         priority = prior;
         operation = op;
         protocol = proto;     
     }
}
class ForceGraph {
  ForceNode[] nodes;
  ForceRels[] relations;
  float k_h, k_c, k_damp, k_mid;
  float thresh;
  boolean start;
  int last_h, last_w;
  int canv_h, canv_w;
  float total_KE;
  float x_1, x_2, y_1, y_2;
  Message message;
  Rect[] rect;

  ForceGraph(Data data, int canvas_w, int canvas_h) {
    canv_w = canvas_w;
    canv_h = canvas_h; 
    ForceParse parser = new ForceParse(data, canv_w, canv_h);
    nodes = parser.nodes;
    relations = parser.relations;

    k_h = .2f;
    k_c = 10000*nodes.length;
    k_damp = .4f;
    k_mid = .5f;
    thresh = 0;
    start = true;
  }

  public Message draw_graph(int x1, int x2, int y1, int y2, Message msg, Rect[] r) {
    x_1 = x1;
    x_2 = x2;
    y_1 = y1;
    y_2 = y2;
    message = msg;
    rect = r;

    total_KE = calc_KE();
    if (total_KE > thresh || start) {
      update_with_forces();
      start = false;
      last_h = canv_h;
      last_w = canv_w;
    } else {
      if ((canv_w != last_w) || (canv_h != last_h)) {
        start = true;
      }
    }

    refresh_message();
    refresh_highlight();

    draw_edges();
    highlighting();
    update_message();
    draw_nodes();
    
    return message;
  }

  //finds total coulumb and hooke's forces for all nodes
  public void calc_forces() {
    initialize_forces();
    find_coulumb();
    find_hooke();
    find_middle();
  }

  public float calc_KE() {
    float total = 0;
    for (int i = 0; i < nodes.length; i++) {
      total += nodes[i].KE;
    }
    return total;
  }

  public void update_with_forces() {
    for (int i = 0; i < nodes.length; i++) {
      nodes[i].update_position(k_damp, x_1, x_2, y_1, y_2);
    }

    for (int k = 0; k < relations.length; k++) {
      ForceNode n1 = lookup(relations[k].node1);
      ForceNode n2 = lookup(relations[k].node2);

      relations[k].update_curr(n1.x, n1.y, n2.x, n2.y);
    }
  }

  public void refresh_message() {
  	message.src_ip = new String[0];
  	message.dest_ip = new String[0];
  }

  public void update_message() {
  	//int xleft, xright, ytop, ybot;
  	for(int i = 0; i < rects.length; i++) {
  		for(int k = 0; k < relations.length; k++) {
  			//updating message based on rectangles
  			if(in_rect(lookup(relations[k].node1), rect[i])) {
  				lookup(relations[k].node1).highlight = true;
  				message.add_src_ip(relations[k].node1);
  				message.add_dest_ip(relations[k].node1);
  			}
  			if(in_rect(lookup(relations[k].node2), rect[i])) {
  				lookup(relations[k].node2).highlight = true;
  				message.add_src_ip(relations[k].node2);
  				message.add_dest_ip(relations[k].node2);
  			}
  		}
  	}
  }

  public boolean in_rect(ForceNode node, Rect r) {
  	if(node.x > r.xleft && node.x < r.xright) {
  		if (node.y > r.ytop && node.y < r.ybot) {
  			return true;
  		}
  	}
  	return false;
  }

  public void refresh_highlight() {
  	for (int i = 0; i < relations.length; i++) {
  		for (int k = 0; k < relations[i].events.length; k++) {
  			lookup(relations[i].node1).highlight = false;
  			lookup(relations[i].node2).highlight = false;
  		}
  	}

  }

  public void highlighting() {
  	for (int i = 0; i < relations.length; i++) {
  		for (int k = 0; k < relations[i].events.length; k++) {
  			if(check_heatmap(message, relations[i].events[k].time, relations[i].events[k].dest_port)) {
  				add_hl(relations[i]); 
  				print("yeahhhhh\n");
  			} else {
  				print("nah bro\n");
  			}

  			if(check_priority(message, relations[i].events[k].priority)) { add_hl(relations[i]); }
  			if(check_operation(message, relations[i].events[k].operation)) { add_hl(relations[i]); }
  			if(check_protocol(message, relations[i].events[k].protocol)) { add_hl(relations[i]); }
  		}
  	}
  }

  public void add_hl(ForceRels r) {
  	lookup(r.node1).highlight = true;
  	lookup(r.node2).highlight = true;
  }

  public boolean check_heatmap(Message message, float time, String dest_port) {
      for (int i = 0; i < message.time.length; i++) {
         if (time == message.time[i]) {
         	 if (dest_port.equals(message.dest_port[i])) {
         	 	return true;
         	 }
         }
      }
      return false;
  }


  public boolean check_priority(Message message, String priority) {
  	//if(message.priority.length == 0) { return true; }
      for (int i = 0; i < message.priority.length; i++) {
         if (priority.equals(message.priority[i])) {
             return true;
         }
      }
      return false;
  }
  
  public boolean check_operation(Message message, String operation) {
  	//if(message.operation.length == 0) { return true; }
      for (int i = 0; i < message.operation.length; i++) {
         if (operation.equals(message.operation[i])) {
             return true;
         }
      }
      return false;
  }
  
  public boolean check_protocol(Message message, String protocol) {
  	//if(message.protocol.length == 0) { return true; }
      for (int i = 0; i < message.protocol.length; i++) {
         if (protocol.equals(message.protocol[i])) {
             return true;
         }
      }
      return false;
  }

  public void draw_nodes() {
    int size = 0;
    for (int i = 0; i < nodes.length; i++) {
      stroke(0, 102, 153);
      if (nodes[i].intersect) {
        fill (200, 200, 255);
        ellipse(nodes[i].x, nodes[i].y, 2*nodes[i].radius, 2*nodes[i].radius);
        fill(255, 0, 0);
        textSize(15);
        textAlign(CENTER);
        String label = "IP: " + nodes[i].id;
        text(label, nodes[i].x, nodes[i].y - nodes[i].mass*2);
        textSize(10);

        //update message
        message.add_src_ip(nodes[i].id);
  		message.add_dest_ip(nodes[i].id);
      } else if (nodes[i].highlight) {
        fill (200, 200, 255);
        ellipse(nodes[i].x, nodes[i].y, 2*nodes[i].radius, 2*nodes[i].radius);
      } else {
        fill(nodes[i].KE, 80, 255 - nodes[i].KE);
        ellipse(nodes[i].x, nodes[i].y, 2*nodes[i].radius, 2*nodes[i].radius);
      }
    }
  }

  public void draw_edges() {
    stroke(0, 102, 153, 75);
    ForceNode n1, n2;
    for (int i = 0; i < relations.length; i++) {
      n1 = lookup(relations[i].node1);
      n2 = lookup(relations[i].node2);
      strokeWeight(relations[i].weight);
      line(n1.x, n1.y, n2.x, n2.y);
      strokeWeight(1);
    }
  }

  public ForceNode lookup(String id) {
    ForceNode toret = null;
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id.equals(id)) {
        toret = nodes[i];
      }
    }
    return toret;
  }

  public void initialize_forces() {
    for (int i = 0; i < nodes.length; i++) {
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
  public void accumulate_coulumb(ForceNode n) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id != n.id) {
        // restricts nodes from landing on top of each other
        if (n.x == nodes[i].x) { 
          n.x = n.x - 1;
        } 
        if (n.y == nodes[i].y) { 
          n.y = n.y + 1;
        }

        float theta_rad = find_angle(n, nodes[i]);
        float force_c = find_force(n, nodes[i]);

        int dx = check_dir(n.x, nodes[i].x);
        int dy = check_dir(n.y, nodes[i].y);

        n.fx += dx * (cos(theta_rad) * force_c);
        n.fy += dy * (sin(theta_rad) * force_c);
      }
    }
  }

  public float find_angle(ForceNode n1, ForceNode n2) 
  {
    float dist_y = abs(n2.y - n1.y);
    float dist_x = abs(n2.x - n1.x);

    float dist_total = sqrt((dist_y * dist_y) + (dist_x * dist_x));

    return atan(dist_y / dist_x);
  }

  public float find_force(ForceNode n1, ForceNode n2)
  {
    float dist_y = abs(n2.y - n1.y);
    float dist_x = abs(n2.x - n1.x);

    float dist_total = sqrt((dist_y * dist_y) + (dist_x * dist_x));

    return (k_c / (dist_total * dist_total));
  }


  // for all edges, finds hooke force effects for both affected nodes
  public void find_hooke() {   
    ForceNode n1, n2;       
    boolean n1Lock, n2Lock;

    for (int i = 0; i < relations.length; i++) {
      n1 = lookup(relations[i].node1);
      n2 = lookup(relations[i].node2);

      n1Lock = n1.drag;
      n2Lock = n2.drag;

      float ex = relations[i].curr_edge_x;
      float targex = relations[i].targ_edge_x;
      float ey = relations[i].curr_edge_y;
      float targey = relations[i].targ_edge_y;

      n1.fx += calc_hooke(n1.x, n2.x, ex, targex);
      n1.fy += calc_hooke(n1.y, n2.y, ey, targey);
      n2.fx += calc_hooke(n2.x, n1.x, ex, targex);
      n2.fy += calc_hooke(n2.y, n1.y, ey, targey);

      if (n1Lock) {
        n2.fx *= 2;
        n2.fy *= 2;
      }

      if (n2Lock) {
        n1.fx *= 2;
        n1.fy *= 2;
      }
    }
  }

  public float calc_hooke(float target, float pusher, float e, float targe) {
    int dir = check_dir(target, pusher);
    float force_h = dir * k_h * (targe - e);

    return force_h;
  }

  public int check_dir (float target, float pusher) {
    if (target < pusher) {
      return -1;
    } else {
      return 1;
    }
  }

  public void find_middle () {
    for (int i = 0; i < nodes.length; i++) {
      check_middle(nodes[i]);
    }
  }

  public void check_middle (ForceNode n) {
    if (n.x > canv_w/2) {
      n.fx -= k_mid * abs(n.x - canv_w/2);
    } else {
      n.fx += k_mid * abs(n.x - canv_w/2);
    }

    if (n.y > canv_h/2) {
      n.fy -= k_mid * abs(n.y - canv_h/2);
    } else {
      n.fy += k_mid * abs(n.y - canv_h/2);
    }
  }

  public void intersect(int mousex, int mousey) {
  	boolean isect = false;
    for (int i = 0; i < nodes.length; i++) {
      isect = nodes[i].intersect(mousex, mousey);
    }
  }

  /*void drag(int mousex, int mousey) {
   boolean intersected = false;
   for (int i = 0; i < nodes.length; i++) {
   if (nodes[i].drag(mousex, mousey) == true) {
   intersected = true;
   }
   }
   
   if (intersected) {
   start = true;
   }
   }
   
   void undrag() {
   for (int i = 0; i < nodes.length; i++) {
   nodes[i].drag = false;
   }
   }*/
}

class ForceNode {
  String id;
  float mass;
  ForceNode parent;
  float dist_to_parent;
  int num_children;
  float x, y;
  float fx, fy;
  float vx, vy;
  float ax, ay;
  float KE;
  boolean intersect;
  boolean highlight;
  boolean drag;
  float radius;

  ForceNode() {
    id = "0";
    mass = 0;
    dist_to_parent = 0;
    num_children = 0;
    x = random(10, width-10);
    y = random(10, height-10);
    fx = 0;
    fy = 0;
    vx = 0;
    vy = 0;
    ax = 0;
    ay = 0;
    KE = 0;
    intersect = false;
    drag = false;
    radius = 0;
    highlight = false;
    //events = new Event[0];
  }

  ForceNode(String i, float mas, int canvas_w, int canvas_h) {
    id = i;
    mass = mas;
    dist_to_parent = 0;
    num_children = 0;
    x = random(10, canvas_w-10);
    y = random(10, canvas_h-10);
    fx = 0;
    fy = 0;
    vx = 0;
    vy = 0;
    ax = 0;
    ay = 0;
    KE = 0;
    intersect = false;
    drag = false;
    radius = crunch();
  }

  public float crunch() {
    return (map(mass, 1, 10, 1, 10));
  }

  public void update_position(float damp_const, float x1, float x2, float y1, float y2) {
    //assuming t = 1 frame
    float t = 1;

    if (!drag) {
      //x
      ax = fx/mass;
      x = x + vx*t + .5f*ax*(t*t);
      vx = damp_const * (vx + ax*t);

      //y
      ay = fy/mass;
      y = y + vy*t + .5f*ay*(t*t);
      vy = damp_const * (vy + ay*t);

      KE = .5f * mass * ((vx*vx) + (vy*vy));
    }

    if (x < x1 + 10) { 
      x = x1 + 10;
    }
    if (y < y1 + 10) { 
      y = y1 + 10;
    }
    if (x > x2 - 10) { 
      x = x2 - 10;
    }
    if (y > y2 - 10) { 
      y = y2 - 10;
    }
  }

  public boolean intersect (int mousex, int mousey) {
    float distance;
    distance = sqrt(((mousex - x) * (mousex - x)) + ((mousey - y) * (mousey - y)));
    if (distance < radius) { 
      intersect = true;
    } else {
      intersect = false;
    }
    return intersect;
  }

  public boolean drag (int mousex, int mousey) {
    if (intersect) {
      drag = true;
      x = PApplet.parseFloat(mousex);
      y = PApplet.parseFloat(mousey);
      return true;
    }
    return false;
  }
}

class ForceParse {
  ForceNode[] nodes;
  ForceRels[] relations;
  Data data;
  int f_place;
  int ult_root;
  int fixed_mass;
  int canvas_w, canvas_h;
  int fixed_length;

  ForceParse(Data d, int canv_w, int canv_h) {   
    canvas_w = canv_w;
    canvas_h = canv_h;    
    nodes = new ForceNode[0];
    relations = new ForceRels[0];
    data = d;
    fixed_mass = 10;
    fixed_length = width/5;

    find_rels();
    find_nodes();
    change_lengths();
    //populate_events();
    //attach_nodes();

    //print_rels();
  }

  public void find_nodes() {
    ForceNode temp1, temp2;
    for (int i = 0; i < relations.length; i++) {
      int exists_index = node_exists(relations[i].node1);
      if (exists_index == -1) {
        temp1 = new ForceNode(relations[i].node1, fixed_mass, canvas_w, canvas_h);
        nodes = (ForceNode[])append(nodes, temp1);
      } else {
        temp1 = nodes[exists_index];
      }

      exists_index = node_exists(relations[i].node2);
      if (exists_index == -1) {
        temp2 = new ForceNode(relations[i].node2, fixed_mass, canvas_w, canvas_h);
        nodes = (ForceNode[])append(nodes, temp2);
      } else {
        temp2 = nodes[exists_index];
      }

      relations[i].update_curr(temp1.x, temp1.y, temp2.x, temp2.y);
    }
  }

  public void find_rels() { 
    for (int i = 0; i < data.events.length; i++) {
      int exists_index = rel_exists(data.events[i]);
      if (exists_index != -1) {
        relations[exists_index].weight += 1;
      } else {
        ForceRels temp = new ForceRels();
        temp.node1 = data.events[i].src_ip;
        temp.node2 = data.events[i].dest_ip;
        temp.weight = 1;
        temp.targ_edge = fixed_length;
        temp.events = (Event[])append(temp.events, data.events[i]);
        relations = (ForceRels[])append(relations, temp);
      }
    }
  }

  public int rel_exists(Event event) {
    for (int i = 0; i <  relations.length; i++) {
      if (relations[i].node1.equals(event.src_ip)) {
        if (relations[i].node2.equals(event.dest_ip)) {
          return i;
        }
      }
    }
    return -1;
  }

  public int node_exists(String node_ip) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id.equals(node_ip)) {
        return i;
      }
    }
    return -1;
  }

  public ForceNode lookup(String id) {
    ForceNode toret = null;
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id == id) {
        toret = nodes[i];
      }
    }
    return toret;
  }

  public void change_lengths() {
    //find min & max
    float max = 0;
    float min = relations[0].weight;
    for (int i = 0; i < relations.length; i++) {
      if (relations[i].weight > max) { 
        max = relations[i].weight;
      }
      if (relations[i].weight < min) { 
        min = relations[i].weight;
      }
    }

    for (int k = 0; k < relations.length; k ++) {
      relations[k].weight = map(relations[k].weight, min, max, 0, 10);
    }
  }

  public void print_rels() {
    for (int i = 0; i < relations.length; i++) {
      print("REL ", i, ": node1 = ", relations[i].node1, "node2 = ", relations[i].node2, "edge = ", relations[i].targ_edge, "\n");
    }
    for (int i = 0; i < nodes.length; i++) {
      print("NODE ", i, " = ", nodes[i].id, "\n");
    }
  }
}

class ForceRels {
  Event[] events;
  float weight;
  String node1;
  String node2;
  float targ_edge;
  float curr_edge;
  float targ_edge_x, targ_edge_y;
  float curr_edge_x, curr_edge_y;
  boolean compressed;

  ForceRels() {
    events = new Event[0]; 
  }

  public void update_curr(float n1x, float n1y, float n2x, float n2y) {
    curr_edge_x = abs(n1x - n2x);
    curr_edge_y = abs(n1y - n2y);
    curr_edge = sqrt((curr_edge_x*curr_edge_x) + (curr_edge_y*curr_edge_y));
    update_targ();
  }

  public void update_targ() {
    //curr_edge should be updated
    compressed = (curr_edge < targ_edge);

    if (curr_edge_x == 0) {
      targ_edge_x = 0;
      targ_edge_y = targ_edge;
    } else {
      float theta_rad = atan(curr_edge_y / curr_edge_x);
      targ_edge_x = targ_edge * cos(theta_rad);
      targ_edge_y = targ_edge * sin(theta_rad);
    }
  }
}

class Heatmap {
  float time_min, time_max;
  float time_interval;
  int num_intervals;
  Data data;
  int[][] hmap;
  String[] ports;
  float[] intervals;
  int canvas_w, canvas_h;
  int interval_w, interval_h;
  int min_val, max_val;
  int buffer_w, buffer_h;
  float[] mess_times;
  String[] mess_ports;
  

  Heatmap(Data parsed) {
    data = parsed;
    time_min = 100000;
    time_max = 0;
    time_interval = 0;
    num_intervals = 31;
    ports = new String[0];
    intervals = new float[num_intervals];
    find_fields();
    time_interval = (time_max - time_min)/(num_intervals-1);
    find_intervals();
    hmap = new int[ports.length][num_intervals];
    fill_hmap();
    find_val_bounds();
    mess_times = new float[0];
    mess_ports = new String[0];
  }

  public void find_fields() {
    for (int i = 0; i < data.events.length; i++) {
      if (data.events[i].time < time_min) {
        time_min = data.events[i].time;
      } 
      if (data.events[i].time > time_max) {
        time_max = data.events[i].time;
      }
      if (find_port(data.events[i].dest_port) == -1) {
        ports = append(ports, data.events[i].dest_port);
      }
    }
    
    ports = sort(ports);
  }
/*
  void find_num_ports() {
    for (int i = 0; i < data.events.length; i++) {
      if (find_port(data.events[i].dest_port) == -1) {
        ports = append(ports, data.events[i].dest_port);
      }
    }
  }
*/
  public void find_intervals() {
    float curr_time = time_min;
    
    for (int i = 0; i < num_intervals; i++) {
      intervals[i] = curr_time;
      curr_time += time_interval;
    }
  }

  public int find_port(String curr) {
    for (int i = 0; i < ports.length; i++) {
      if (curr.equals(ports[i])) {
        return i;
      }
    }
    return -1;
  }

  public void fill_hmap() {
    for (int i = 0; i < data.events.length; i++) {
      hmap[find_port(data.events[i].dest_port)][which_interval(data.events[i].time)] += 1;
    }
  }

  public void find_val_bounds() {
    for (int i = 0; i < ports.length; i++) {
      for (int j = 0; j < num_intervals; j++) {
        if (hmap[i][j] < min_val) {
          min_val = hmap[i][j];
        }
        if (hmap[i][j] > max_val) {
          max_val = hmap[i][j];
        }
      }
    }
  }

  public int which_interval(float curr) {
    float difference = curr - time_min;
    return floor(difference/time_interval);
  }

  public Message draw_heatmap(int x1, int x2, int y1, int y2, Message message, Rect[] rects) {
    /*message.add_src_ip("*.2.130-140");
    message.add_dest_ip("*.1.0-10");
    message.add_priority("Info");*/
    mess_times = new float[0];
    mess_ports = new String[0];
    check_message(message);
    if(intersect(x1, y1 - 15, x2, y2)) {
        message.dest_port = new String[0];
        message.time = new float[0];
    }
    
    buffer_w = 90;
    buffer_h = 50;
    canvas_w = (x2 - x1) - buffer_w;
    canvas_h = (y2 - y1) - buffer_h;

    interval_w = canvas_w/(num_intervals);
    interval_h = canvas_h/(ports.length);

    int curr_x = x1 + buffer_w;
    int curr_y = y1;
    float c;

    draw_axis_labels(x1, x2, y1, y2);

    fill(255);
    stroke(0);
    textAlign(CENTER, CENTER);
    for (int i = 0; i < ports.length; i++) {
      for (int j = 0; j < num_intervals; j++) {
        c = map(hmap[i][j], min_val, max_val, 0, 255);
            
        if (intersect(curr_x, curr_y, curr_x + interval_w, curr_y + interval_h) || 
          rect_intersect(rects, curr_x, curr_y, curr_x + interval_w, curr_y + interval_h)) {
          fill(50, 50, 50);
          message.add_time(intervals[j]);
          message.add_dest_port(ports[i]);
        } else if (in_mess_arrays(intervals[j], ports[i])) {
        //else if ((message.in_dest_port(ports[i]) == message.in_time(intervals[j])) && (message.in_time(intervals[j]) != -1)) {
          fill(50, 255, 50);
          
        } else {
          fill(c, 195 - c, 255 - c);
        }

        rect(curr_x, curr_y, interval_w, interval_h);
        fill(0);
        //text(hmap[i][j], curr_x + interval_w/2, curr_y + interval_h/2);
        curr_x += interval_w;
      }
      curr_y += interval_h;
      curr_x = x1 + buffer_w;
    }
    
    return message;
  }
  
  public void check_message(Message message) {
     boolean found = false;
     for (int i = 0; i < data.events.length; i++) {
        found = false;
        found = check_priority(message, data.events[i].priority);
        if (found == false) {found = check_operation(message, data.events[i].operation);}
        if (found == false) {found = check_protocol(message, data.events[i].protocol);}
        if (found == false) {found = check_dest_ip(message, data.events[i].dest_ip);}
        if (found == false) {found = check_src_ip(message, data.events[i].src_ip);}
        
        if (found == true) {
            mess_times = append(mess_times, data.events[i].time);
            mess_ports = append(mess_ports, data.events[i].dest_port);
        }
     }
  }

  
  public boolean check_src_ip(Message message, String src_ip) {
      for (int i = 0; i < message.src_ip.length; i++) {
         if (src_ip.equals(message.src_ip[i])) {
             return true;
         }
      }
      return false;
  }
  
  public boolean check_dest_ip(Message message, String dest_ip) {
      for (int i = 0; i < message.dest_ip.length; i++) {
         if (dest_ip.equals(message.dest_ip[i])) {
             return true;
         }
      }
      return false;
  }
  
  public boolean check_priority(Message message, String priority) {
      for (int i = 0; i < message.priority.length; i++) {
         if (priority.equals(message.priority[i])) {
             return true;
         }
      }
      return false;
  }
  
  public boolean check_operation(Message message, String operation) {
      for (int i = 0; i < message.operation.length; i++) {
         if (operation.equals(message.operation[i])) {
             return true;
         }
      }
      return false;
  }
  
  public boolean check_protocol(Message message, String protocol) {
      for (int i = 0; i < message.protocol.length; i++) {
         if (protocol.equals(message.protocol[i])) {
             return true;
         }
      }
      return false;
  }

  public boolean in_mess_arrays(float time, String dest_port) {
      for (int i = 0; i < mess_times.length; i++) {
          if (time == mess_times[i]) {
              if (dest_port.equals(mess_ports[i])) {
                  return true;
              }
          }
      }
      
      return false;
  }

  public boolean intersect(int x1, int y1, int x2, int y2) {
    if ((mouseX > x1 && mouseX < x2) && (mouseY > y1 && mouseY < y2)) {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean rect_intersect(Rect[] rects, int x1, int y1, int x2, int y2) {
    for (int i = 0; i < rects.length; i++) {
        if(is_in(rects[i], x1, y1) || is_in(rects[i], x1, y2) ||
            is_in(rects[i], x2, y1) || is_in(rects[i], x2, y2)) {
                return true;
        }
    }
      return false;
  }    
      
  public boolean is_in(Rect r, int x, int y) {
      if ((x > r.xleft && x < r.xright) && (y > r.ytop && y < r.ybot)) {
          return true;
      } else {
          return false;
      } 
  }

  public void draw_axis_labels(int x1, int x2, int y1, int y2) {
    int curr_x = x1 + buffer_w/3;
    int curr_y = y1;
    float curr_time = time_min;


    textAlign(CENTER, CENTER);
    for (int i = 0; i < ports.length; i++) {
      fill(0);
      text(ports[i], curr_x + interval_w/2, curr_y + interval_h/2);
      curr_y += interval_h;
    }

    curr_x = buffer_w;

    for (int i = 0; i < num_intervals; i++) {
      curr_time = intervals[i];
      fill(0);
      textSize(10);
      translate(curr_x + interval_w/2, curr_y + buffer_h/2);
      rotate(PI/2);
      text(convert_time(curr_time), 0, 0);
      rotate(-PI/2);
      translate(-(curr_x + interval_w/2), -(curr_y + buffer_h/2));
      curr_x += interval_w;
    }
  }

  public String convert_time(float total) {
    int hour, minutes, seconds;

    hour = floor(total/3600);
    minutes = floor(total%3600/60);
    seconds = floor(total%3600)%60;

    String s = str(hour) + ":" + str(minutes) + ":" + str(seconds);

    return s;
  }
  /*  
   void print_hmap() {
   for (int i = 0; i < ports.length; i++) {
   print(ports[i], ": - ");
   for (int j = 0; j < num_intervals; j++) {
   print(hmap[i][j], " ");
   }
   print("\n"); 
   }
   }
   */
}


class Message {
  boolean empty;
  float[] time;
  String[] src_ip;
  String[] src_port;
  String[] dest_ip;
  String[] dest_port;
  String[] priority;
  String[] operation;
  String[] protocol; 


  Message() {
    empty = true;
    time = new float[0];
    src_ip = new String[0];
    src_port = new String[0];
    dest_ip = new String[0];
    dest_port = new String[0];
    priority = new String[0];
    operation = new String[0];
    protocol = new String[0];
  }

  public boolean is_empty() { return empty; }

  public void add_time(float val) { 
  	time = append(time, val); 
  	empty = false;
  }
  public void add_src_ip(String val) { 
  	src_ip = append(src_ip, val); 
  	empty = false;
  }
  public void add_src_port (String val) { 
  	src_port = append(src_port, val); 
  	empty = false;
  }
  public void add_dest_ip (String val) { 
  	dest_ip = append(dest_ip, val); 
  	empty = false;
  }
  public void add_dest_port(String val) { 
  	dest_port = append(dest_port, val); 
  	empty = false;
  }
  public void add_priority (String val) { 
  	priority = append(priority, val); 
  	empty = false;
  }
  public void add_operation (String val) { 
  	operation = append(operation, val); 
  	empty = false;
  }
  public void add_protocol (String val) { 
  	protocol = append(protocol, val); 
  	empty = false;
  }

  public int in_dest_port(String port) {
    for (int i = 0; i < dest_port.length; i++) {
      if (port.equals(dest_port[i])) {
        return i;
      }
    }
    return -1;
  }

  public int in_time(float t) {
    for (int i = 0; i < time.length; i++) {
      if (t == time[i]) {
        return i;
      }
    }
    return -1;
  }
}
/*class NetworkView {
    ForceNode[] nodes;
    ForceRels[] relations;
    ForceGraph graph;
    
    NetworkView(Data data) {
        nodes = new ForceNode[0];
        relations = new ForceRels[0];
        
        for(int i = 0; i < data.events.length; i++) {
             // Checks destination IP
             if (node_exists(data.events[i].dest_ip) == -1 ) {
                 ForceNode node = new ForceNode(data.events[i].dest_ip);
                 nodes = append(nodes, 
             }  else {
                //stuff 
             }
             
             // Checks source IP
             if (node_exists(data.events[i].src_ip) == -1) {
                //stuff
             } else {
                //more stuff
             }  
        }
    }
    
    int node_exists(String IP) {
        //if it exists then return index. else return -1
    }
}*/
class Rect {
  int xleft, xright, ytop, ybot;
  
  Rect() {
    xleft = 0;
    xright = 0;
    ytop = 0;
    ybot = 0;
  }
  
  Rect(int x1, int x2, int y1, int y2) {
    set_dim(x1, x2, y1, y2);
  }
  
  public void draw_rect() {
      fill(color(171,217,233), 50);
      stroke(color(171,217,233));
      rect(xleft, ytop, xright-xleft, ybot-ytop);
  }
  
  public void set_dim(int x1, int x2, int y1, int y2) {
    if (x1 < x2) {
       xleft = x1;
       xright = x2;
    } else {
       xleft = x2;
       xright = x1;
    }
    
    if (y1 < y2) {
        ytop = y1;
        ybot = y2;
    } else {
        ytop = y2;
        ybot = y1;
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "a4" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
