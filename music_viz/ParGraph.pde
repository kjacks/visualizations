//Needs UserData to have:
//  int get_num_rows() { return vals[0].length; }
//  String get_header(int index) { return header[index]; };

class ParGraph {
  //initializations for final project
  boolean active;
  int num_cols;
  int num_rows;
  Range range;
  String gender;
  float[][] vals;

  //default initializations
  UserData data;
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
  boolean flip;
  boolean[] flipped_cols;
  String[] headers;
  Range prev;
  String[] questions;

  ParGraph (UserData d) {
    //initializations for final project
    num_cols = d.NUM_QS + 1;
    num_rows = 93;
    data = d;
    prev = new Range();
    prev.low = 0;
    prev.high = 0;
    prev.gender="";

    //initializing questions
    headers = new String[num_cols];
    for (int i = 0; i < num_cols; i++) {
      headers[i] = "Q" + str(i);
    }
    headers[headers.length - 1] = "Age";
    questions = new String[num_cols];
    questions[0] = "I enjoy actively searching for and discovering music that I have never heard before";
    questions[1] = "I find it easy to find new music";
    questions[2] = "I am constantly interested in and looking for more music";
    questions[3] = "I would like to buy new music but I don't know what to buy";
    questions[4] = "I used to know where to find music";
    questions[5] = "I am not willing to pay for music";
    questions[6] = "I enjoy music primarily from going out to dance";
    questions[7] = "Music for me is all about nightlife and going out";
    questions[8] = "I am out of touch with new music";
    questions[9] = "My music collection is a source of pride";
    questions[10] = "Pop music is fun";
    questions[11] = "Pop music helps me to escape";
    questions[12] = "I want a multimedia experience at my fingertips wherever I go";
    questions[13] = "I love technology";
    questions[14] = "People often ask my advice on music - what to listen to";
    questions[15] = "I would be willing to pay for the opportunity to buy new music pre-release";
    questions[16] = "I find seeing a new artist/band on TV a useful way of discovering new music";
    questions[17] = "I like to be at the cutting edge of new music";
    questions[18] = "I like to know about music before other people";
    questions[19] = "Age";

    //initializing columns and rows
    num_labels = headers.length;
    labels = new float[num_cols][num_labels];
    label_coords = new float[num_cols][num_labels];
    pg = null;
    colored_col = num_cols - 1;

    //initializing interactivity
    hover_col = -1;
    flip = false;
    flipped_cols = new boolean[num_cols];
    for (int i = 0; i < flipped_cols.length; i++) {
      flipped_cols[i] = false;
    }
    generate_colors();
  }

  void draw_graph(int x_in, int y_in, int w_in, int h_in, Range r, String g) {
    print("DRAWING PARGRAPH\n");
    x = x_in;
    y = y_in;
    w = w_in;
    h = h_in;

    fill(255);
    noStroke();
    rect(x, y, w, h);

    range = r;
    gender = g;

    calculate_data(r, g);
    calculate_axes();
    calc_pts();
    calc_labels();
    calc_colors();

    draw_axes();
    draw_lines();
    //draw_pts();
    draw_labels();
    draw_captioning();

    prev = r;
  }

  void calculate_data(Range r, String g) {
    num_rows = range.high - range.low;

    vals = data.get_qs_avg(range, gender);

    mins = new float[num_cols];
    maxes = new float[num_cols];
    find_bounds();
    x_coords = new float[num_cols];
    y_coords = new float[num_cols][num_rows];
  }

  void generate_colors() {
    colors = new color[num_cols][num_rows];
    color_list = new color[num_labels-1];
    if (num_labels - 1 == 4) {
      color_list[0] = color(255, 0, 146);
      color_list[1] = color(182, 255, 0);
      color_list[2] = color(34, 141, 255);
      color_list[3] = color(255, 202, 27);
    } else {
      for (int i = 0; i < color_list.length; i++) {
        //color_list[i] = color(random(0, 255), random(0, 255), random(0, 255));
        color_list[i] = color(random(0, 200), map(i, 0, color_list.length, 255, 150), map(i, 0, color_list.length, 150, 255));
      }
    }
  }

  void find_bounds() {
    for (int i = 0; i < num_cols; i++) {
      //print(vals[i].length);
      mins[i] = 100;
      maxes[i] = max(vals[i]);
      for (int k = 0; k < vals[i].length; k++) {
        if (vals[i][k] != -1 && vals[i][k] < mins[i]) {
          mins[i] = vals[i][k];
        }
      }
    }
  }

  void calculate_axes() {
    x_spacing = w/(num_cols+1);
    for (int i = 0; i < x_coords.length; i++) {
      x_coords[i] = x + x_spacing * (i+1);
    }

    y_top = y+20;
    y_bott = y + h - 100;
  }

  void calc_pts() {
    for (int i = 0; i < num_cols; i++) {
      for (int k = 0; k < num_rows; k++) {
        if (vals[i][k] != -1) {
          y_coords[i][k] = map(vals[i][k], mins[i], maxes[i], y_bott, y_top);
          if (y_coords[i][k] < y_top) {
            y_coords[i][k] = y_top;
          }
        } else {
          y_coords[i][k] = -1;
        }
      }
    }
    for (int i = 0; i < flipped_cols.length; i++) {
      if (flipped_cols[i]) { 
        flip_pts(i);
      }
    }
  }

  void calc_labels() {
    float y_spacing = (y_bott - y_top)/(num_labels-1);
    for (int i = 0; i < num_cols; i++) {
      for (int k = 0; k < num_labels; k++) {
        float label_spacing = (maxes[i] - mins[i])/(num_labels-1);
        float label = mins[i] + (label_spacing*k);
        labels[i][k] = label;
        label_coords[i][k] = y_bott - (y_spacing*k);
      }
    }
    for (int i = 0; i < flipped_cols.length; i++) {
      if (flipped_cols[i]) { 
        flip_labels(i);
      }
    }
  }

  void calc_colors() {
    for (int i = 0; i < num_cols; i++) {
      for (int k = 0; k < num_rows; k++) {
        for (int m = 0; m < num_labels - 1; m++) {
          if (!flipped_cols[colored_col]) {
            if (vals[colored_col][k] >= labels[colored_col][m] &&
              vals[colored_col][k] <= labels[colored_col][m+1]) {
              colors[i][k] = color_list[m];
            }
          } else {
            if (vals[colored_col][k] <= labels[colored_col][m] &&
              vals[colored_col][k] >= labels[colored_col][m+1]) {
              colors[i][k] = color_list[m];
            }
          }
        }
      }
    }
  }

  void draw_axes() {
    strokeWeight(1);
    stroke(0);
    fill(0);

    for (int i = 0; i < x_coords.length; i++) {
      if (i == colored_col) {
        strokeWeight(2); 
        stroke(186, 141, 255);
        fill(186, 141, 255);
      } else if (i == hover_col) {
        strokeWeight(1); 
        stroke(0, 255, 173);
        fill(0, 255, 173);
      }

      if (flipped_cols[i]) {
        text("Flipped", x_coords[i], y_bott + 30);
      }

      line(x_coords[i], y_top, x_coords[i], y_bott);
      textSize(10);
      textAlign(CENTER);
      text(headers[i], x_coords[i], y_bott + 20);

      strokeWeight(1);
      stroke(0);
      fill(0);
    }
  }

  void draw_pts() {
    for (int i = 0; i < num_cols; i++) {
      //printArray(y_coords[i]);
      for (int k = 0; k < num_rows; k++) {
        if (y_coords[i][k] != -1) {
          fill(0, 0, 0);
          ellipse(x_coords[i], y_coords[i][k], 5, 5);
        }
      }
    }
  }

  void draw_lines() {
    for (int i = 0; i < num_rows; i++) {
      for (int k = 0; k < num_cols-1; k++) {
        if (y_coords[k][i] != -1 && y_coords[k+1][i] != -1) {
          stroke(colors[k][i]);
          line(x_coords[k], y_coords[k][i], x_coords[k+1], y_coords[k+1][i]);
          stroke(0, 0, 0);
        }
      }
    }
  }

  void draw_labels() {
    for (int i = 0; i < num_cols; i++) {
      for (int k = 0; k < num_labels; k++) {
        if (i == hover_col) {
          fill(0, 0, 0);
          textSize(10);
          textAlign(LEFT, CENTER);
          float len = y_bott - y_top;
          text(labels[i][k], x_coords[i]+5, label_coords[i][k]);
        }
      }
    }
  }

  void draw_captioning() {
    for (int i = 0; i < num_cols; i++) {
      if (i == hover_col) {
        strokeWeight(1);
        textSize(15);
        textAlign(CENTER, CENTER);
        text(questions[i], w/2, y_bott+45);
      }
    }
    textSize(10);
    text("To flip an axis, use up and down arrows when hovering over it. To recolor lines based on a different axis, click the axis.", w/2, y_bott+75);
  }

  void col_change(int mousex) {
    for (int i = 0; i < num_cols; i++) {
      if (mousex > (width/num_cols)*i && mousex < (width/num_cols)*(i+1)) {
        colored_col = i;
      }
    }
  }

  void hover(int mousex) {
    // int num_cols = num_cols;
    for (int i = 0; i < num_cols; i++) {
      if (mousex > (w/num_cols)*i && mousex < (w/num_cols)*(i+1)) {
        hover_col = i;
      }
    }
  }

  void flip_dim() { 
    flipped_cols[hover_col] = true;
  }
  void unflip() { 
    flipped_cols[hover_col] = false;
  }

  void flip_pts(int i) {
    //print("flipping points\n");
    for (int k = 0; k < num_rows; k++) {
      y_coords[i][k] = map(vals[i][k], maxes[i], mins[i], y_bott, y_top);
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
}

