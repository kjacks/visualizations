class Rels {
  int node1;
  int node2;
  String n1_name, n2_name;
  float targ_edge;
  float curr_edge;
  float targ_edge_x, targ_edge_y;
  float curr_edge_x, curr_edge_y;
  boolean compressed;
  
  Rels(int n1, int n2, String name1, String name2, int targ) {
     node1 = n1;
     node2 = n2;
     n1_name = name1;
     n2_name = name2;
     targ_edge = targ;
    
  }
  
  void update_curr(float n1x, float n1y, float n2x, float n2y) {
      curr_edge_x = abs(n1x - n2x);
      curr_edge_y = abs(n1y - n2y);
      curr_edge = sqrt((curr_edge_x*curr_edge_x) + (curr_edge_y*curr_edge_y));
      update_targ();
  }
  
  void update_targ() {
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
