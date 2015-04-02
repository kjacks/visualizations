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

public class a2 extends PApplet {

//pie & line - Ali
//pie & bar - Matt
//bar & line - Kirk

int screenWidth = 1000;
int screenHeight = 800;
String curr_chart;
String next_chart;
Data data;
Button line_button, bar_button, pie_button;
Button triver_button, stack_button, rose_button;
Line_Graph line;
Bar_Graph bar;
Pie_Chart pie;
Stacked_Bar stack;
Theme_River triver;
Rose_Chart rose;
boolean half_complete;
boolean line_to_bar;

public void setup() {
   size(screenWidth, screenHeight);
   background(255, 255, 255);
   data = new Data();
   data.parse("Dataset2.csv");
   if (frame!=null) { frame.setResizable(true); }
   buttons_set();
   curr_chart = "Line Graph";
   next_chart = "Line Graph";
   line = new Line_Graph(data);
   bar = new Bar_Graph(data);
   pie = new Pie_Chart(data);
   stack = new Stacked_Bar(data);
   triver = new Theme_River(data);
   rose = new Rose_Chart(data);
   half_complete = false;
   line_to_bar = false;
}

public void draw() {
    background(255, 255, 255);
    draw_buttons();
    line.update();
    
    if (curr_chart != next_chart) {
        draw_transition();
    } else {
        if (curr_chart == "Line Graph") {
            line.draw_graph();
        } else if (curr_chart == "Bar Chart") {
            bar.draw_graph();
        } else if (curr_chart == "Pie Chart") {
            pie.draw_graph();
        } else if (curr_chart == "Theme River") {
            triver.draw_graph();
        } else if (curr_chart == "Stacked Bar") {
            stack.draw_graph();
        } else if (curr_chart == "Rose Chart") {
            rose.draw_graph();
        }
    }
    
}

public void mouseClicked() {
    check_button();
}

public void draw_transition() {
    //REMEMBER TO REMOVE CURR_CHART = NEXT_CHART <-- JUST FOR RUNNING CODE
    if (curr_chart == "Line Graph") {
        if (next_chart == "Bar Chart") {
            //print("line to bar\n");
            line_to_bar();
        } else if (next_chart == "Pie Chart") {
            //print ("line to pie\n");
            line_to_pie();
        } else if (next_chart == "Theme River") {
            //print ("line to triver\n");
            line_to_triver();
        } else if (next_chart == "Stacked Bar") {
            line_to_bar();
        } else if (next_chart == "Rose Chart") {
            line_to_pie();
        }
    } else if (curr_chart == "Bar Chart") {
        if (next_chart == "Line Graph") {
            //print("bar to line\n");
            bar_to_line();
        } else if (next_chart == "Pie Chart") {
            //print("bar to pie\n");
            bar_to_pie();
            //curr_chart = next_chart;
        } else if (next_chart == "Theme River") {
            //print ("line to triver\n");
            bar_to_line();
        } else if (next_chart == "Stacked Bar") {
            bar_to_stack();
        } else if (next_chart == "Rose Chart") {
            bar_to_pie();
        }
    } else if (curr_chart == "Pie Chart") {
        if (next_chart == "Line Graph") {
             //print("pie to line\n");
             pie_to_line();
        } else if (next_chart == "Bar Chart") {
             //print ("pie to bar\n");
             pie_to_bar();
        } else if (next_chart == "Theme River") {
            //print ("line to triver\n");
            pie_to_line();
        } else if (next_chart == "Stacked Bar") {
            pie_to_bar();
        } else if (next_chart == "Rose Chart") {
            pie_to_rose();
        }
    } else if (curr_chart == "Theme River") {
         triver_to_line();
    } else if (curr_chart == "Stacked Bar") {
         stack_to_bar();
    } else if (curr_chart == "Rose Chart") {
         rose_to_pie();
    }
        
}

public void line_to_bar() {
    if (half_complete == false) {
       half_complete = line.line_to_bar();
    } else {
       half_complete = bar.line_to_bar();
        if (half_complete == false) {
            //print("transition complete\n");
            curr_chart = "Bar Chart";
        }
    }
}

public void bar_to_line() {
    if (half_complete == false) {
        //print("half complete is false, calling bar to line\n");
        half_complete = bar.bar_to_line();
    } else {
       //print("half complete is true, calling bar to line\n");
       half_complete = line.bar_to_line();
        if (half_complete == false) {
            curr_chart = "Line Graph";
        }
    }
    
}

public void pie_to_bar() {
  if (half_complete == false) {
      half_complete = pie.pie_to_bar(line.get_y(), line.get_x(), bar.get_w());
  } else {
      half_complete = bar.pie_to_bar();
      if (half_complete == false) {
         curr_chart = "Bar Chart";
      }
  }
}

public void bar_to_pie() {
  if (half_complete == false) {
      half_complete = bar.bar_to_pie();
  } else {
      half_complete = pie.bar_to_pie(line.get_y(), line.get_x(), bar.get_w());
      if (half_complete == false) {
         curr_chart = "Pie Chart";
      }
  }
}

public void pie_to_line() {
  if (half_complete == false) {
      half_complete = pie.pie_to_line(line.get_y(), line.get_x());
  } else {
      half_complete = line.pie_to_line();
      if (half_complete == false) {
          curr_chart = "Line Graph";
      }
  }
}

public void line_to_pie() {
  if (half_complete == false) {
      half_complete = line.line_to_pie();
  } else {
      half_complete = pie.line_to_pie(line.get_y(), line.get_x(), 50);
      if (half_complete == false) {
          curr_chart = "Pie Chart";
      }
  }
}

public void line_to_triver() {
    if (half_complete == false) {
       half_complete = line.line_to_triver();
    } else {
       half_complete = triver.line_to_triver(line.y_coords);
        if (half_complete == false) {
            curr_chart = "Theme River";
        }
    }
}

public void triver_to_line() {
    if (half_complete == false) {
       half_complete = triver.triver_to_line(line.y_coords);
    } else {
       half_complete = line.triver_to_line();
        if (half_complete == false) {
            curr_chart = "Line Graph";
        }
    }
}

public void stack_to_bar() {
    curr_chart = "Bar Chart";
}

public void bar_to_stack() {
    curr_chart = "Stacked Bar";
}

public void pie_to_rose() {
    curr_chart = "Rose Chart";
}

public void rose_to_pie() {
    curr_chart = "Pie Chart";
}

public void draw_buttons() {
    line_button.draw_button(width/7, height-30);
    bar_button.draw_button(2*width/7, height-30);
    pie_button.draw_button(3*width/7, height-30);
    triver_button.draw_button(4*width/7, height-30);
    stack_button.draw_button(5*width/7, height-30);
    rose_button.draw_button(6*width/7, height-30);
    
}

public void buttons_set() {
    line_button = new Button();
    line_button.add_state("Line Graph", 100, 20, width/7, height-30, color(100, 100, 100));
    line_button.add_state("Line Graph", 100, 20, width/7, height-30, color(200, 200, 255));
    line_button.update();
    
    bar_button = new Button();
    bar_button.add_state("Bar Chart", 100, 20, 2*width/7, height-30, color(100, 100, 100));
    bar_button.add_state("Bar Chart", 100, 20, 2*width/7, height-30, color(200, 200, 255));
     
    pie_button = new Button();
    pie_button.add_state("Pie Chart", 100, 20, 3*width/7, height-30, color(100, 100, 100));
    pie_button.add_state("Pie Chart", 100, 20, 3*width/7, height-30, color(200, 200, 255));
    
    triver_button = new Button();
    triver_button.add_state("Theme River", 100, 20, 4*width/7, height-30, color(100, 100, 100));
    triver_button.add_state("Theme River", 100, 20, 4*width/7, height-30, color(200, 200, 255));
    
    stack_button = new Button();
    stack_button.add_state("Stacked Bar", 100, 20, 5*width/7, height-30, color(100, 100, 100));
    stack_button.add_state("Stacked Bar", 100, 20, 5*width/7, height-30, color(200, 200, 255));
    
    rose_button = new Button();
    rose_button.add_state("Rose Chart", 100, 20, 6*width/7, height-30, color(100, 100, 100));
    rose_button.add_state("Rose Chart", 100, 20, 6*width/7, height-30, color(200, 200, 255));
}

public void check_button() {
    boolean clicked;
    
    clicked = line_button.intersect(mouseX, mouseY);
    if (clicked == true) {
        next_chart = "Line Graph";
        //curr_chart = "Line Graph";
        bar_button.set_default();
        pie_button.set_default();
        triver_button.set_default();
        stack_button.set_default();
        rose_button.set_default();
    } else {
        clicked = bar_button.intersect(mouseX, mouseY);
        if (clicked == true) {
            next_chart = "Bar Chart";
            line_button.set_default();
            pie_button.set_default();
            triver_button.set_default();
            stack_button.set_default();
            rose_button.set_default();
        } else {
            clicked = pie_button.intersect(mouseX, mouseY);
            if (clicked == true) {
                  next_chart = "Pie Chart";
                  line_button.set_default();
                  bar_button.set_default();
                  triver_button.set_default();
                  stack_button.set_default();
                  rose_button.set_default();
            } else {
                  clicked = triver_button.intersect(mouseX, mouseY);
                  if (clicked == true) {
                      next_chart = "Theme River";
                      line_button.set_default();
                      bar_button.set_default();
                      pie_button.set_default();
                      stack_button.set_default();
                      rose_button.set_default();
                  } else {
                      clicked = stack_button.intersect(mouseX, mouseY);
                      if (clicked == true) {
                          next_chart = "Stacked Bar";
                          line_button.set_default();
                          bar_button.set_default();
                          pie_button.set_default();
                          triver_button.set_default();
                          rose_button.set_default();
                      } else {
                          clicked = rose_button.intersect(mouseX, mouseY);
                          if (clicked == true) {
                              next_chart = "Rose Chart";
                              line_button.set_default();
                              bar_button.set_default();
                              triver_button.set_default();
                              stack_button.set_default();
                              pie_button.set_default();
                          }
                      }
                  }
            }
        }
    } 
}
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
  int axes_color;
  
  //variables for transition
  int phase;
  float[] dum_y;
  float dum_width; //width correlates to xspacing/2, 
  float[] dum_heights;
  int dum_color;
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
  
  public void draw_graph() {
    make_canvas(); 
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    get_y_coords();
    draw_bars(x_spacing/2, heights);
  }
    
  public void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 120;
    canvas_x1 = 60;
    canvas_x2 = width - 60;
    
    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  public void draw_axes(float x_x, float x_y, float y_x, float y_y){
    fill(255, 255, 255);
    line(canvas_x1, canvas_y1, y_x, y_y);  //y axis
    line(canvas_x1, canvas_y2, x_x, x_y);  //x axis
  }
  
  public void draw_axes_labels(int c) {    
    //Draw y axis
    num_intervals = PApplet.parseInt((y_max / interval) + 1);
    shown_intervals = num_intervals/10;
    for (int i = 0; i <= num_intervals; i += 1) {
        float pos_y = canvas_y2 - (i * (canvas_h/num_intervals));        
        float pos_x = canvas_x1 - 15;
        
        if (shown_intervals == 0) {
          fill(c);
          textSize(10);
          text(PApplet.parseInt(i*interval), pos_x, pos_y);
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
  
  public void draw_axes_titles() {
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
  
  public void get_y_coords() {
      y_coords = new float[0];
      heights = new float[0];
      float max_height = num_intervals*interval;
        
      for (int i = 0; i < data.name.length; i++) {
          float ratio = data.values[0][i]/max_height;
          y_coords = append(y_coords, (PApplet.parseFloat(canvas_h)-(PApplet.parseFloat(canvas_h)*ratio))+canvas_y1);
          heights = append(heights, canvas_y2 - ((PApplet.parseFloat(canvas_h)-(PApplet.parseFloat(canvas_h)*ratio))+canvas_y1));
      }
    
  }
  
  public void draw_bars(float w, float[] hs) {
        for (int i = 0; i < data.name.length; i++) {
              float gray = map(i, 0, data.values[0].length, 0, 255);
              fill(150, gray, 150);
              rect(x_coords[i]-(w/4), y_coords[i], w, hs[i]);   
        }
  }
  
  public boolean line_to_bar() {  
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
  
  public int set_ltob_dummy() {
    dum_y = new float[num_points];
    dum_heights = new float[num_points];
    
    for (int i = 0; i < num_points; i++) {
      dum_y[i] = 0;
      dum_heights[i] = 0;
    }
   
    dum_width = 0;
    return 1;
  }
  
  public int expand_point() {
    dum_width = lerp(dum_width, (x_spacing/2), .05f);
    for (int i = 0; i<num_points; i++) {
       dum_heights[i] = 1; 
    }
    
    if(dum_width > x_spacing/2 - .1f) {
        return 1;
    } else {
        return 0;
    }
  }
  
  public int fill_bar() {
    //println(dum_y);
    for(int i = 0; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], canvas_y2 - y_coords[i], .1f);
      dum_heights[i] = dum_y[i];
    }
    
    boolean all_same = true;
    for(int i = 0; i < num_points; i++) {
      if(PApplet.parseInt(dum_y[i]) != PApplet.parseInt(canvas_y2 - y_coords[i])) {
           all_same = false;
      }
    }
    
    if(all_same) {
      return 1;
    } else {
      return 0;
    }
  }
  
  public boolean bar_to_line() {  
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
  
  public boolean bar_to_pie() {  
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
  
 public int set_btol_dummy() {
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
  
 public int shrink_bar() {
    for(int i = 0; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], 1, .1f);
      dum_heights[i] = lerp(dum_heights[i], 1, .1f);
    }
    
    boolean all_same = true;
    for(int i = 0; i < num_points; i++) {
      if(dum_y[i] > 1.1f) {
           all_same = false;
      }
    }
    
    if(all_same) {
      return 1;
    } else {
      return 0;
    }
 }
 
 public int shrink_point() {
   dum_width = lerp(dum_width, 0, .05f);
    if(dum_width < .1f) {
        return 1;
    } else {
        return 0;
    }
 }
 
 public boolean pie_to_bar() {
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
 
 public int set_ptob_dummy() {
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
 
 public int expand_axes() {
      dum_x_x = lerp(dum_x_x, canvas_x2, .05f);
      dum_y_y = lerp(dum_y_y, canvas_y2, .05f);
      
      if (PApplet.parseInt(dum_x_x) + 1 >= PApplet.parseInt(canvas_x2)) {
          return 1;
      } else {
          return 0;
      }
  }
  
  public int shrink_axes() {
      dum_x_x = lerp(dum_x_x, 0, .05f);
      dum_y_y = lerp(dum_y_y, 0, .05f);
      
      if (PApplet.parseInt(dum_x_x) - PApplet.parseInt(canvas_x1) < 1) {
          return 1;
      } else {
          return 0;
      }
  }
  
  public int fade_in_labels() {
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
  
  public int fade_out_labels() {
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
  
  public float get_w() { return (((width - 120)/data.name.length)/2); }
}  
  
class Button {
  Button_State[] states;
  boolean isect;
  int curr_state;

  Button() {
    isect = false;
    curr_state = 0;
    states = new Button_State[0];
  }
  
  public void draw_button(int x, int y) {
     states[curr_state].pos_x = x - (states[curr_state].w/2);
     states[curr_state].pos_y = y - (states[curr_state].h/2);
    
     int pos_x = states[curr_state].pos_x;
     int pos_y = states[curr_state].pos_y;
     int w = states[curr_state].w;
     int h = states[curr_state].h;
     String text = states[curr_state].text;
     int c = states[curr_state].col;
    
     fill(c);
     rect(pos_x, pos_y, w, h);
     textSize(10);
     fill(0,0,0);
     textAlign(CENTER, CENTER);
     text(text, pos_x + (w/2), pos_y + (h/2));
  }
  
  public void add_state(String T, int wt, int ht, int x, int y, int c) {
     Button_State new_state = new Button_State(T, c, wt, ht, x, y);
     states = (Button_State[])append(states, new_state);
  }
  
  public void update() {
    curr_state = 1;
  }
  
  public void set_default() {
    curr_state = 0; 
  }
  
  public boolean intersect (int mousex, int mousey) {
       int pos_x = states[curr_state].pos_x;
       int pos_y = states[curr_state].pos_y;
       int w = states[curr_state].w;
       int h = states[curr_state].h;
       
       if (mousex < (pos_x + w) && mousex > pos_x) {
           if (mousey < (pos_y + h) && mousey > pos_y) {
             update();
             return true;
           }
       }
       
       return false;
   }
   
   public int getState() { return curr_state; }
   
}
class Button_State {
   String text;
   int col;
   int w, h;
   int pos_x, pos_y;
  
   Button_State(String t, int c, int wt, int ht, int x, int y) {
      text = t;
      col = c;
      w = wt;
      h = ht;
      pos_x = x;
      pos_y = y; 
   }
   
   public void setText(String t) { text = t; }
   public void setColor(int c) { col = c; }
   public void setDim(int wt, int ht) { 
     w = wt;
     h = ht;
   }
   public void setPos(int x, int y) {
     pos_x = x;
     pos_y = y;
   }
   
   public float getHeight () { return h; }
   public float getWidth () { return w; }
   public float getPosX () { return pos_x; }
   public float getPosY () { return pos_y; }
   
}
class Data { 
   String[] header;
   int num_cols;
   String[] name;
   float[][] values;
   float[] row_totals;

  
   //Modularity: Could've taken in delimeters
   public void parse(String file){
      String[] lines = loadStrings(file);
      String[] split_line;
      
      readHeader(lines[0]);
      num_cols = header.length - 1;
      
      name = new String[lines.length-1];
      values = new float[num_cols][lines.length-1];
      row_totals = new float[lines.length-1];
      
      for (int i = 1; i < lines.length; i++) {
        split_line = splitTokens(lines[i], ",");
        name[i-1] = split_line[0];
        for (int j = 0; j < num_cols; j++) {
          values[j][i-1] = PApplet.parseFloat(split_line[j+1]);
          row_totals[i-1] += values[j][i-1];
        }   
      }
      /*
      print("Names:\n");
      printArray(name);
      print('\n');
      print("Values:\n");
      for(int i = 0; i < name.length; i++) {
        printArray(row_totals[i]);
        //printArray(values[j]);
      }
      */
   }
   
   public void readHeader(String line1) {
      header = new String[8];
      
      //given CSV has header delimited by ',' & ' '
      header = splitTokens(line1, ",");
      /*print("Headers: \n");
      printArray(header);
      print('\n');*/
   }
  
}
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
  int axes_color;

  //variables for transition
  int phase;
  float[] dum_x;
  float[] dum_y;
  float dum_radius;
  float dum_y_x, dum_y_y;
  float dum_x_x, dum_x_y;
  int dum_color;

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

  public void draw_graph() {
    make_canvas(); 
    calc_y_interval();
    draw_axes(canvas_x2, canvas_y2, canvas_x1, canvas_y2);
    draw_axes_labels(axes_color);
    draw_axes_titles();
    draw_line(x_coords, y_coords, x_coords, y_coords);
    draw_points(radius);
  }

  public void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 120;
    canvas_x1 = 60;
    canvas_x2 = width - 60;

    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  public void calc_y_interval() {
    num_intervals = PApplet.parseInt((y_max / y_interval) + 1);
    shown_intervals = num_intervals/10;
  }

  public void draw_axes(float x_x, float x_y, float y_x, float y_y) {
    fill(255, 255, 255);
    line(canvas_x1, canvas_y1, y_x, y_y); // y axis
    line(canvas_x1, canvas_y2, x_x, x_y); // x axis
  }

  public void draw_axes_labels(int c) {    
    //Draw y axis
    for (int i = 0; i <= num_intervals; i += 1) {
      float pos_y = canvas_y2 - (i * (canvas_h/num_intervals));
      float pos_x = canvas_x1 - 15;

      if (shown_intervals == 0) {
        fill(c);
        textSize(10);
        text(PApplet.parseInt(i*y_interval), pos_x, pos_y);
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
  
  public void update_x() {
      x_coords = new float[0];
      float spacing = canvas_w/num_points;
      for (int i = 0; i < num_points; i += 1) {
        float pos_x = (i*spacing) + (spacing/2) + canvas_x1;
        x_coords = append(x_coords, pos_x + 10); 
      }
  }

  public void draw_axes_titles() {
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

  public void draw_points(float r) {
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
  
  public void update_y() {
      y_coords = new float[0];
      float max_height = num_intervals*y_interval;

      for (int i = 0; i < data.name.length; i++) {
        float ratio = data.values[0][i]/max_height;
        y_coords = append(y_coords, (PApplet.parseFloat(canvas_h)-(PApplet.parseFloat(canvas_h)*ratio))+canvas_y1);
      }
  }

  public void draw_line(float[] x1, float[] y1, float[] x2, float[] y2) {
    for (int i = 0; i < (data.name.length - 1); i++) {
      line(x1[i], y1[i], x2[i+1], y2[i+1]);
    }
  }

  public void update() {
    make_canvas();
    calc_y_interval();
    update_x();
    update_y();
  }


  public boolean line_to_bar() {    
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

  public int set_ltob_dummy() {
    dum_y = new float[num_points];
    dum_x = new float[num_points];
    dum_radius = radius;

    for (int i = 0; i < num_points; i++) {
      dum_y[i] = y_coords[i];
      dum_x[i] = x_coords[i];
    }
    return 1;
  }

  public int shrink_lines() {
    for (int i = 1; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], y_coords[i-1], .1f);
      dum_x[i] = lerp(dum_x[i], x_coords[i-1], .1f);
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

  public int shrink_points() {
    dum_radius = lerp(dum_radius, 1, .05f);
    if (dum_radius < 1.2f) {
      return 1;
    } else {
      return 0;
    }
  }

  public boolean bar_to_line() {
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

  public int set_btol_dummy() {
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
  
  public int set_ptol_dummy() {
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

  public int expand_points() {
    dum_radius = lerp(dum_radius, radius, .05f);
    if (dum_radius > radius - .1f) {
      return 1;
    } else {
      return 0;
    }
  }

  public int expand_lines() {
    for (int i = 0; i < num_points; i++) {
      dum_y[i] = lerp(dum_y[i], y_coords[i], .1f);
      dum_x[i] = lerp(dum_x[i], x_coords[i], .1f);
    }

    boolean all_same = true;
    for (int i = 0; i < num_points; i++) {
      if (dum_y[i] < y_coords[i]-.2f) {
        all_same = false;
      } else if (dum_x[i] < x_coords[i]-.2f) {
        all_same = false;
      }
    }

    if (all_same) {
      return 1;
    } else {
      return 0;
    }
  }

  public void point_intersect(int mousex, int mousey) {
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

  public boolean pie_to_line() {
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
  
  public int fade_in_labels() {
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
  
  public int fade_out_labels() {
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
  
  public int expand_axes() {
      dum_x_x = lerp(dum_x_x, canvas_x2, .05f);
      dum_y_y = lerp(dum_y_y, canvas_y2, .05f);
      
      if (PApplet.parseInt(dum_x_x) + 1 >= PApplet.parseInt(canvas_x2)) {
          return 1;
      } else {
          return 0;
      }
  }
  
  public int shrink_axes() {
      dum_x_x = lerp(dum_x_x, canvas_x1, .05f);
      dum_y_y = lerp(dum_y_y, canvas_y1, .05f);
      
      if (PApplet.parseInt(dum_x_x) + 1 >= PApplet.parseInt(canvas_x2)) {
          return 1;
      } else {
          return 0;
      }
  }
  
  public boolean line_to_pie() {
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
  
  public int set_ltop_dummy() {
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
  
  public boolean line_to_triver() {
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

public boolean triver_to_line() {
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

  public float[] get_y() { return y_coords; }
  public float[] get_x() { return x_coords; }
}

class Pie_Chart {
  boolean visible;  
  Data data;
  String x_axis;
  String y_axis;
  float y_max;
  int num_points;
  int canvas_x1, canvas_x2;
  int canvas_y1, canvas_y2;
  int canvas_w, canvas_h;
  int isect;
  float[] angles;
  
  //variables matt made global
  float diameter; //set during draw function
  int text_color;  //(200, 150, 200)
  
  //variables for transition
  int phase;
  int dum_text_color;
  float dum_dia;
  float dum_dia_target;
  float[] dum_angles;
  float[] dum_last_ang;
  float[] dum_last_ang_corr; //ugly patch for re-rotating wedges
  float[] spread_loc;
  float[] dum_height;

  Pie_Chart(Data parsed) {
    phase = 0;
    data = parsed;
    y_max = max(data.values[0]);
    num_points = data.name.length;
    isect = -1;
    text_color = color(200, 150, 200);
  }

  public void draw_graph() {
    make_canvas(); 
    find_angles();
    draw_chart();
  }

  public void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 90;
    canvas_x1 = 60;
    canvas_x2 = width - 60;

    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }

  public void find_angles() {
    float total = 0;
    angles = new float[0];
    for (int i = 0; i < data.name.length; i++) {
      total += data.values[0][i];
    }
    for (int k = 0; k < data.name.length; k++) {
      float angle = PApplet.parseFloat(360) * data.values[0][k] / total;
      angles = append(angles, angle);
    }
  }

  public void draw_chart() {
      find_diameter();
  
        //make_chart(text color,     wedge locations, wedge rotation)
        //make_chart(color text_c,   bool spreading,  bool rotating)
      if(phase == 0) {          //normal draw
          make_chart(text_color, false, false, false, false);
      } else if (phase == 1) {  //fading text color out
          make_chart(dum_text_color, false, false, false, false);
      } else if (phase == 2) {  //shrinking graph
          make_chart(255, true, false, false, false);
      } else if (phase == 3) {  //spreading wedges out
          make_chart(255, true, true, false, false);
      } else if (phase == 4) {  //phase == 4, turn wedges up
          make_chart(255, true, true, true, false);
      } else {                  //phase == 5, collapse wedges
          make_chart(255, true, true, true, true);
      }
  }
  
  public void draw_chart_rev() {
    find_diameter();
  
        //make_chart(text color,     wedge locations, wedge rotation)
        //make_chart(color text_c,   bool spreading,  bool rotating)
      if((phase == 0) || (phase == 1)) { //just coming out of bar & initialize
          //print("Phase is zero, calling make\n");
          make_chart(255, true, true, true, true);
      } else if (phase == 2) {  //expand wedges
          //print("Phase is one, calling make\n");
          make_chart(255, true, true, true, true);
      } else if (phase == 3) {  //wedges rotate back home
          //print("Phase is two, calling make\n");
          make_chart(255, true, true, true, false);
      } else if (phase == 4) {  //wedges reconvene
          //print("Phase is three, calling make\n");
          make_chart(255, true, true, false, false);
      } else if (phase == 5) {  //graph expands
          make_chart(255, true, false, false, false);
      } else {                  //fade text back in
          make_chart(dum_text_color, false, false, false, false);
      }
  }


  public void make_chart(int text_c, boolean shrink, boolean spread, boolean rotate, boolean collapse) {
      float lastAngle = 0;
      
      for (int i = 0; i < data.values[0].length; i++) {
          float gray = map(i, 0, data.values[0].length, 0, 255);
          fill(150, gray, 150);
         
          if(!shrink && !spread && !rotate && !collapse) {
              arc(width/2, height/2, diameter, diameter, lastAngle, lastAngle + radians(angles[i]), PIE);
              draw_words(text_c, lastAngle, i);
          } else if (shrink && !spread && !rotate && !collapse) {
              arc(width/2, height/2, dum_dia, dum_dia, lastAngle, lastAngle + radians(angles[i]), PIE);
          } else if (shrink && spread && !rotate && !collapse) {
              arc(spread_loc[i], dum_height[i], dum_dia, dum_dia, lastAngle, lastAngle + radians(angles[i]), PIE);
          } else if (shrink && spread && rotate && !collapse) {
              arc(spread_loc[i], dum_height[i], dum_dia, dum_dia, dum_last_ang[i], dum_last_ang[i] + radians(angles[i]), PIE);
          } else {//(shrink && spread && rotate && collapse)
              arc(spread_loc[i], dum_height[i], dum_dia, dum_dia, dum_last_ang[i], radians(dum_angles[i]), PIE);
              //print("This one, right?\n");
              //print(spread_loc[i], ", ", dum_height[i], ", ", dum_dia, ", ", dum_last_ang[i], ", ", dum_angles[i], "\n");
          }
          
          lastAngle += radians(angles[i]);
      }
  }
  
  public void draw_words(int c, float lastAngle, int i) {
      //translate
      translate(width/2, height/2);
      rotate(lastAngle + radians(angles[i]/2));
      translate(diameter/2 + 10, 0);

      //print words
      fill(c);
      textSize(15);
      textAlign(BASELINE);
      String label = data.name[i] + ", " + str(data.values[0][i]);
      text(label, 0, 0); 

      //un-translate
      translate(-diameter/2 - 10, 0);
      rotate(-lastAngle - radians(angles[i]/2));
      translate(-width/2, -height/2);
  }
  
  public void find_diameter() {
    if (width > height) {
      diameter = height/2;
    } else {
      diameter = width/2;
    }
  }
   
   public boolean pie_to_bar(float[] y_coords, float[] x_coords, float bar_w) {
     if (phase == 0) {              //initialize
         phase += set_ptob_dummy();
     } else if (phase == 1) {       //white out words
         phase += change_text_col();
     } else if (phase == 2) {       //shrink graph
         phase += shrink_graph();
     } else if (phase == 3) {       //spread out wedges
         phase += spread_wedges(y_coords, x_coords, bar_w);  //put in a phase that blends 3 and 4? returns 1 when 3 returns 1
     } else if (phase == 4) {       //rotate wedges
         phase += rotate_wedges();
     } else if (phase == 5) {
         phase += shrink_wedges(bar_w); //make them skinnier
         //phase += 1;
     } else if (phase == 6) {
         phase += collapse_wedges();  //fold them into lines
     } else {
       phase = 0;
       return true;
     }

     make_canvas(); 
     find_angles();
     draw_chart();
     
     return false;
   }
   
   public boolean bar_to_pie(float[] y_coords, float[] x_coords, float bar_w) {
     if (phase == 0) {              //initialize
         phase += set_btop_dummy(y_coords, x_coords, bar_w);
     } else if (phase == 1) {       //pull line out
         phase += grow_wedges(bar_w * 2);
     } else if (phase == 2) {       //expand into wedge
         phase += inflate_wedges();
     } else if (phase == 3) {       //rotate to orientation
         phase += unrotate_wedges();
     } else if (phase == 4) {       //bring back into chart
         phase += condense_wedges();
     } else if (phase == 5) {
         phase += expand_graph();   //make chart big again
     } else if (phase == 6) {
         phase += colorize_text();  //print words
     } else {
       make_canvas(); 
       find_angles();
       draw_chart_rev();
       phase = 0;
       return false;
     }

     make_canvas(); 
     find_angles();
     draw_chart_rev();
     
     return true;
   }
   
   public boolean pie_to_line(float[] y_coords, float[] x_coords) {
     if (phase == 0) {              //initialize
         phase += set_ptol_dummy();
     } else if (phase == 1) {       //white out words
         phase += change_text_col();
     } else if (phase == 2) {
         phase += 1; //skip phase
     } else if (phase == 3) {
         phase += 1; //skip phase
     } else if (phase == 4) {
         phase += spread_to_line(y_coords, x_coords);
     } else {
       make_canvas(); 
       find_angles();
       draw_chart();
       phase = 0;
       return true;
     }

     make_canvas(); 
     find_angles();
     draw_chart();
     
     return false;
   }
   
   public int set_ptol_dummy() {
       dum_text_color = text_color;
       dum_dia = diameter;
       dum_dia_target = 150;
       dum_angles = new float[data.values[0].length];
       dum_last_ang = new float[data.values[0].length];
       spread_loc = new float[data.values[0].length];
       dum_height = new float[data.values[0].length];
       float ang_trak = 0;
       
       for(int i = 0; i < data.values[0].length; i++) {
           dum_angles[i] = angles[i];
           dum_last_ang[i] = ang_trak;
           spread_loc[i] = width/2;
           dum_height[i] = height/2;
           
           ang_trak += radians(dum_angles[i]);
       }
     
       return 1;
   }
   
   public int set_ptob_dummy() {
       dum_text_color = text_color;
       dum_dia = diameter;
       dum_dia_target = 150;
       dum_angles = new float[data.values[0].length];
       dum_last_ang = new float[data.values[0].length];
       spread_loc = new float[data.values[0].length];
       dum_height = new float[data.values[0].length];
       float ang_trak = 0;
       
       for(int i = 0; i < data.values[0].length; i++) {
           dum_angles[i] = angles[i];
           dum_last_ang[i] = ang_trak;
           spread_loc[i] = width/2;
           dum_height[i] = height/2;
           
           ang_trak += radians(dum_angles[i]);
       }
     
       return 1;
   }
   
   public int set_btop_dummy(float[] y_coords, float[] x_coords, float w) {
       find_angles();
       dum_text_color = color(255, 255, 255);
       dum_dia = 1;
       dum_dia_target = 150;
       dum_angles = new float[data.values[0].length];
       dum_last_ang = new float[data.values[0].length];
       dum_last_ang_corr = new float[data.values[0].length];
       spread_loc = new float[data.values[0].length];
       dum_height = new float[data.values[0].length];
       float ang_trak = 0; 
       
       for(int i = 0; i < data.values[0].length; i++) {
           dum_angles[i] = 0;
           dum_last_ang[i] = 0;
           dum_last_ang_corr[i] = ang_trak;
           spread_loc[i] = x_coords[i] - (w/4);
           dum_height[i] = y_coords[i];
           ang_trak += radians(angles[i]);
       }
       
       grow_wedges(w);
       return 1;
   }
   
   public int change_text_col() {
     float tempR = red(dum_text_color);
     float tempG = green(dum_text_color);
     float tempB = blue(dum_text_color);
     
     if(tempR < 255) {tempR += 5;}
     if(tempG < 255) {tempG += 5;}
     if(tempB < 255) {tempB += 5;}
     
     dum_text_color = color(tempR, tempG, tempB);
     
     if(tempR == 255 && tempG == 255 && tempB == 255) {
       return 1;
     } else {
       return 0;
     }
   }
   
   public int colorize_text() {
     float tempR = red(dum_text_color);
     float tempG = green(dum_text_color);
     float tempB = blue(dum_text_color);
     
     if(tempR > 200) {tempR -= 5;}
     if(tempG > 150) {tempG -= 5;}
     if(tempB > 200) {tempB -= 5;}
     
     dum_text_color = color(tempR, tempG, tempB);

     if(tempR == 200 && tempG == 150 && tempB == 200) {
       return 1;
     } else {
       return 0;
     }
   }
   
   public int shrink_graph() {
       dum_dia = lerp(dum_dia, 20, .05f);
       
       if(dum_dia < dum_dia_target + .1f) {
         return 1;
       } else {
         return 0;
       }
   }
   
   public int expand_graph() {
       dum_dia = lerp(dum_dia, diameter, .05f);
       
       if (dum_dia > diameter - .1f) {
         return 1;
       } else {
         return 0;
       }
   }
   
   public int spread_wedges(float[] y_coords, float[] x_coords, float bar_w) {
     for (int i = 0; i < spread_loc.length; i++) {
         spread_loc[i] = lerp(spread_loc[i], x_coords[i]-(bar_w/4), .1f);
         dum_height[i] = lerp(dum_height[i], y_coords[i], .05f);
         angles[i] = lerp(angles[i], 0, .05f);
     }  
      
     for (int k = 0; k < dum_height.length; k++) {
         if (PApplet.parseInt(dum_height[k]) != PApplet.parseInt(y_coords[k])) {
              return 0; 
         }
      }
      return 1;
   }
   
   public int condense_wedges() {
     int count = 0;
     
     for (int i = 0; i < spread_loc.length; i++) {
         spread_loc[i] = lerp(spread_loc[i], width/2, .1f);
         dum_height[i] = lerp(dum_height[i], height/2, .05f);
         //angles[i] = lerp(angles[i], 0, .05);
         if(! (spread_loc[i] > width/2 - .1f && spread_loc[i] < width/2 + .1f)) {
             count++;
         }
     }  
      
     if (count > 0) {
       return 0;
     } else {
       return 1;
     }
   }
   
   public int spread_to_line(float[] y_coords, float[] x_coords) {
     dum_dia = lerp(dum_dia, 1, .05f); 
     
      for (int i = 0; i < dum_height.length; i++) {
         dum_height[i] = lerp(dum_height[i], y_coords[i], .05f);
         spread_loc[i] = lerp(spread_loc[i], x_coords[i], .05f);
         angles[i] = lerp(angles[i], 0, .05f);
      }
   
      for (int k = 0; k < dum_height.length; k++) {
         if (PApplet.parseInt(dum_height[k]) != PApplet.parseInt(y_coords[k])) {
              return 0; 
         }
      }
      return 1;
   }
   
   public int rotate_wedges() {
       //dum_dia = lerp(dum_dia, 1, .02);
       int count = 0;
       for (int i = 0; i < dum_last_ang.length; i++) {
           dum_last_ang[i] = lerp(dum_last_ang[i], 0, .1f);
           
           if (!((dum_last_ang[i] > ((0) - .01f)) && (dum_last_ang[i] < ((0) + .01f)))) {
               count++;
           }
       }
       
       if(count > 1) {
         return 0;
       } else {
         return 1;
       }
   }
   
   public int unrotate_wedges() {
       int count = 0;
       for (int i = 0; i < dum_last_ang.length; i++) {
           dum_last_ang[i] = lerp(dum_last_ang[i], dum_last_ang_corr[i], .1f);
           
           if(!(dum_last_ang[i] > dum_last_ang_corr[i] - .1f)) {
               count++;
           }
       }
       
       if (count > 0) {
         return 0;
       } else {
         return 1;
       }
   }
   
   public int collapse_wedges() {
       int count = 0;
       for(int i = 0; i < dum_angles.length; i++) {
           dum_angles[i] = lerp(dum_angles[i], 0, .05f);
           if(dum_angles[i] > 2) {
               count++;
           }
       }
           
       if(count > 0) {
          return 0;
       } else {
          return 1;
       } 
   }
   
   public int inflate_wedges() {
      int count = 0;
      for(int i = 0; i < dum_angles.length; i++) {
         //print("Dum angle: ", dum_angles[i], " angle: ", angles[i], "\n");
         dum_angles[i] = lerp(dum_angles[i], angles[i], .05f);
         if(dum_angles[i] > angles[i] - .1f) {
            count++;
         }
      }
      
      //print(count, "\n");
     
      if(count > 0) {
        return 1;
      } else {
        return 0;
      } 
   }
   
   public int shrink_wedges(float bar_w) {
       //print("BAR WIDTH: ", bar_w, "\n");
       dum_dia = lerp(dum_dia, -4, .02f);
       
       if(dum_dia < bar_w*2) {
         return 1;
       } else {
         return 0;
       }
   }
   
   public int grow_wedges(float bar_w) {
       dum_dia = bar_w;
       return 1;
   }
   
   public boolean line_to_pie(float[] y_coords, float[] x_coords, float bar_w) {
     return bar_to_pie(y_coords, x_coords, bar_w);
   }
}

  


class Rose_Chart{
  boolean visible;  
  Data data;
  float max_val;
  int num_wedges;
  float angle;
  int canvas_x1, canvas_x2;
  int canvas_y1, canvas_y2;
  int canvas_w, canvas_h;
  float[][] radii;
  
  Rose_Chart(Data parsed) {
    //phase = 0;
    data = parsed;
    max_val = max(data.values[0]);
    num_wedges = data.name.length;
    angle = (2 * PI) / num_wedges;
  }
  
  public void draw_graph() {
    make_canvas(); 
    calc_radii();
    draw_chart();
  }

  public void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 90;
    canvas_x1 = 60;
    canvas_x2 = width - 60;

    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  
  public void calc_radii() {
      radii = new float[data.num_cols][num_wedges];
      float tot_so_far;
      
      for(int i = 0; i < num_wedges; i++) {
          tot_so_far = data.values[0][i];
          radii[0][i] = tot_so_far;
          for(int j = 1; j < data.num_cols; j++) {
              tot_so_far += data.values[j][i];
              radii[j][i] = tot_so_far;
              if (tot_so_far > max_val) {
                  max_val = tot_so_far;
              }
          }
      }  
      print_data();
  }
  
  public void print_data() {
    for(int i = 0; i < num_wedges; i++) {
      for(int j = 0; j < data.num_cols; j++) {
        print(j, " ", i, " ", radii[j][i], "\n");
      }
    }
  }
  
  public void draw_chart() {
      float curr_angle;
      int fillVal = color(255, 0, 0);
      int top_index = data.num_cols - 1;
      
      for(int i = top_index; i >= 0; i--) {
          curr_angle = 0;
          fill(fillVal);
          for(int j = 0; j < num_wedges; j++) {
              print("here ", radii[i][j], "\n");
              arc(width/2, height/2, radii[i][j], radii[i][j], curr_angle, curr_angle + angle);
              curr_angle += angle;
          }
          fillVal = color(0, 0, 255);
      }
  }

  
  
  
  
  
}
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
  
  public void draw_graph() {
    make_canvas(); 
    draw_axes();
    draw_axes_titles();
    get_max_y_coords();
    draw_bars(x_spacing/2);
  }
    
  public void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 120;
    canvas_x1 = 60;
    canvas_x2 = width - 60;
    
    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  public void draw_axes() {
    fill(255, 255, 255);
    line(canvas_x1, canvas_y2, canvas_x2, canvas_y2);
    line(canvas_x1, canvas_y1, canvas_x1, canvas_y2);
    
    //Draw y axis
    num_intervals = PApplet.parseInt((y_max / interval) + 1);
    print("num intervals is: ", num_intervals, "\n");
    shown_intervals = num_intervals/10;
    for (int i = 0; i <= num_intervals; i += 1) {
        float pos_y = canvas_y2 - (i * (canvas_h/num_intervals));        
        float pos_x = canvas_x1 - 25;
        
        if (shown_intervals == 0) {
          fill(0,0,0);
          textSize(10);
          text(PApplet.parseInt(i*interval), pos_x, pos_y);
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
  
  public void draw_axes_titles() {
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
  
  public void get_max_y_coords() {
      max_y_coords = new float[0];
      float max_height = num_intervals*interval;
        
      for (int i = 0; i < data.name.length; i++) {
          float ratio = data.row_totals[i]/max_height;
          max_y_coords = append(max_y_coords, (PApplet.parseFloat(canvas_h)-(PApplet.parseFloat(canvas_h)*ratio))+canvas_y1);
      }
    
  }
  
  public void draw_bars(float w) {
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
                 
              fill(fill_clr, 200, 200);
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
  
  public void draw_graph() {
    make_canvas(); 
    draw_axes();
    draw_axes_titles();
    get_y_coords();
    //draw_points();
    draw_triver(data.num_cols - 2, x_coords, y_coords);
  }
    
  public void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 120;
    canvas_x1 = 60;
    canvas_x2 = width - 60;
    
    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }
  
  public void draw_axes() {
    fill(255, 255, 255);
    line(canvas_x1, canvas_y2, canvas_x2, canvas_y2);
    //line(canvas_x1, canvas_y1, canvas_x1, canvas_y2);
    
    //Draw y axis labels
    num_intervals = PApplet.parseInt((y_max / y_interval) + 1);
    
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
  
  public void draw_axes_titles() {
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
  
  public void get_y_coords() {
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
  
  public void draw_triver(int lines_to_draw, float[]x, float[][]y) {
        //print("data length: ", data.name.length, "\n");
        for (int j = 0; j <= lines_to_draw; j++) {
          //float fill_clr = map(j, 0, data.num_cols, 50, 255);
          float fill_clr = map(i, 0, data.name.length, 0, 255);
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
  
  public boolean line_to_triver(float[] line_y) {
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
  
  public int set_ltot_dummy(float[] line_y) {
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
  
 public int sink_line() {
    for (int i = 0; i < data.name.length; i++) {
      dum_y[i] = lerp(dum_y[i], y_coords[i][0], .1f);
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
  
  public int incr_lines_drawn() {
    lines_drawn = lerp(lines_drawn, data.num_cols + 5, .01f);
    //print(lines_drawn, "\n");
    
    if (lines_drawn <= data.num_cols - 2) {
       return 0;
    } else {
       return 1;
    }
  }
  
   public void draw_line() {
    for (int i = 0; i < (data.name.length - 1); i++) {
      fill(000);
      line(x_coords[i], dum_y[i], x_coords[i+1], dum_y[i+1]);
    }
  }
  
  public boolean triver_to_line(float[] line_y) {
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
  
  public int set_ttol_dummy() {
    dum_y = new float[data.name.length];
    
    for (int i = 0; i < data.name.length; i++) {
      dum_y[i] = y_coords[i][0];
    }
    
    lines_drawn = data.num_cols - 2;
    return 1;
  }
  
  public int decr_lines_drawn() {
    lines_drawn = lerp(lines_drawn, -3, .01f);
    //print(lines_drawn, "\n");
    
    if (lines_drawn > 0) {
       return 0;
    } else {
       return 1;
    }
  }
  
  public int raise_line(float[] line_y) {
    for (int i = 0; i < data.name.length; i++) {
      dum_y[i] = lerp(dum_y[i], line_y[i], .05f);
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "a2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
