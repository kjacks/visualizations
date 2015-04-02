class Para_Coord {
  Data data;
  float[] mins;
  float[] maxes;
  float[] x_coords;
  float[][] y_coords;
  float[][] label_coords;
  float[][] labels;
  float x, y;
  float w, h;
  float y_top, y_bott;
  float x_spacing;
  int num_labels;
  PGraphics pg;
  int colored_col;
  int hover_col;
  color[][] colors;
  color[] color_list;
  boolean curve;
  boolean flip;
  boolean[] flipped_cols;

  Para_Coord (Data d) {
    data = d;
    mins = new float[data.get_num_cols()];
    maxes = new float[data.get_num_cols()];
    find_bounds();
    x_coords = new float[data.get_num_cols()];
    y_coords = new float[data.get_num_cols()][data.get_num_rows()];
    num_labels = 5;
    labels = new float[data.get_num_cols()][num_labels];
    label_coords = new float[data.get_num_cols()][num_labels];
    pg = null;
    colored_col = data.get_num_cols() - 1;
    hover_col = -1;
    colors = new color[data.get_num_cols()][data.get_num_rows()];
    curve = false;
    flip = false;
    flipped_cols = new boolean[data.get_num_cols()];
    for(int i = 0; i < flipped_cols.length; i++) {
      flipped_cols[i] = false;
    }

    //generating colors
    color_list = new color[num_labels-1];
    if (num_labels - 1 == 4) {
      color_list[0] = color(255, 0, 146);
      color_list[1] = color(182, 255, 0);
      color_list[2] = color(34, 141, 255);
      color_list[3] = color(255, 202, 27);
    } else {
      for (int i = 0; i < color_list.length; i++) {
        color_list[i] = color(random(0, 255), random(0, 255), random(0, 255));
      }
    }
  }

  void draw_graph(float x_in, float y_in, float w_in, float h_in) {
    x = x_in;
    y = y_in;
    w = w_in;
    h = h_in;

    calculate_axes();
    calc_pts();
    calc_labels();
    calc_colors();

    draw_axes();
    draw_lines();
    draw_pts();
    draw_labels();
  }

  void find_bounds() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      mins[i] = min(data.vals[i]);
      maxes[i] = max(data.vals[i]);
    }
  }

  void calculate_axes() {
    x_spacing = w/(data.get_num_cols()+1);
    for (int i = 0; i < x_coords.length; i++) {
      x_coords[i] = x + x_spacing * (i+1);
    }

    y_top = y+20;
    y_bott = y + h - 40;
  }

  void calc_pts() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < data.get_num_rows (); k++) {
        y_coords[i][k] = map(data.vals[i][k], mins[i], maxes[i], y_bott, y_top);
      }
    }
    for(int i = 0; i < flipped_cols.length; i++) {
      if(flipped_cols[i]) { flip_pts(i); }
    }
  }

  void calc_labels() {
    float y_spacing = (y_bott - y_top)/(num_labels-1);
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < num_labels; k++) {
        float label_spacing = (maxes[i] - mins[i])/(num_labels-1);
        float label = mins[i] + (label_spacing*k);
        labels[i][k] = label;
        label_coords[i][k] = y_bott - (y_spacing*k);
      }
    }
    for(int i = 0; i < flipped_cols.length; i++) {
      if(flipped_cols[i]) { flip_labels(i); }
    }
  }

  void calc_colors() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < data.get_num_rows (); k++) {
        for (int m = 0; m < num_labels - 1; m++) {
          if(!flipped_cols[colored_col]) {
            if (data.vals[colored_col][k] >= labels[colored_col][m] &&
              data.vals[colored_col][k] <= labels[colored_col][m+1]) {
              colors[i][k] = color_list[m];
            }
          } else {
            if (data.vals[colored_col][k] <= labels[colored_col][m] &&
              data.vals[colored_col][k] >= labels[colored_col][m+1]) {
              colors[i][k] = color_list[m];
            }
          }
        }
      }
    }
  }

  void draw_axes() {
    for (int i = 0; i < x_coords.length; i++) {
      if (i == colored_col) {
        /*strokeWeight(3);
         stroke(0);
         fill(0);*/
        strokeWeight(2); 
        stroke(186, 141, 255);
        fill(186, 141, 255);
      } else if (i == hover_col) {
        strokeWeight(1); 
        stroke(0, 255, 173);
        fill(0, 255, 173);
      }

      line(x_coords[i], y_top, x_coords[i], y_bott);
      textSize(10);
      textAlign(CENTER);
      text(data.get_header(i), x_coords[i], y_bott + 20);

      strokeWeight(1);
      stroke(0);
      fill(0);
    }
  }

  void draw_pts() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < data.get_num_rows (); k++) {
        fill(0, 0, 0);
        ellipse(x_coords[i], y_coords[i][k], 5, 5);
      }
    }
  }

  void draw_lines() {
    if (curve) {
      noFill();
      int num_cols = data.get_num_cols();
      for (int i = 0; i < (data.get_num_rows ()); i++) {
        //for (int i = 0; i < 1; i++) {
        stroke(colors[0][i]);
        for (int k = 0; k < num_cols - 1; k++) {
          if (y_coords[k][i] > y_coords[k+1][i]) {
            bezier(x_coords[k], y_coords[k][i], 
            x_coords[k]+(x_spacing/4), y_coords[k][i]+((3/4)*(y_coords[k][i]-y_coords[k+1][i])), 
            x_coords[k]+3*(x_spacing/4), y_coords[k+1][i]-((1/4)*(y_coords[k][i]-y_coords[k+1][i])), 
            x_coords[k+1], y_coords[k+1][i]);
          } else {
            bezier(x_coords[k], y_coords[k][i], 
            x_coords[k]+3*(x_spacing/4), y_coords[k][i]-((1/4)*(y_coords[k+1][i]-y_coords[k][i])), 
            x_coords[k]+(x_spacing/4), y_coords[k+1][i]+((3/4)*(y_coords[k+1][i]-y_coords[k][i])), 
            x_coords[k+1], y_coords[k+1][i]);
          }
        }
      }
      stroke(0);
    } else {
      for (int i = 0; i < (data.get_num_rows ()); i++) {
        for (int k = 0; k < data.get_num_cols () - 1; k++) {
          stroke(colors[k][i]);
          line(x_coords[k], y_coords[k][i], x_coords[k+1], y_coords[k+1][i]);
          stroke(0, 0, 0);
        }
      }
    }
  }

  void draw_labels() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < num_labels; k++) {
        fill(0, 0, 0);
        textSize(10);
        textAlign(RIGHT, CENTER);
        float len = y_bott - y_top;
        text(labels[i][k], x_coords[i]-5, label_coords[i][k]);
      }
    }
  }

  void col_change(int mousex) {
    int num_cols = data.get_num_cols();
    for (int i = 0; i < num_cols; i++) {
      if (mousex > (width/num_cols)*i && mousex < (width/num_cols)*(i+1)) {
        colored_col = i;
      }
    }
  }

  void hover(int mousex) {
    int num_cols = data.get_num_cols();
    for (int i = 0; i < num_cols; i++) {
      if (mousex > (w/num_cols)*i && mousex < (w/num_cols)*(i+1)) {
        hover_col = i;
      }
    }
  }

  void flip_dim() { flipped_cols[hover_col] = true; }
  void unflip() { flipped_cols[hover_col] = false; }

  void flip_pts(int i) {
    //print("flipping points\n");
    for (int k = 0; k < data.get_num_rows (); k++) {
      y_coords[i][k] = map(data.vals[i][k], maxes[i], mins[i], y_bott, y_top);
      //print("flipped: ", y_coords[i][0], "\n");
    }
  }

  void flip_labels(int i) {
    float y_spacing = (y_bott - y_top)/(num_labels-1);
    for (int k = 0; k < num_labels; k++) {
      float label_spacing = (maxes[i] - mins[i])/(num_labels-1);
      float label = maxes[i] - (label_spacing*k);
      labels[i][k] = label;
      label_coords[i][k] = y_bott - (y_spacing*k);
    }
  }

  void view_bezier() { curve = true; }
  void view_line() { curve = false; }
}

