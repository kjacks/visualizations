class Stacked_Bar {
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
  float[] max_y_coords;
  float interval;
  float x_spacing;
  int num_intervals;
  int shown_intervals;
  
  
  Stacked_Bar(Data parsed) {
    data = parsed;
    y_max = max(data.row_totals);
    num_points = data.name.length;
    interval = 10;
    num_intervals = 0;
  }
  
  void draw_graph() {
    make_canvas(); 
    draw_axes();
    draw_axes_titles();
    get_max_y_coords();
    draw_bars(x_spacing/2);
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
    line(canvas_x1, canvas_y1, canvas_x1, canvas_y2);
    
    //Draw y axis
    num_intervals = int((y_max / interval) + 1);
    print("num intervals is: ", num_intervals, "\n");
    shown_intervals = num_intervals/10;
    for (int i = 0; i <= num_intervals; i += 1) {
        float pos_y = canvas_y2 - (i * (canvas_h/num_intervals));        
        float pos_x = canvas_x1 - 25;
        
        if (shown_intervals == 0) {
          fill(0,0,0);
          textSize(10);
          text(int(i*interval), pos_x, pos_y);
          shown_intervals = num_intervals/10;
        } else {
           shown_intervals--;
        }
        /*fill(0,0,0);
        textSize(10);
        text(i*interval, pos_x, pos_y);*/
    }    
    
    
    //Draw x axis
    x_coords = new float[0];
    x_spacing = canvas_w/num_points;
    
    for (int i = 0; i < num_points; i += 1) {
        float pos_x = (i*x_spacing) + (x_spacing/2) + canvas_x1;
        float pos_y = canvas_y2 + 10;
        
        x_coords = append(x_coords, pos_x + 10); 
        
        translate(pos_x + 10, pos_y);
        rotate(PI/2);
        
        fill(0,0,0);
        textAlign(LEFT, CENTER);
        textSize(10);
        text(data.name[i], 0, 0);        
        //translate(0, canvas_w/num_points);
        
        rotate(-PI/2);
        translate(-pos_x - 10, -pos_y);
    }
  }
  
  void draw_axes_titles() {
    textSize(15);
    textAlign(CENTER, CENTER);
    
    //x axis header
    text(data.header[0], width/2, height - 70);
    
    //y axis header
    translate(15, height/2);
    rotate(-PI/2);
    text(data.header[1], 0, 0); 
    rotate(PI/2);
    translate(-15, -height/2);
    
    textAlign(BASELINE);
  }
  
  void get_max_y_coords() {
      max_y_coords = new float[0];
      float max_height = num_intervals*interval;
        
      for (int i = 0; i < data.name.length; i++) {
          float ratio = data.row_totals[i]/max_height;
          max_y_coords = append(max_y_coords, (float(canvas_h)-(float(canvas_h)*ratio))+canvas_y1);
      }
    
  }
  
  void draw_bars(float w) {
        float tot_h = 0;
        float h_ratio = 0;
        float curr_y = canvas_y2;
        y_coords = new float[num_points][data.num_cols];
        //print("in draw bars, dum width: ", w, "\ngoal: ", x_spacing/2, "\n");
        for (int i = 0; i < data.name.length; i++) {
             curr_y = canvas_y2;
             tot_h = canvas_y2 - max_y_coords[i];
          for (int j = 0; j < data.num_cols-1; j++) {
              float fill_clr = map(j, 0, data.num_cols, 0, 255);
              h_ratio = data.values[j][i]/data.row_totals[i];
              curr_y -= tot_h*h_ratio;
                 
              fill(150, fill_clr, 150);
              // rect(x_coords[i]-(x_spacing/4), y_coords[i], x_spacing/2, canvas_y2 - y_coords[i]);
              rect(x_coords[i]-(w/4), curr_y, w, tot_h*h_ratio); 
              y_coords[i][j] = curr_y;
          } 
        }
    
    }
 /*   
  boolean bar_to_stack(float[] bar_y) {
    make_canvas(); 
    draw_axes();
    draw_axes_titles();
    
    if (phase == 0) {
      phase += set_btos_dummy(bar_y);
    } else if (phase == 1) {
      print("phase 1\n");
      //phase += decr_lines_drawn();
    } else if (phase == 2) {
      //phase += raise_line(line_y);
    } else {
      phase = 0;
      return false;
    }
    
    draw_bars(x_spacing/2);
   
    return true;
  }
  
  int set_btos_dummy(float[] bar_y) {
   for (int i = 0; i < data.name.length; i++) {
      dum_y[i] = bar_y[i];
    }
    
    lines_drawn = 0;
    return 1;
 }
  */
}
