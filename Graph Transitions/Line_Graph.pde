class Line_Graph {
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
  float y_interval;
  int num_intervals;
  int isect;
  int shown_intervals;
  float radius;
  int display_x, display_y;
  color axes_color;

  //variables for transition
  int phase;
  float[] dum_x;
  float[] dum_y;
  float dum_radius;
  float dum_y_x, dum_y_y;
  float dum_x_x, dum_x_y;
  color dum_color;

  Line_Graph(Data parsed) {
    phase = 0;
    data = parsed;
    y_max = max(data.values[0]);
    num_points = data.name.length;
    y_interval = 5;
    num_intervals = 0;
    isect = -1;
    radius = 10;
    axes_color = color(0, 0, 0);
  }

  void draw_graph() {
    make_canvas(); 
    calc_y_interval();
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    draw_line(x_coords, y_coords, x_coords, y_coords);
    draw_points(radius);
  }

  void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 120;
    canvas_x1 = 60;
    canvas_x2 = width - 60;

    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  void calc_y_interval() {
    num_intervals = int((y_max / y_interval) + 1);
    shown_intervals = num_intervals/10;
  }

  void draw_axes(float x_x, float x_y, float y_x, float y_y) {
    fill(255, 255, 255);
    line(canvas_x1, canvas_y1, y_x, y_y); // y axis
    line(canvas_x1, canvas_y2, x_x, x_y); // x axis
  }

  void draw_axes_labels(color c) {    
    //Draw y axis
    for (int i = 0; i <= num_intervals; i += 1) {
      float pos_y = canvas_y2 - (i * (canvas_h/num_intervals));
      float pos_x = canvas_x1 - 15;

      if (shown_intervals == 0) {
        fill(c);
        textSize(10);
        text(int(i*y_interval), pos_x, pos_y);
        shown_intervals = num_intervals/10;
      } else {
        shown_intervals--;
      }
    }    

    //Draw x axis labels
    update_x();
    for (int i = 0; i < num_points; i += 1) {
      float pos_x = x_coords[i];
      float pos_y = canvas_y2 + 10;
      translate(pos_x, pos_y);
      rotate(PI/2);

      fill(c);
      textAlign(LEFT, RIGHT);
      textSize(10);
      text(data.name[i], 0, 0);        

      rotate(-PI/2);
      translate(-pos_x, -pos_y);
    }
  }
  
  void update_x() {
      x_coords = new float[0];
      float spacing = canvas_w/num_points;
      for (int i = 0; i < num_points; i += 1) {
        float pos_x = (i*spacing) + (spacing/2) + canvas_x1;
        x_coords = append(x_coords, pos_x + 10); 
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

  void draw_points(float r) {
    update_y();

    for (int i = 0; i < data.name.length; i++) {
      /*if (i == isect) {
        fill(255, 0, 0);
        ellipse(x_coords[i], y_coords[i], r, r);
        textSize(10);
        text("(" + data.name[i] + ", " + data.values[0][i] + ")", x_coords[i] + 8, y_coords[i] + 8);
      } else {*/
        float gray = map(i, 0, data.name.length, 0, 255);
        fill(150, gray, 150);
        ellipse(x_coords[i], y_coords[i], r, r);
    }
  }
  
  void update_y() {
      y_coords = new float[0];
      float max_height = num_intervals*y_interval;

      for (int i = 0; i < data.name.length; i++) {
        float ratio = data.values[0][i]/max_height;
        y_coords = append(y_coords, (float(canvas_h)-(float(canvas_h)*ratio))+canvas_y1);
      }
  }

  void draw_line(float[] x1, float[] y1, float[] x2, float[] y2) {
    for (int i = 0; i < (data.name.length - 1); i++) {
      line(x1[i], y1[i], x2[i+1], y2[i+1]);
    }
  }

  void update() {
    make_canvas();
    calc_y_interval();
    update_x();
    update_y();
  }


  boolean line_to_bar() {    
    if (phase == 0) {
      phase += set_ltob_dummy();
    } else if (phase == 1) {
      phase += shrink_lines();
    } else if (phase == 2) {
      phase += shrink_points();
    } else {
      phase = 0;
      //Creates blank frame if draw functions still not called in here
      
      make_canvas(); 
      calc_y_interval();
      draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
      draw_axes_labels(axes_color);
      draw_axes_titles();
      draw_line(x_coords, y_coords, dum_x, dum_y);
      draw_points(dum_radius);
      
      return true;
    }

    make_canvas(); 
    calc_y_interval();
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    draw_line(x_coords, y_coords, dum_x, dum_y);
    draw_points(dum_radius);

    return false;
  }

  int set_ltob_dummy() {
    dum_y = new float[num_points];
    dum_x = new float[num_points];
    dum_radius = radius;

    for (int i = 0; i < num_points; i++) {
      dum_y[i] = y_coords[i];
      dum_x[i] = x_coords[i];
    }
    return 1;
  }

  int shrink_lines() {
    for (int i = 1; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], y_coords[i-1], .1);
      dum_x[i] = lerp(dum_x[i], x_coords[i-1], .1);
    }

    boolean all_same = true;
    for (int i = 1; i < num_points; i++) {
      if ((int)dum_y[i] != (int)y_coords[i-1]) {
        all_same = false;
      } else if ((int)dum_x[i] != (int)x_coords[i-1]) {
        all_same = false;
      }
    }

    if (all_same) {
      return 1;
    } else {
      return 0;
    }
  }

  int shrink_points() {
    dum_radius = lerp(dum_radius, 1, .05);
    if (dum_radius < 1.2) {
      return 1;
    } else {
      return 0;
    }
  }

  boolean bar_to_line() {
    if (phase == 0) {
      phase += set_btol_dummy();
    } else if (phase == 1) {
      phase += expand_points();
    } else if (phase == 2) {
      phase += expand_lines();
    } else {
      make_canvas(); 
      calc_y_interval();
      draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
      draw_axes_labels(axes_color);
      draw_axes_titles();
      draw_line(x_coords, y_coords, dum_x, dum_y);
      draw_points(dum_radius);
      phase = 0;
      return false;
    }

    make_canvas(); 
    calc_y_interval();
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    draw_line(x_coords, y_coords, dum_x, dum_y);
    draw_points(dum_radius);

    return true;
  }

  int set_btol_dummy() {
    dum_y = new float[num_points];
    dum_x = new float[num_points];
    dum_radius = 1;
    make_canvas(); 
    calc_y_interval();
    //draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    //draw_axes_labels(color(255, 255, 255));
    //draw_axes_titles();
    draw_points(dum_radius);


    for (int i = 1; i < num_points; i++) {
      dum_y[i] = y_coords[i-1];
      dum_x[i] = x_coords[i-1];
    }
    return 1;
  }
  
  int set_ptol_dummy() {
    dum_y = new float[num_points];
    dum_x = new float[num_points];
    dum_radius = 1;
    dum_y_x = canvas_x1;
    dum_y_y = canvas_y1;
    dum_x_x = canvas_x1;
    dum_x_y = canvas_y2;
    dum_color = color(255, 255, 255);

    for (int i = 1; i < num_points; i++) {
      dum_y[i] = y_coords[i-1];
      dum_x[i] = x_coords[i-1];
    }
    return 1; 
  }

  int expand_points() {
    dum_radius = lerp(dum_radius, radius, .05);
    if (dum_radius > radius - .1) {
      return 1;
    } else {
      return 0;
    }
  }

  int expand_lines() {
    for (int i = 0; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], y_coords[i], .1);
      dum_x[i] = lerp(dum_x[i], x_coords[i], .1);
    }

    boolean all_same = true;
    for (int i = 0; i < num_points; i++) {
      if (dum_y[i] < y_coords[i]-.2) {
        all_same = false;
      } else if (dum_x[i] < x_coords[i]-.2) {
        all_same = false;
      }
    }

    if (all_same) {
      return 1;
    } else {
      return 0;
    }
  }

  void point_intersect(int mousex, int mousey) {
    boolean intersection = false;

    for (int i = 0; i < data.name.length; i++) {
      float posx = x_coords[i];
      float posy = y_coords[i];
      float radius = 5;

      float distance = sqrt((mousex - posx) * (mousex - posx) + 
        (mousey - posy) * (mousey - posy));
      if (distance < radius) {
        isect = i;
        intersection = true;
      }
    }

    if (intersection == false) {
      isect = -1;
    }
  }

  boolean pie_to_line() {
    //rate is .05
    if (phase == 0) {
      phase += set_ptol_dummy();
    } else if (phase == 1) {
      expand_points();
      phase += expand_axes();
    } else if (phase < 4) {
      phase += expand_lines();
      phase += fade_in_labels();
    } else {
      phase = 0;
      make_canvas(); 
      calc_y_interval();
      draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
      draw_axes_labels(axes_color);
      draw_axes_titles();
      draw_line(x_coords, y_coords, dum_x, dum_y);
      draw_points(dum_radius);
      return false;
    }

    make_canvas(); 
    calc_y_interval();
    draw_axes(dum_x_x, dum_x_y, dum_y_x, dum_y_y); 
    draw_axes_labels(dum_color);
    draw_axes_titles();
    draw_line(x_coords, y_coords, dum_x, dum_y);
    draw_points(dum_radius);
    return true;
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
      dum_x_x = lerp(dum_x_x, canvas_x1, .05);
      dum_y_y = lerp(dum_y_y, canvas_y1, .05);
      
      if (int(dum_x_x) + 1 >= int(canvas_x2)) {
          return 1;
      } else {
          return 0;
      }
  }
  
  boolean line_to_pie() {
    if (phase == 0) {
      phase += set_ltop_dummy();
    } else if (phase == 1) {
      phase += shrink_lines();
    } else if (phase < 6) {
      phase += shrink_points();
      phase += fade_out_labels();
      phase += shrink_axes();
    } else {
      //Creates blank frame if draw functions still not called in here
      make_canvas(); 
      calc_y_interval();
      draw_line(x_coords, y_coords, dum_x, dum_y);
      draw_points(dum_radius);
      phase = 0;
      return true;
    }

    make_canvas(); 
    calc_y_interval();
    draw_axes(dum_x_x, dum_x_y, dum_y_x, dum_y_y);
    draw_axes_labels(dum_color);
    draw_axes_titles();
    draw_line(x_coords, y_coords, dum_x, dum_y);
    draw_points(dum_radius);
    
    return false;
  }
  
  int set_ltop_dummy() {
    dum_y = new float[num_points];
    dum_x = new float[num_points];
    dum_radius = radius;
    dum_color = color(0, 0, 0);
    dum_y_x = canvas_x1;
    dum_y_y = canvas_y2;
    dum_x_x = canvas_x2;
    dum_x_y = canvas_y2;

    for (int i = 0; i < num_points; i++) {
      dum_y[i] = y_coords[i];
      dum_x[i] = x_coords[i];
    }
    return 1;
  }
  
  boolean line_to_triver() {
   if (phase == 0) {
      dum_radius = radius;
      phase++;
    } else if (phase == 1) {
      phase += shrink_points();
    } else {
      phase = 0;
      //Creates blank frame if draw functions still not called in here
      make_canvas(); 
      draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
      draw_axes_labels(axes_color);
      draw_axes_titles();
      draw_points(dum_radius);
      draw_line(x_coords, y_coords, x_coords, y_coords);
      return true;
    }

    make_canvas(); 
    calc_y_interval();
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    draw_points(dum_radius);
    draw_line(x_coords, y_coords, x_coords, y_coords);
    return false;
}

boolean triver_to_line() {
   if (phase == 0) {
      dum_radius = 0;
      phase++;
    } else if (phase == 1) {
      phase += expand_points();
    } else {
      phase = 0;
      //Creates blank frame if draw functions still not called in here
      make_canvas(); 
      draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
      draw_axes_labels(axes_color);
      draw_axes_titles();
      draw_points(dum_radius);
      draw_line(x_coords, y_coords, x_coords, y_coords);
      return false;
    }

    make_canvas(); 
    calc_y_interval();
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    draw_points(dum_radius);
    draw_line(x_coords, y_coords, x_coords, y_coords);
    return true;
}

  float[] get_y() { return y_coords; }
  float[] get_x() { return x_coords; }
}

