class Rose_Chart{
  boolean visible;  
  Data data;
  float max_val;
  int num_wedges;
  int num_layers;
  float angle;
  int canvas_x1, canvas_x2;
  int canvas_y1, canvas_y2;
  int canvas_w, canvas_h;
  float[][] radii;
  int diameter;
  //radii[layer][wedge #]
  
  // for transitions
  int phase;
  int first_layer;
  int last_layer;
  float[][] dum_radii;
  
  Rose_Chart(Data parsed) {
    phase = 0;
    data = parsed;
    max_val = max(data.values[0]);
    num_wedges = data.name.length;
    num_layers = data.num_cols;
    angle = (2 * PI) / num_wedges;
  }
  
  void draw_graph() {
    make_canvas(); 
    calc_radii();
    draw_chart(0, num_layers - 1, radii);
  }

  void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 90;
    canvas_x1 = 60;
    canvas_x2 = width - 60;

    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  
  void calc_radii() {
      radii = new float[data.num_cols][num_wedges];
      float tot_so_far;
      
      for(int i = 0; i < num_wedges; i++) {
          tot_so_far = data.values[0][i];
          radii[0][i] = tot_so_far;
          for(int j = 1; j < num_layers; j++) {
              tot_so_far += data.values[j][i];
              radii[j][i] = tot_so_far;
              if (tot_so_far > max_val) {
                  max_val = tot_so_far;
              }
          }
      }  

      if (width > height) {
        diameter = height / 2;
      } else {
        diameter = width / 2;
      }
  }
  
  /*
  void print_data() {
    for(int i = 0; i < num_wedges; i++) {
      for(int j = 0; j < num_layers; j++) {
        print(j, " ", i, " ", radii[j][i], "\n");
      }
    }
  }
  */

  void draw_chart(int f_lay, int b_lay, float[][] rad) {
      for(int i = b_lay; i >= f_lay; i--) {
          float c = map(i, num_layers - 1, 0, 0, 105);
          draw_layer(rad[i], c);
      }
  }
  
  void draw_layer(float[] rad, float c) {
      float curr_angle = 0;
      float rad_to_draw;
      for(int i = 0; i < num_wedges; i++) {
          float gray = map(i, 0, num_wedges, 0, 255);
          fill(150 + c, gray, 150 + c);
          rad_to_draw = map(rad[i], 0, max_val, 0, diameter);
          arc(width/2, height/2, rad_to_draw, rad_to_draw, curr_angle, curr_angle + angle, PIE);
          curr_angle += angle;
      }
  }

  boolean pie_to_rose() {
      if(phase == 0) {          //initialize
          phase += set_ptor_dum();
      } else if (phase == 1) {  //expand outer wedges - NEEDS INTERNAL PHASE
          phase += expand_phases();
      } else {
          make_canvas(); 
          calc_radii();
          draw_chart(first_layer, last_layer, dum_radii);
          phase = 0;
          return false;          
      }
      
      make_canvas(); 
      calc_radii();
      draw_chart(first_layer, last_layer, dum_radii);
      
      return true;
  }
  
  int set_ptor_dum() {
     first_layer = num_layers - 1; 
     last_layer = num_layers - 1;
     dum_radii = new float[num_layers][num_wedges];
     
     for(int i = 0; i < num_layers; i++) {
       for(int j = 0; j < num_wedges; j++) {
         if (i == num_layers - 1) {  
             dum_radii[i][j] = 120;
         } else {
             dum_radii[i][j] = 0;
         }
       }
     }
     return 1;
  }
  
  int expand_phases() {
     int curr_lay = first_layer;
     int count = 0;
     
     for(int i = 0; i < num_wedges; i++) {
         dum_radii[curr_lay][i] = lerp(dum_radii[curr_lay][i], radii[curr_lay][i], .1);
         
         if(! (dum_radii[curr_lay][i] > radii[curr_lay][i] - .1)) {
           count++;
         }
     }
     
     if(count == 0) {
         if(curr_lay == 0) {
             return 1;
         } else {
             first_layer--;
             return 0;
         }
     } else {
         return 0;
     }
  }
  
}
