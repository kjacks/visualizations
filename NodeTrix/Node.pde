class Node {
   int id;
   int num_names;
   Node parent;
   float dist_to_parent;
   //int num_children;
   float x, y;
   float fx, fy;
   float vx, vy;
   float ax, ay;
   float KE;
   boolean intersect;
   boolean drag;
   float radius;
   String[] names;
   int[][] intern_links;
   Coord[] sides;
   Extern_link[] extern_links;
   int square_size;
   float canvas_x1;
   float canvas_y1;
   color[] colors;
   float wid;
   
   
   Node() {
       id = 0;
       num_names = 0;
       dist_to_parent = 0;
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
       extern_links = new Extern_link[0];
       square_size = 10;
       sides = new Coord[4];
       set_sides();
   }
   
   Node(int i, int mas) {
       id = i;
       num_names = mas;
       dist_to_parent = 0;
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
       radius = crunch();
       extern_links = new Extern_link[0];
       square_size = 10;
       wid = square_size * num_names;
       canvas_x1 = x - square_size*(float)num_names/2;
       canvas_y1 = y - square_size*(float)num_names/2;
       colors = new color[6];
       set_colors();
       sides = new Coord[4];
       set_sides();

   }
   
   void set_colors() {
       colors[0] = #ffffff;
       colors[1] = #c7e9b4;
       colors[2] = #7fcdbb;
       colors[3] = #41b6c4;
       colors[4] = #2c7fb8;
       colors[5] = #253494;
   }
   
   void set_sides() {
       sides[0] = new Coord();
       sides[0].x = x + wid/2;
       sides[0].y = y;
       
       sides[1] = new Coord();
       sides[1].x = x;
       sides[1].y = y + wid/2;
       
       sides[2] = new Coord();
       sides[2].x = x - wid/2;
       sides[2].y = y;
       
       sides[3] = new Coord();
       sides[3].x = x;
       sides[3].y = y - wid/2;
   }
   
   int which_index(String name) {
       for (int i = 0; i < num_names; i++) {
           print(names[i]);
           if (name.equals(names[i])) {
              return i; 
           }
       }
       
       return -1;
   }
   
   Coord get_name_coord(int index, int quadrant) {
       Coord loc = new Coord();
       if (quadrant == 0 || quadrant == 2) {
         loc.x = sides[quadrant].x;
         loc.y = canvas_y1 + square_size * index + square_size/2;
       } else {
         loc.x = canvas_x1 + square_size * index + square_size/2;
         loc.y = sides[quadrant].y;
       } 
       
       return loc;
   }
   
   
   void add_extern(int for_node, String loc_name, String for_name) {
       Extern_link temp = new Extern_link(for_node, loc_name, for_name);
       extern_links = (Extern_link[])append(extern_links, temp);
   }
   
   float crunch() {
       return (map(num_names, 1, 10, 5, 20));
   }
   
   void update_position(float damp_const) {
        //assuming t = 1 frame
        float t = 1;
                    
        if (!drag) {
            //x
            ax = fx/num_names;
            x = x + vx*t + .5*ax*(t*t);
            vx = damp_const * (vx + ax*t);
    
            //y
            ay = fy/num_names;
            y = y + vy*t + .5*ay*(t*t);
            vy = damp_const * (vy + ay*t);
      
            KE = .5 * num_names * ((vx*vx) + (vy*vy));
        }
            
        if (x < 10) { x = 10; }
        if (y < 10) { y = 10; }
        if (x > width-10) { x = width - 10; }
        if (y > height-10) { y = height - 10; }
        
        canvas_x1 = x - square_size*(float)num_names/2;
        canvas_y1 = y - square_size*(float)num_names/2;
        set_sides();
    }
    
    void draw_node() {
        draw_matrix();
        draw_names();
        
    }
    
    void draw_matrix() {
        float curr_x = canvas_x1;
        float curr_y = canvas_y1;
    
        fill(255);
        stroke(0);
        for (int i = 0; i < num_names; i++) {
           for (int j = 0; j < num_names; j++) {
              fill(colors[intern_links[i][j]]);
              rect(curr_x, curr_y, square_size, square_size);
              curr_x += square_size;
           }
           curr_x = canvas_x1;
           curr_y += square_size;
        }
    }
    
    void draw_names() {
        float curr_x = canvas_x1;
        float curr_y = canvas_y1;
        int pad = 5;
        
        fill(0);
        stroke(0);
        textSize(10);
        for (int i = 0; i < num_names; i++) {
           textAlign(RIGHT, TOP);
           text(names[i], curr_x-pad, curr_y);
           
           textAlign(LEFT, TOP);
           text(names[i], curr_x + num_names*square_size + pad, curr_y);
           curr_y += square_size;
        }
        
        curr_x = -(num_names*square_size)/2;
        curr_y = -(num_names*square_size)/2;
        translate(x, y);
        rotate(radians(-90));
        for (int i = 0; i < num_names; i++) {
           textAlign(RIGHT, TOP);
           text(names[i], curr_x-pad, curr_y);
           
           textAlign(LEFT, TOP);
           text(names[i], curr_x + num_names*square_size + pad, curr_y);
           curr_y += square_size;
        }
        
        
        rotate(radians(90));
        translate(-x,-y);
        
        
    }
   
    void intersect (int mousex, int mousey) {
    	float distance;
    	distance = sqrt(((mousex - x) * (mousex - x)) + ((mousey - y) * (mousey - y)));
    	if (distance < radius) { 
    		intersect = true; 
    	} else {
    		intersect = false;
    	}
    }

    boolean drag (int mousex, int mousey) {
    	if (intersect) {
    		drag = true;
    		x = float(mousex);
    		y = float(mousey);
                canvas_x1 = x - square_size*(float)num_names/2;
                canvas_y1 = y - square_size*(float)num_names/2;
                return true;
    	}
        return false;
    }
}
