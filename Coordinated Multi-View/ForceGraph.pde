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

    k_h = .2;
    k_c = 10000*nodes.length;
    k_damp = .4;
    k_mid = .5;
    thresh = 0;
    start = true;
  }

  Message draw_graph(int x1, int x2, int y1, int y2, Message msg, Rect[] r) {
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
  void calc_forces() {
    initialize_forces();
    find_coulumb();
    find_hooke();
    find_middle();
  }

  float calc_KE() {
    float total = 0;
    for (int i = 0; i < nodes.length; i++) {
      total += nodes[i].KE;
    }
    return total;
  }

  void update_with_forces() {
    for (int i = 0; i < nodes.length; i++) {
      nodes[i].update_position(k_damp, x_1, x_2, y_1, y_2);
    }

    for (int k = 0; k < relations.length; k++) {
      ForceNode n1 = lookup(relations[k].node1);
      ForceNode n2 = lookup(relations[k].node2);

      relations[k].update_curr(n1.x, n1.y, n2.x, n2.y);
    }
  }

  void refresh_message() {
    message.src_ip = new String[0];
    message.dest_ip = new String[0];
  }

  void update_message() {
    //int xleft, xright, ytop, ybot;
    for (int i = 0; i < rects.length; i++) {
      for (int k = 0; k < relations.length; k++) {
        //updating message based on rectangles
        if (in_rect(lookup(relations[k].node1), rect[i])) {
          lookup(relations[k].node1).highlight = true;
          message.add_src_ip(relations[k].node1);
          message.add_dest_ip(relations[k].node1);
        }
        if (in_rect(lookup(relations[k].node2), rect[i])) {
          lookup(relations[k].node2).highlight = true;
          message.add_src_ip(relations[k].node2);
          message.add_dest_ip(relations[k].node2);
        }
      }
    }
  }

  boolean in_rect(ForceNode node, Rect r) {
    if (node.x > r.xleft && node.x < r.xright) {
      if (node.y > r.ytop && node.y < r.ybot) {
        return true;
      }
    }
    return false;
  }

  void refresh_highlight() {
    for (int i = 0; i < relations.length; i++) {
      for (int k = 0; k < relations[i].events.length; k++) {
        lookup(relations[i].node1).highlight = false;
        lookup(relations[i].node2).highlight = false;
      }
    }
  }

  void highlighting() {
    for (int i = 0; i < relations.length; i++) {
      for (int k = 0; k < relations[i].events.length; k++) {
        if (check_heatmap(message, relations[i].events[k].time, relations[i].events[k].dest_port)) {
          add_hl(relations[i]); 
        }

        if (check_priority(message, relations[i].events[k].priority)) { 
          add_hl(relations[i]);
        }
        if (check_operation(message, relations[i].events[k].operation)) { 
          add_hl(relations[i]);
        }
        if (check_protocol(message, relations[i].events[k].protocol)) { 
          add_hl(relations[i]);
        }
      }
    }
  }

  void add_hl(ForceRels r) {
    lookup(r.node1).highlight = true;
    lookup(r.node2).highlight = true;
  }

  boolean check_heatmap(Message message, float time, String dest_port) {
    for (int i = 0; i < message.time.length; i++) {
      if (time == message.time[i]) {
        if (dest_port.equals(message.dest_port[i])) {
          return true;
        }
      }
    }
    return false;
  }


  boolean check_priority(Message message, String priority) {
    //if(message.priority.length == 0) { return true; }
    for (int i = 0; i < message.priority.length; i++) {
      if (priority.equals(message.priority[i])) {
        return true;
      }
    }
    return false;
  }

  boolean check_operation(Message message, String operation) {
    //if(message.operation.length == 0) { return true; }
    for (int i = 0; i < message.operation.length; i++) {
      if (operation.equals(message.operation[i])) {
        return true;
      }
    }
    return false;
  }

  boolean check_protocol(Message message, String protocol) {
    //if(message.protocol.length == 0) { return true; }
    for (int i = 0; i < message.protocol.length; i++) {
      if (protocol.equals(message.protocol[i])) {
        return true;
      }
    }
    return false;
  }

  void draw_nodes() {
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

  void draw_edges() {
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

  ForceNode lookup(String id) {
    ForceNode toret = null;
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id.equals(id)) {
        toret = nodes[i];
      }
    }
    return toret;
  }

  void initialize_forces() {
    for (int i = 0; i < nodes.length; i++) {
      nodes[i].fx = 0;
      nodes[i].fy = 0;
    }
  }

  //for all nodes, finds coulumb forces from other nodes
  void find_coulumb() {
    for (int i = 0; i < nodes.length; i++) {
      accumulate_coulumb(nodes[i]);
    }
  }

  //for a single node, find coulumb forces from other nodes
  void accumulate_coulumb(ForceNode n) {
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

  float find_angle(ForceNode n1, ForceNode n2) 
  {
    float dist_y = abs(n2.y - n1.y);
    float dist_x = abs(n2.x - n1.x);

    float dist_total = sqrt((dist_y * dist_y) + (dist_x * dist_x));

    return atan(dist_y / dist_x);
  }

  float find_force(ForceNode n1, ForceNode n2)
  {
    float dist_y = abs(n2.y - n1.y);
    float dist_x = abs(n2.x - n1.x);

    float dist_total = sqrt((dist_y * dist_y) + (dist_x * dist_x));

    return (k_c / (dist_total * dist_total));
  }


  // for all edges, finds hooke force effects for both affected nodes
  void find_hooke() {   
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

  float calc_hooke(float target, float pusher, float e, float targe) {
    int dir = check_dir(target, pusher);
    float force_h = dir * k_h * (targe - e);

    return force_h;
  }

  int check_dir (float target, float pusher) {
    if (target < pusher) {
      return -1;
    } else {
      return 1;
    }
  }

  void find_middle () {
    for (int i = 0; i < nodes.length; i++) {
      check_middle(nodes[i]);
    }
  }

  void check_middle (ForceNode n) {
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

  void intersect(int mousex, int mousey) {
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

