class Parser {
  Node[] nodes;
  Rels[] relations;
  Graph graph;
  int curr_line;
  int ult_root;
  int num_nodes;
  
 Graph parse(String file) {
       String[] lines = loadStrings(file);
       String[] split_line;
       
       curr_line = 0;
       graph = new Graph();
       
       split_line = splitTokens(lines[curr_line++], ",");
       num_nodes = int(split_line[0]);
       print("num nodes ", num_nodes, "\n");
       nodes = new Node[num_nodes];
       relations = new Rels[0];
       
       for (int i = 0; i < num_nodes; i++) {
           split_line = splitTokens(lines[curr_line++], ",");
           nodes[i] = new Node(int(split_line[0]), int(split_line[1]));
           int num_links = int(split_line[2]);
           read_names(lines, i);
           read_intern_links(lines, i, num_links);
       }
       
       read_extern_links(lines);
        for (int i = 0; i < nodes[2].extern_links.length; i++) {
             nodes[2].extern_links[i].print_link();
        }
            
       //attach_nodes();
       
       //print_rels();
       
       graph.nodes = nodes;
       graph.relations = relations;
       
       return graph;
  }
  
  void read_names (String[] lines, int index) {
      nodes[index].names = new String[nodes[index].num_names];
      String[] split_line;
      for (int i = 0; i < nodes[index].num_names; i++) {
          split_line = splitTokens(lines[curr_line++], ",");
          nodes[index].names[i] = split_line[0];
      }
  }
  
  void read_intern_links (String[] lines, int index, int num_links) {
      String[] split_line;
      nodes[index].intern_links = new int[nodes[index].num_names][nodes[index].num_names];
      

      for (int i = 0; i < num_links; i++) {
          split_line = splitTokens(lines[curr_line++], ",");
          printArray(split_line);
          
          int name1 = nodes[index].which_index(split_line[0]);
          int name2 = nodes[index].which_index(split_line[1]);
          
          
          nodes[index].intern_links[name1][name2] = int(split_line[2]);
          nodes[index].intern_links[name2][name1] = int(split_line[2]);
      }
  }
  
  void read_extern_links(String[] lines) {
      String[] split_line;
      for (; curr_line < lines.length; curr_line++) {
         print("curr_line", curr_line, "\n");
         split_line = splitTokens(lines[curr_line], ",");
         int node1 = int(split_line[1]);
         int node2 = int(split_line[3]);
         String name1 = split_line[0];
         String name2 = split_line[2];
         
         //nodes[node1].add_extern(node2, name1, name2);
         //nodes[node2].add_extern(node1, name2, name1);
         Rels temp = new Rels(node1, node2, name1, name2, 250);
         relations = (Rels[])append(relations, temp);
      }
    
  }
  
 /*   
    void find_nodes(String[] lines) {
      String[] split_line;
      split_line = splitTokens(lines[0], ",");
      int num_nodes = int(split_line[0]);
      nodes = new Node[num_nodes];

      for(f_place = 1; f_place <= num_nodes; f_place++) {
           split_line = splitTokens(lines[f_place], ",");
           nodes[f_place-1] = new Node(int(split_line[0]), float(split_line[1]));
       }

    }
    
    void find_rels(String[] lines) { 
      String[] split_line;
      split_line = splitTokens(lines[f_place++], ",");
      int num_rels = int(split_line[0]);     
      int j = 0;  
      relations = new Rels[num_rels];

      for(; f_place < lines.length; f_place++) {
         relations[j] = new Rels();
         split_line = splitTokens(lines[f_place], ",");
         relations[j].node1 = int(split_line[0]);
         relations[j].node2  = int(split_line[1]);
         relations[j].targ_edge = float(split_line[2]);
         relations[j].update_curr(lookup(relations[j].node1).x, lookup(relations[j].node1).y, lookup(relations[j].node2).x, lookup(relations[j].node2).y);
         j++;
       }
    }
    
    Node lookup(int id) {
       Node toret = null;
       for (int i = 0; i < nodes.length; i++) {
           if (nodes[i].id == id) {
              toret = nodes[i]; 
           }
       }
       return toret;
    }
    
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
