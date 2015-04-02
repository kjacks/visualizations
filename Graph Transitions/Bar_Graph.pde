class Bar_Graph {
  boolean visible;  
  Data data;
  String x_axis;
  String y_axis;
  float y_max;
  int num_points;
  int canvas_x1, canvas_x2;
  int canvas_y1, canvas_y2;
  int canvas_w, canvas_h;
  float[] x_coords;
  float[] y_coords;
  float interval;
  float x_spacing;
  int num_intervals;
  int isect;
  int shown_intervals;
  float[] heights;
  color axes_color;
  
  //variables for transition
  int phase;
  float[] dum_y;
  float dum_width; //width correlates to xspacing/2, 
  float[] dum_heights;
  color dum_color;
  float dum_x_x, dum_x_y, dum_y_x, dum_y_y;

  Bar_Graph(Data parsed) {
    data = parsed;
    y_max = max(data.values[0]);
    num_points = data.name.length;
    interval = 5;
    num_intervals = 0;
    isect = -1;
    phase = 0;
    heights = new float[0];
    axes_color = color(0, 0, 0);
  }
  
  void draw_graph() {
    make_canvas(); 
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    get_y_coords();
    draw_bars(x_spacing/2, heights);
  }
    
  void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 120;
    canvas_x1 = 60;
    canvas_x2 = width - 60;
    
    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  void draw_axes(float x_x, float x_y, float y_x, float y_y){
    fill(255, 255, 255);
    line(canvas_x1, canvas_y1, y_x, y_y);  //y axis
    line(canvas_x1, canvas_y2, x_x, x_y);  //x axis
  }
  
  void draw_axes_labels(color c) {    
    //Draw y axis
    num_intervals = int((y_max / interval) + 1);
    shown_intervals = num_intervals/10;
    for (int i = 0; i <= num_intervals; i += 1) {
        float pos_y = canvas_y2 - (i * (canvas_h/num_intervals));        
        float pos_x = canvas_x1 - 15;
        
        if (shown_intervals == 0) {
          fill(c);
          textSize(10);
          text(int(i*interval), pos_x, pos_y);
          shown_intervals = num_intervals/10;
        } else {
           shown_intervals--;
        }
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
        
        fill(c);
        textAlign(LEFT, RIGHT);
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
  
  void get_y_coords() {
      y_coords = new float[0];
      heights = new float[0];
      float max_height = num_intervals*interval;
        
      for (int i = 0; i < data.name.length; i++) {
          float ratio = data.values[0][i]/max_height;
          y_coords = append(y_coords, (float(canvas_h)-(float(canvas_h)*ratio))+canvas_y1);
          heights = append(heights, canvas_y2 - ((float(canvas_h)-(float(canvas_h)*ratio))+canvas_y1));
      }
    
  }
  
  void draw_bars(float w, float[] hs) {
        for (int i = 0; i < data.name.length; i++) {
              float gray = map(i, 0, data.values[0].length, 0, 255);
              fill(150, gray, 150);
              rect(x_coords[i]-(w/4), y_coords[i], w, hs[i]);   
        }
  }
  
  boolean line_to_bar() {  
    make_canvas(); 
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    get_y_coords();
    
    if (phase == 0) {
        phase += set_ltob_dummy();
    } else if (phase == 1) {
        phase += expand_point();
    } else if (phase == 2) {
        phase += fill_bar();
    } else {
        phase = 0;
        draw_bars(dum_width, heights);
        return false;
    }
    
    draw_bars(dum_width, dum_heights);
    
    return true;
  }
  
  int set_ltob_dummy() {
    dum_y = new float[num_points];
    dum_heights = new float[num_points];
    
    for (int i = 0; i < num_points; i++) {
      dum_y[i] = 0;
      dum_heights[i] = 0;
    }
   
    dum_width = 0;
    return 1;
  }
  
  int expand_point() {
    dum_width = lerp(dum_width, (x_spacing/2), .05);
    for (int i = 0; i<num_points; i++) {
       dum_heights[i] = 1; 
    }
    
    if(dum_width > x_spacing/2 - .1) {
        return 1;
    } else {
        return 0;
    }
  }
  
  int fill_bar() {
    //println(dum_y);
    for(int i = 0; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], canvas_y2 - y_coords[i], .1);
      dum_heights[i] = dum_y[i];
    }
    
    boolean all_same = true;
    for(int i = 0; i < num_points; i++) {
      if(int(dum_y[i]) != int(canvas_y2 - y_coords[i])) {
           all_same = false;
      }
    }
    
    if(all_same) {
      return 1;
    } else {
      return 0;
    }
  }
  
  boolean bar_to_line() {  
    //print("phase is ", phase, "\n");
    make_canvas(); 
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    get_y_coords();
    
    if (phase == 0) {
        phase += set_btol_dummy();
    } else if (phase == 1) {
        //print("shrinking bars\n");
        phase += shrink_bar();
    } else if (phase == 2) {
        //print("shrinking points\n");
        phase += shrink_point();
    } else {
        phase = 0;
        return true;
    }
    
    if (phase != 0) {
      draw_bars(dum_width, dum_heights);
    }
    
    return false;
  }
  
  boolean bar_to_pie() {  
    //print("phase is ", phase, "\n");
    make_canvas(); 
    get_y_coords();
    
    if (phase == 0) {
        phase += set_btol_dummy();
    } else if (phase < 4) {
        //print("shrinking bars\n");
        phase += shrink_bar();
        phase += shrink_axes();
        phase += fade_out_labels();
    } else {
        make_canvas(); 
        //draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
        //draw_axes_labels(axes_color);
        //draw_axes_titles();
        get_y_coords();
        phase = 0;
        return true;
    }
    
    draw_axes(dum_x_x, canvas_y2, canvas_x1, dum_y_y);
    draw_axes_labels(dum_color);
    draw_axes_titles();
    if (phase != 0) {
      draw_bars(dum_width, dum_heights);
    }
    
    return false;
  }
  
 int set_btol_dummy() {
    dum_y = new float[num_points];
    dum_heights = new float[num_points];
    dum_y_x = canvas_x1;
    dum_y_y = canvas_y2;
    dum_x_x = canvas_x2;
    dum_x_y = canvas_y2;
    dum_color = color(0,0,0);
    
    for (int i = 0; i < num_points; i++) {
      dum_y[i] = canvas_y2 - y_coords[i];
      dum_heights[i] = canvas_y2 - y_coords[i];
    }
   
    dum_width = x_spacing/2;
    return 1;
 }
  
 int shrink_bar() {
    for(int i = 0; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], 1, .1);
      dum_heights[i] = lerp(dum_heights[i], 1, .1);
    }
    
    boolean all_same = true;
    for(int i = 0; i < num_points; i++) {
      if(dum_y[i] > 1.1) {
           all_same = false;
      }
    }
    
    if(all_same) {
      return 1;
    } else {
      return 0;
    }
 }
 
 int shrink_point() {
   dum_width = lerp(dum_width, 0, .05);
    if(dum_width < .1) {
        return 1;
    } else {
        return 0;
    }
 }
 
 boolean pie_to_bar() {
    make_canvas(); 
    get_y_coords();
        
    if (phase == 0) {
        phase += set_ptob_dummy();
    } else if (phase == 1) {
        phase += fill_bar();
    } else if (phase < 4) {
        //print("filling bar\n");
        phase += expand_axes();
        phase += fade_in_labels();
    } else {
        phase = 0;
        make_canvas(); 
        get_y_coords();
        draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
        draw_axes_labels(axes_color);
        draw_axes_titles();
        draw_bars(x_spacing/2, heights);
        return false;
    }
    draw_axes(dum_x_x, dum_x_y, dum_y_x, dum_y_y);
    draw_axes_labels(dum_color);
    draw_bars(dum_width, dum_heights);
    return true;
 }
 
 int set_ptob_dummy() {
     dum_y = new float[num_points];
     dum_heights = new float[num_points];
     dum_y_x = canvas_x1;
     dum_y_y = canvas_y1;
     dum_x_x = canvas_x1;
     dum_x_y = canvas_y2;
     dum_color = color(255, 255, 255);
     dum_width = get_w();
    
    for (int i = 0; i < num_points; i++) {
      dum_y[i] = 0;
      dum_heights[i] = 0;
    }

    return 1;
 }
 
 int expand_axes() {
      dum_x_x = lerp(dum_x_x, canvas_x2, .05);
      dum_y_y = lerp(dum_y_y, canvas_y2, .05);
      
      if (int(dum_x_x) + 1 >= int(canvas_x2)) {
          return 1;
      } else {
          return 0;
      }
  }
  
  int shrink_axes() {
      dum_x_x = lerp(dum_x_x, 0, .05);
      dum_y_y = lerp(dum_y_y, 0, .05);
      
      if (int(dum_x_x) - int(canvas_x1) < 1) {
          return 1;
      } else {
          return 0;
      }
  }
  
  int fade_in_labels() {
     float tempR = red(dum_color);
     float tempG = green(dum_color);
     float tempB = blue(dum_color);
     
     if(tempR > 0) {tempR = tempR - 5;}
     if(tempG > 0) {tempG = tempG - 5;}
     if(tempB > 0) {tempB = tempB - 5;}
     
     dum_color = color(tempR, tempG, tempB);
     
     if(tempR == 0 && tempG == 0 && tempB == 0) {
       return 1;
     } else {
       return 0;
     }
  }
  
  int fade_out_labels() {
     float tempR = red(dum_color);
     float tempG = green(dum_color);
     float tempB = blue(dum_color);
     
     if(tempR < 255) {tempR = tempR + 5;}
     if(tempG < 255) {tempG = tempG + 5;}
     if(tempB < 255) {tempB = tempB + 5;}
     
     dum_color = color(tempR, tempG, tempB);
     
     if(tempR == 255 && tempG == 255 && tempB == 255) {
       return 1;
     } else {
       return 0;
     }
  }
  
  float get_w() { return (((width - 120)/data.name.length)/2); }
}  
  
