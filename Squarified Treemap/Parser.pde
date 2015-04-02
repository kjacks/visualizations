class Parser {
  Leaf[] leaves;
  Rels[] relations;
  int f_place;
  int ult_root;
  
  Canvas parse(String file) {
       String[] lines = loadStrings(file);
       String[] split_line;
       
       leaves = find_leaves(lines);
       relations = find_rels(lines);
       
       //printall();
       find_root();
       Canvas root = set_links(ult_root);
       //print_tree(root);
       
       return root;
       //Canvas to_return = new Canvas();
  }
  
    
    Leaf[] find_leaves(String[] lines) {
      String[] split_line;
      Leaf[] leaves = new Leaf[int(lines[0])];

      for(f_place = 1; f_place <= int(lines[0]); f_place++) {
           leaves[f_place-1] = new Leaf();
           split_line = splitTokens(lines[f_place], " ");
           leaves[f_place-1].id = int(split_line[0]);
           leaves[f_place-1].value = int(split_line[1]);
       }
      
       return leaves;
    }
    
    Rels[] find_rels(String[] lines) {       
      String[] split_line;
      int j = 0;  
      Rels[] relations = new Rels[int(lines[f_place++])];


      for(; f_place < lines.length; f_place++) {
         relations[j] = new Rels();
         split_line = splitTokens(lines[f_place], " ");
         relations[j].parent = int(split_line[0]);
         relations[j].child  = int(split_line[1]);
         relations[j].is_linked = false;
         j++;
       }
       
       return relations;
    }
  
    void find_root() {
      ult_root = relations[0].parent;

      for ( int i = 0; i < relations.length; i++) {
         if (relations[i].child == ult_root) {
            ult_root = relations[i].parent;
            i = -1;
         } 
      }

    }
    
    Canvas set_links(int id) {
        Canvas to_return;
        
        //check to see if ID is leaf
        for(int i = 0; i < leaves.length; i++) {
          if(leaves[i].id == id) {
            to_return = new Canvas(id, leaves[i].value, true);
            return to_return;
          }
        }
        
        //didn't find leaf, therefore have to build tree
        to_return = new Canvas(id, 0, false);
        
        for(int i = 0; i < relations.length; i++) {
          if (relations[i].parent == id) {
            to_return.children = (Canvas[])append(to_return.children, set_links(relations[i].child));
            int child_place = to_return.children.length - 1;
            to_return.children[child_place].parent = to_return;
            to_return.total_value += to_return.children[child_place].total_value;
          }
        }
        
        to_return.sort_children();
        
        return to_return;
    }
   
  void print_tree(Canvas parent) {
     print("parent = ");
     print(parent.id, "\n");
     print("total value: ");
     print(parent.total_value, "\n");
     print("children: \n");
     for(int i = 0; i < parent.children.length; i++) {
        print(parent.children[i].id, "\n"); 
     }
     
     for(int i = 0; i < parent.children.length; i++) {
        print_tree(parent.children[i]); 
     }

  }
  
  void printall() {
       print("Leaves:\n");
       for (int j = 0; j < leaves.length; j++) {
           print(leaves[j].id);
           print("\n");
       }
       
       print("Values:\n");
       for(int j = 0; j < leaves.length; j++) {
           print(leaves[j].value);
           print("\n");
       }
       
       print("Parents:\n");
       for (int j = 0; j < relations.length; j++) {
           print(relations[j].parent);
           print("\n");
       }
       
       print("Kiddies:\n");
       for(int j = 0; j < relations.length; j++) {
           print(relations[j].child);
           print("\n");
       }
    }
        
}
