class Treemap {
  Canvas root;
  Canvas active_node;
  int active_level;
  Row[] rows;

  Treemap(Canvas node) {
    root = node;
    active_node = node;
    rows = new Row[0];
    active_level = 0;
  }
  
  void draw_treemap() {
      float canvas_area = width*height;
      float total_value = active_node.total_value;
      float VA_ratio = canvas_area/total_value;
      rows = new Row[0];
      
      //calculate proportional area of canvas
      calculate_areas(active_node, VA_ratio);
      
      //draw active_node
      new_row(active_node, 0, 0, width, height, 0);
      
      //recursively draw all children
      squarify(active_node, 0, 0, width, height, 0);
      draw_rows();
  }
  
  float calculate_areas(Canvas node, float ratio) {
      node.area = 0;
      if (node.is_leaf == true) {
          node.area = node.total_value * ratio;
          return node.area;
      } else {
          for (int i=0; i < node.children.length; i++) {
                node.area += calculate_areas(node.children[i], ratio);    
          }
          return node.area;
      }
  }
  
 void squarify(Canvas node, float x, float y, float wid, float hgt, int level) {
      if(node.is_leaf == true) {
          return;
      }
    
      new_row(node.children[0], x, y, wid, hgt, level);  
      for(int i = 1; i < node.children.length; i++) {
         add_new_node(node.children[i]);
      }
      
      for(int i = 0; i < node.children.length; i++) {
          float cushion = 3*(level+1);
          float w = node.children[i].wid;
          float h = node.children[i].hgt;
          if (w < 0) { w = 0; }
          if (h < 0) { h = 0; }
          squarify(node.children[i], node.children[i].x, node.children[i].y, w, h, level + 1);
      }
  }
  
  //x, y, wid, and hgt represent the blank area being drawn on
  void new_row(Canvas node, float x, float y, float wid, float hgt, int level) {
      Row temp = new Row(x, y);
      rows = (Row[])append(rows, temp);
      int curr = rows.length - 1;
      
      rows[curr].level = level;
      rows[curr].values = (Canvas[])append(rows[curr].values, node);
      
      if (wid > hgt) {
          rows[curr].horizontal = false;
          node.hgt = hgt;
          node.wid = node.area/hgt;
          node.aspect_ratio = node.wid/node.hgt;
          rows[curr].hgt = hgt;
          rows[curr].wid = node.wid;
      } else {
          rows[curr].horizontal = true;
          node.hgt = node.area/wid;
          node.wid = wid;
          node.aspect_ratio = node.wid/node.hgt;
          rows[curr].wid = wid;
          rows[curr].hgt = node.hgt;
      }
      
      node.x = x;
      node.y = y;
      
      rows[curr].worst_aspect = node.aspect_ratio;
      rows[curr].total_value = node.total_value;
      rows[curr].ctxt_w = wid;
      rows[curr].ctxt_h = hgt;
  }
  
  void add_new_node(Canvas node) {
      int curr = rows.length - 1;
      float aspect;
      float hgt, wid;
      
      if(rows[curr].horizontal == false) {
           hgt = (node.total_value/(rows[curr].total_value+node.total_value)) * rows[curr].hgt;
           wid = node.area/hgt;
           aspect = wid/hgt;
           
           if (dist_to_one(aspect) < dist_to_one(rows[curr].worst_aspect)) {
               node.wid = wid;
               node.hgt = hgt;
               node.aspect_ratio = aspect;
               insert_node(node);
           } else {
               float w = rows[curr].ctxt_w - rows[curr].wid;
               float h = rows[curr].hgt;
               float x = rows[curr].x + rows[curr].wid;
               float y = rows[curr].y;
               new_row(node, x, y, w, h, rows[curr].level);
           }
      } else {
           wid = node.total_value/(rows[curr].total_value+node.total_value) * rows[curr].wid;
           hgt = node.area/wid;
           aspect = wid/hgt;
           
           if (dist_to_one(aspect) < dist_to_one(rows[curr].worst_aspect)) {
               node.wid = wid;
               node.hgt = hgt;
               node.aspect_ratio = aspect;
               insert_node(node);
           } else {
               float w = rows[curr].wid;
               float h = rows[curr].ctxt_h - rows[curr].hgt;
               float x = rows[curr].x;
               float y = rows[curr].y + rows[curr].hgt;
               new_row(node, x, y, w, h, rows[curr].level);
           }
      }
  }
  
  void insert_node(Canvas node) {
      int curr = rows.length - 1;
      float worst_ratio = node.aspect_ratio;
      float curr_x = rows[curr].x;
      float curr_y = rows[curr].y;
      
      //shifting canvases in row
      for(int i = 0; i < rows[curr].values.length; i++) {
         //move location
         rows[curr].values[i].x = curr_x;
         rows[curr].values[i].y = curr_y;
         
         //adjusting canvas sizes
         if (rows[curr].horizontal == false) {
             rows[curr].values[i].wid = node.wid;
             rows[curr].values[i].hgt = rows[curr].values[i].area/node.wid;
             rows[curr].values[i].aspect_ratio = rows[curr].values[i].wid/rows[curr].values[i].hgt;
             curr_y += rows[curr].values[i].hgt;
         } else {
             rows[curr].values[i].hgt = node.hgt;
             rows[curr].values[i].wid = rows[curr].values[i].area/node.hgt;
             rows[curr].values[i].aspect_ratio = rows[curr].values[i].wid/rows[curr].values[i].hgt;
             curr_x += rows[curr].values[i].wid;
         }
         
         //looking for worst aspect ratio
         if (dist_to_one(rows[curr].values[i].aspect_ratio) > dist_to_one(worst_ratio)) {
             worst_ratio = rows[curr].values[i].aspect_ratio;
         }
      } 
      
      node.x = curr_x;
      node.y = curr_y;

      //updating row attributes      
      if (rows[curr].horizontal == false) {
          rows[curr].wid = node.wid;
      } else {
          rows[curr].hgt = node.hgt;
      }
      rows[curr].worst_aspect = worst_ratio;
      rows[curr].values = (Canvas[])append(rows[curr].values, node);
      rows[curr].total_value = rows[curr].total_value + node.total_value;
  } 
  
  float dist_to_one(float ratio) {
       float distance = 1 - ratio;
       if (distance >= 0) {
           return distance;
       } else {
           return -distance;
       }
  }
  
  void draw_rows() {
      for(int i = 0; i < rows.length; i++) {
          for(int k = 0; k < rows[i].values.length; k++) {
              //calculating cushion
              int cushion = 2*(rows[i].level+1);
              float x = rows[i].values[k].x + cushion;
              float y = rows[i].values[k].y + cushion;
              float w = rows[i].values[k].wid - (2*cushion);
              float h = rows[i].values[k].hgt - (2*cushion);
              if (w < 0) { w = 0; }
              if (h < 0) { h = 0; }
              
              //fill rectangle if mouse is over it
              if(rows[i].values[k].intersection == true && rows[i].values[k].is_leaf == true) {
                //highlight shade gets lighter the deeper you go
                float shade = (float(active_level + 1) / float(active_level + 2)) * 255;
                fill(int(shade), int(shade), 255);
              } else {
                  fill(250, 250, 250); 
              }
              
              //draw rectangle
              rect(x, y, w, h);
              fill(0,0,0);
              textSize(10);
              textAlign(CENTER, CENTER);
              text(rows[i].values[k].id, rows[i].values[k].x+(rows[i].values[k].wid/2), rows[i].values[k].y+(rows[i].values[k].hgt/2));
          }
      }
  }
  
  void zoom_in(int node_id) {
      if (active_node.is_leaf == false) {
          Canvas temp_node = find_canvas(node_id, active_node);
          while(temp_node.parent != active_node) {
            temp_node = temp_node.parent;
          }
          active_node = temp_node;
          active_level = active_level + 1;
      }
  }
  
  Canvas find_canvas(int node_id, Canvas curr_node) {
      Canvas found_canvas = null;
      
      if (curr_node.id == node_id) {
          found_canvas = curr_node;
      } else {
          for(int i = 0; i < curr_node.children.length; i++) {
                 Canvas temp = find_canvas(node_id, curr_node.children[i]);
                 if (temp != null) {
                     found_canvas = temp;
                 }
           }
      }
      
      return found_canvas;
  }
  
  void zoom_out(int node_id) {
      //just zooms all the way out
      if(active_node != root) {
          active_node = active_node.parent;
          active_level = active_level - 1;
      }
  }
  
  int intersect(int mousex, int mousey) {
     return active_node.intersect(mousex, mousey); 
  }
}
