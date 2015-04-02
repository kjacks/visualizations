class Theme_River {
  Data data;
  String x_axis;
  String y_axis;
  float y_max;
  int num_points;
  int canvas_x1, canvas_x2;
  int canvas_y1, canvas_y2;
  int canvas_w, canvas_h;
  float[] x_coords;
  float[][] y_coords;
  float[] dum_y;
  float[] ttol_dest;
  float y_interval;
  int num_intervals;
  int isect;
  int shown_intervals;
  float radius;
  int phase;
  float lines_drawn;

  Theme_River(Data parsed) {
    //phase = 0;
    data = parsed;
    y_max = max(data.row_totals);
    num_points = data.name.length;
    y_interval = 10;
    num_intervals = 0;
    radius = 3;
    phase = 0;
  }
  
  void draw_graph() {
    make_canvas(); 
    draw_axes();
    draw_axes_titles();
    get_y_coords();
    //draw_points();
    draw_triver(data.num_cols - 2, x_coords, y_coords);
  }
    
  void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 120;
    canvas_x1 = 60;
    canvas_x2 = width - 60;
    
    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  void draw_axes() {
    fill(255, 255, 255);
    line(canvas_x1, canvas_y2, canvas_x2, canvas_y2);
    //line(canvas_x1, canvas_y1, canvas_x1, canvas_y2);
    
    //Draw y axis labels
    num_intervals = int((y_max / y_interval) + 1);
    
    x_coords = new float[0];
    float spacing = canvas_w/num_points;
    
    for (int i = 0; i < num_points; i += 1) {
        float pos_x = (i*spacing) + (spacing/2) + canvas_x1;
        float pos_y = canvas_y2 + 10;
        
        x_coords = append(x_coords, pos_x + 10); 
        //fill(200, 200, 200);
        //line(pos_x + 10, canvas_y2, pos_x + 10, canvas_y1);
        
        translate(pos_x + 10, pos_y);
        rotate(PI/2);
        
        fill(0,0,0);
        textAlign(LEFT, CENTER);
        textSize(10);
        text(data.name[i], 0, 0);        
        
        rotate(-PI/2);
        translate(-pos_x - 10, -pos_y);
    }
  }
  
  void draw_axes_titles() {
    textSize(15);
    textAlign(CENTER, CENTER);
    
    //x axis header
    text(data.header[0], width/2, height - 70);
    /*
    //y axis header
    translate(15, height/2);
    rotate(-PI/2);
    text(data.header[1], 0, 0); 
    rotate(PI/2);
    translate(-15, -height/2);
    
    textAlign(BASELINE);
    
    */
  }
  
  void get_y_coords() {
      y_coords = new float[data.name.length][data.num_cols];
      float max_height = num_intervals*y_interval;
      float total_hratio, total_height, bottom_gutter, curr_y, sub_hratio, sub_height;
      //print("max_height: ", max_height, "\n");
      
      for (int i = 0; i < data.name.length; i++) {
          total_hratio = data.row_totals[i]/max_height;
          total_height = total_hratio * canvas_h;
          bottom_gutter = (canvas_h - total_height)/2;
          curr_y = canvas_y2 - bottom_gutter;
          /*print("hratio: ", total_hratio, "\n");
          print("total_height: ", total_height, "\n");
          print("curr_y: ", curr_y, "\n");*/
          
          for (int j = 0; j < data.num_cols; j++) {
            sub_hratio = data.values[j][i]/data.row_totals[i];
            sub_height = sub_hratio * total_height;
            curr_y = curr_y - sub_height;
            y_coords[i][j] = curr_y;
            //print("sub height: ", sub_height, "\n");
          }
        
      }
    
  }
 /*
 void draw_points() {
     for (int i = 0; i < 1; i++) {
       for (int j = 0; j < data.num_cols; j++) {
           ellipse(x_coords[i], y_coords[i][j], radius, radius);
       }
     }
 }
 */
 /* 
  void draw_points(float r) {
        y_coords = new float[data.name.length][data.num_cols];
        float tot_h = 0;
        float h_ratio = 0;
        float curr_y = canvas_y2;
        
        for (int i = 0; i < data.name.length; i++) {
            print("i is: ", i, "\n");
            curr_y = canvas_y2;
            tot_h = canvas_y2 - max_y_coords[i];
          for (int j = 0; j < data.num_cols-1; j++) {
                 h_ratio = data.values[i][j]/data.row_totals[i];
                 curr_y -= tot_h*h_ratio;  
            
            //y_coords = append(y_coords, canvas_y2 - ((canvas_h/(num_intervals*y_interval))*data.value[i]));
            fill(0,0,0);
            ellipse(x_coords[i], curr_y, r, r);
            y_coords[i][j] = curr_y;
          }
        }
  }
  */
  
  void draw_triver(int lines_to_draw, float[]x, float[][]y) {
        //print("data length: ", data.name.length, "\n");
        for (int j = 0; j <= lines_to_draw; j++) {
          //float fill_clr = map(j, 0, data.num_cols, 50, 255);
          float fill_clr = map(j, 0, lines_to_draw, 0, 255);
          if (j == lines_to_draw) {
            fill_clr = 255;
          }
          //fill(fill_clr/2, 2*fill_clr/3, fill_clr);
          fill(150, fill_clr, 150);
          beginShape();
          curveVertex(canvas_x1 - 25, canvas_y1 + canvas_h/2);
          curveVertex(canvas_x1 - 15, canvas_y1 + canvas_h/2);
          for (int i = 0; i < data.name.length; i++) {
            curveVertex(x[i], y[i][j]);
          }
          
          curveVertex(canvas_x2 + 25, canvas_y1 + canvas_h/2);
          
          for (int i = data.name.length - 1; i >= 0; i--) {
              curveVertex(x[i], y[i][j+1]);
          }
          
          curveVertex(canvas_x1 - 15, canvas_y1 + canvas_h/2);
          curveVertex(canvas_x1 - 25, canvas_y1 + canvas_h/2);
          endShape();
          
        }
  }
  
  boolean line_to_triver(float[] line_y) {
    make_canvas(); 
    draw_axes();
    draw_axes_titles();
    get_y_coords();
    
    if (phase == 0) {
      phase += set_ltot_dummy(line_y);
    } else if (phase == 1) {
      phase += sink_line();
    } else if (phase == 2) {
      phase += incr_lines_drawn();
    } else {
      phase = 0;
      return false;
    }
   
    //draw_points();
    if (phase == 1) {
      draw_line();
    } else {
      draw_triver((int)lines_drawn, x_coords, y_coords);
    }
    
    return true;
  }
  
  int set_ltot_dummy(float[] line_y) {
    dum_y = new float[data.name.length];
    /*float max_val = 0;
    
    for (int i = 0; i < data.name.length; i++) {
      if (data.values[i][0] > max_val) {
        max_val = data.values[i][0];
      }
    }
    
    int num_interv = int((max_val/ y_interval) + 1);
    float max_height = num_interv*y_interval;
*/
    for (int i = 0; i < data.name.length; i++) {
      //float ratio = data.values[i][0]/max_height;
      //dum_y[i] = (float(canvas_h)-(float(canvas_h)*ratio))+canvas_y1;
      //ttol_dest[i] = dum_y[i];
      dum_y[i] = line_y[i];
    }
    
    lines_drawn = 0;
    return 1;
  }
  
 int sink_line() {
    for (int i = 0; i < data.name.length; i++) {
      dum_y[i] = lerp(dum_y[i], y_coords[i][0], .1);
    }
    
    boolean all_same = true;
    for (int i = 1; i < num_points; i++) {
      if ((int)dum_y[i] != (int)y_coords[i][0]) {
        all_same = false;
      }
    }

    if (all_same) {
      return 1;
    } else {
      return 0;
    }
  }
  
  int incr_lines_drawn() {
    lines_drawn = lerp(lines_drawn, data.num_cols + 5, .01);
    //print(lines_drawn, "\n");
    
    if (lines_drawn <= data.num_cols - 2) {
       return 0;
    } else {
       return 1;
    }
  }
  
   void draw_line() {
    for (int i = 0; i < (data.name.length - 1); i++) {
      fill(000);
      line(x_coords[i], dum_y[i], x_coords[i+1], dum_y[i+1]);
    }
  }
  
  boolean triver_to_line(float[] line_y) {
    make_canvas(); 
    draw_axes();
    draw_axes_titles();
    get_y_coords();
    
    if (phase == 0) {
      phase += set_ttol_dummy();
    } else if (phase == 1) {
      //print("phase 1\n");
      phase += decr_lines_drawn();
    } else if (phase == 2) {
      phase += raise_line(line_y);
    } else {
      phase = 0;
      draw_line();
      return true;
    }
    
   
    if (phase == 2 || phase == 3) {
      draw_line();
    } else {
      draw_triver((int)lines_drawn, x_coords, y_coords);
    }
    
    return false;
  }
  
  int set_ttol_dummy() {
    dum_y = new float[data.name.length];
    
    for (int i = 0; i < data.name.length; i++) {
      dum_y[i] = y_coords[i][0];
    }
    
    lines_drawn = data.num_cols - 2;
    return 1;
  }
  
  int decr_lines_drawn() {
    lines_drawn = lerp(lines_drawn, -3, .01);
    //print(lines_drawn, "\n");
    
    if (lines_drawn > 0) {
       return 0;
    } else {
       return 1;
    }
  }
  
  int raise_line(float[] line_y) {
    for (int i = 0; i < data.name.length; i++) {
      dum_y[i] = lerp(dum_y[i], line_y[i], .05);
    }
    
    boolean all_same = true;
    for (int i = 1; i < num_points; i++) {
      if ((int)dum_y[i] != (int)line_y[i]) {
        all_same = false;
      }
    }

    if (all_same) {
      return 1;
    } else {
      return 0;
    }
  }
}
