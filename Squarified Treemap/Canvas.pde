class Canvas {
   boolean is_leaf = true;
   int id;
   float wid, hgt;
   Canvas[] children;
   Canvas parent;
   float total_value;
   float area;
   float aspect_ratio;
   float x, y;
   boolean intersection;
   
   Canvas(int id_num, int val, boolean leaf) {
       id = id_num;
       total_value = float(val);
       is_leaf = leaf;
       children = new Canvas[0];
   }
   
   void sort_children() {
       Canvas temp;
       for(int cur_pos = 1; cur_pos < children.length; cur_pos++) {
         for(int i = cur_pos; i >= 0; i--) {
          if(children[cur_pos].total_value > children[cur_pos - 1].total_value) {
           //swap
           temp = children[i];
           children[i] = children[i-1];
           children[i-1] = temp;
          }
          else {
            break; 
          }
         } 
       }
       
   }
   
   int intersect(int mousex, int mousey) {
       int intersected_node = -1;
       
       if (is_leaf == true) {
           float x1 = x + wid;
           float y1 = y + hgt;
           if (mousex < x1 && mousex > x) {
               if (mousey < y1 && mousey > y) {
                   intersection = true;
                   intersected_node = id;
               } else {
                   intersection = false;
               }
           } else {
               intersection = false;
           }
       } else {
           for(int i = 0; i < children.length; i++) {
                 int temp = children[i].intersect(mousex, mousey);
                 if (intersected_node == -1) {
                     intersected_node = temp;
                 }
           }
       }
       
       return intersected_node;
   }
}


