import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class lab8 extends PApplet {

Data data;
Para_Coord graph;
int screenWidth = 800;
int screenHeight = 800;

public void setup() {
  size(screenWidth, screenHeight);
  if (frame != null) {
    frame.setResizable(true);
  }

  data = new Data();
  data.parse("iris.csv");
  graph = new Para_Coord(data);
}

public void draw() {
  background(255, 255, 255);
  graph.draw_graph(0, 0, width, height);
}

class Data { 
  String[] header;
  int num_cols;
  float[][] vals;

  public void parse(String file) {
    String[] lines = loadStrings(file);
    String[] split_line;

    readHeader(lines[0]);
    num_cols = header.length;
    vals = new float[num_cols][lines.length - 1];

    //print(lines.length);
    for (int k = 0; k < num_cols; k++) {
      for (int i = 1; i < lines.length; i++) {
        split_line = splitTokens(lines[i], ",");
        vals[k][i-1] = PApplet.parseFloat(split_line[k]);
      }
    }

    //printArray(vals[1]);
  }

  public void readHeader(String line1) {
    header = new String[8];

    //given CSV has header delimited by ',' & ' '
    header = splitTokens(line1, ",");
    /*print("Headers: \n");
     printArray(header);
     print('\n');*/
  }
  
  public int get_num_cols() { return num_cols; }
  public int get_num_rows() { return vals[0].length; }
  public String get_header(int index) { return header[index]; };
}
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
  int num_labels;
  PGraphics pg;
  int colored_col;
  int[][] colors;
  int[] color_list;

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
    colors = new int[data.get_num_cols()][data.get_num_rows()];
   
    color_list = new int[num_labels-1];
    color_list[0] = color(0,0,0);
    color_list[1] = color(255, 0, 0);
    color_list[2] = color(0, 255, 0);
    color_list[3] = color(0, 0, 255);
    /*for(int i = 0; i < color_list.length; i++) {
      color_list[i] = color(random(0, 255), random(0, 255), random(0, 255));
    } */ 
  }

  public void draw_graph(float x_in, float y_in, float w_in, float h_in) {
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

  public void find_bounds() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      mins[i] = min(data.vals[i]);
      maxes[i] = max(data.vals[i]);
    }
  }

  public void calculate_axes() {
    float x_spacing = w/(data.get_num_cols()+1);
    for (int i = 0; i < x_coords.length; i++) {
      x_coords[i] = x_spacing * (i+1);
    }

    y_top = y + 20;
    y_bott = y + h - 60;
  }

  public void calc_pts() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < data.get_num_rows (); k++) {
        y_coords[i][k] = map(data.vals[i][k], mins[i], maxes[i], y_bott, y_top);
      }
    }
  }

  public void calc_labels() {
    float y_spacing = (y_bott - y_top)/(num_labels-1);
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < num_labels; k++) {
        float label_spacing = (maxes[i] - mins[i])/(num_labels-1);
        float label = mins[i] + (label_spacing*k);
        labels[i][k] = label;
        label_coords[i][k] = y_bott - (y_spacing*k);
      }
    }
  }

  public void calc_colors() {
    for(int i = 0; i < data.get_num_cols(); i++) {
      for(int k = 0; k < data.get_num_rows(); k++) {
        for(int m = 0; m < num_labels - 1; m++) {
          print(labels[colored_col][m], labels[colored_col][m+1]);
          if (data.vals[colored_col][k] < labels[colored_col][m] &&
              data.vals[colored_col][k] > labels[colored_col][m+1]) {
            colors[i][k] = color_list[m];
          }
        }
      }
    }
  }

  public void draw_axes() {
    for (int i = 0; i < x_coords.length; i++) {
      fill(0, 0, 0);
      line(x_coords[i], y_top, x_coords[i], y_bott);
      textSize(15);
      textAlign(CENTER);
      text(data.get_header(i), x_coords[i], y_bott + 20);
    }
  }

  public void draw_pts() {
    for (int i = 0; i < data.get_num_cols (); i++) {
      for (int k = 0; k < data.get_num_rows (); k++) {
        fill(0, 0, 0);
        ellipse(x_coords[i], y_coords[i][k], 5, 5);
      }
    }
  }

  public void draw_lines() {
    for (int i = 0; i < (data.get_num_rows ()); i++) {
      for (int k = 0; k < data.get_num_cols () - 1; k++) {
          stroke(colors[k][i]);
          line(x_coords[k], y_coords[k][i], x_coords[k+1], y_coords[k+1][i]);
          stroke(0, 0, 0);
      }
    }
  }

  public void draw_labels() {
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
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "lab8" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
