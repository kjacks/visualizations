class WordBar {
  int[] vals;
  int num_ages = 94;
  int canvas_x1, canvas_x2;
  int canvas_y1, canvas_y2;
  int canvas_w, canvas_h;
  float[] x_coords;
  float[] y_coords;
  float max_val;
  int interval;
  int x_spacing;
  int bar_width;
  boolean with_axes;
  
  WordBar(int[] vs, int x1, int y1, int x2, int y2, boolean w_axes) {
    max_val = 700;
    vals = new int[num_ages];
    for (int i = 0; i < num_ages; i++) {
      vals[i] = vs[i];
    }
    canvas_x1 = x1;
    canvas_x2 = x2;
    canvas_y1 = y1;
    canvas_y2 = y2;
    canvas_w = x2 - x1;
    canvas_h = y2 - y1;
    interval = canvas_w/(num_ages + 10);
    x_spacing = 2;
    bar_width = interval - 2*x_spacing;
    with_axes = w_axes;
  }
  
  void draw_graph(Range range, String word) {
    fill(255);
    noStroke();
    rect(0, canvas_y1 - 5, canvas_w - 50, canvas_h + 5);
    get_coords();
    draw_bars(range, word);
    if (with_axes == true) {
      draw_axes();
    }
  }
  
  void get_coords() {
    y_coords = new float[num_ages];
    x_coords = new float[num_ages];
    int curr_x = canvas_x1;
    
    for (int i = 0; i < num_ages; i++) {
       float ratio = vals[i]/max_val;
       y_coords[i] = (float(canvas_h) - float(canvas_h)*ratio) + canvas_y1;
       x_coords[i] = lerp(canvas_x1, canvas_x2 - 30, (i / 93.0));
       //curr_x += interval;
    }
    
  }
  
  void draw_bars(Range range, String word) {
     float highest = min(y_coords);
     boolean drawn = false;
    
     for (int i = 0; i < num_ages; i++) {
        if((i >= range.low) && (i <= range.high)) {
            fill(0);
        } else {
            fill(125);
        }
        rect(x_coords[i]+x_spacing, y_coords[i], bar_width, canvas_y2 - y_coords[i]);
        
        if ((with_axes == false) && (y_coords[i] == highest && drawn == false)) {
           String msg ="age " + i + " = " + vals[i];
           PFont font;
           font = loadFont("UbuntuMono-Regular-13.vlw");
           textFont(font, 13);
           textAlign(CENTER);
           //text(msg, x_coords[i], y_coords[i] - 12);
           //text(vals[i], x_coords[i], y_coords[i] - 2);
           text(msg, x_coords[i], y_coords[i] - 2);
           noStroke();
           drawn = true;
        }
     }
     
     textSize(15);
     text(word, canvas_x1 + 50, canvas_y2 - 10);
    
  }
  
  void draw_axes() {
    fill(0);
    stroke(0);
    textSize(12);
    for (int i = 0; i < max_val; i += 50) {
       float ratio = i/max_val;
       float y = (float(canvas_h) - float(canvas_h)*ratio) + canvas_y1;
       text(i, canvas_x1 + 85, y);
    }
    
  }
  
  
}
