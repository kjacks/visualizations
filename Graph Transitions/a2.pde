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
void setup() {
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

void draw() {
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

void mouseClicked() {
    check_button();
}

void draw_transition() {
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

void line_to_bar() {
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

void bar_to_line() {
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

void pie_to_bar() {
  if (half_complete == false) {
      half_complete = pie.pie_to_bar(line.get_y(), line.get_x(), bar.get_w());
  } else {
      half_complete = bar.pie_to_bar();
      if (half_complete == false) {
         curr_chart = "Bar Chart";
      }
  }
}

void bar_to_pie() {
  if (half_complete == false) {
      half_complete = bar.bar_to_pie();
  } else {
      half_complete = pie.bar_to_pie(line.get_y(), line.get_x(), bar.get_w());
      if (half_complete == false) {
         curr_chart = "Pie Chart";
      }
  }
}

void pie_to_line() {
  if (half_complete == false) {
      half_complete = pie.pie_to_line(line.get_y(), line.get_x());
  } else {
      half_complete = line.pie_to_line();
      if (half_complete == false) {
          curr_chart = "Line Graph";
      }
  }
}

void line_to_pie() {
  if (half_complete == false) {
      half_complete = line.line_to_pie();
  } else {
      half_complete = pie.line_to_pie(line.get_y(), line.get_x(), 50);
      if (half_complete == false) {
          curr_chart = "Pie Chart";
      }
  }
}

void line_to_triver() {
    if (half_complete == false) {
       half_complete = line.line_to_triver();
    } else {
       half_complete = triver.line_to_triver(line.y_coords);
        if (half_complete == false) {
            curr_chart = "Theme River";
        }
    }
}

void triver_to_line() {
    if (half_complete == false) {
       half_complete = triver.triver_to_line(line.y_coords);
    } else {
       half_complete = line.triver_to_line();
        if (half_complete == false) {
            curr_chart = "Line Graph";
        }
    }
}

void stack_to_bar() {
    curr_chart = "Bar Chart";
}

void bar_to_stack() {
    curr_chart = "Stacked Bar";
}

void pie_to_rose() {
    if (half_complete == false) {
      half_complete = pie.pie_to_rose();
    } else {
      half_complete = rose.pie_to_rose();
      if (half_complete == false) {
        curr_chart = "Rose Chart";
      }
    }
}

void rose_to_pie() {
    curr_chart = "Pie Chart";
}

void draw_buttons() {
    line_button.draw_button(width/7, height-30);
    bar_button.draw_button(2*width/7, height-30);
    pie_button.draw_button(3*width/7, height-30);
    triver_button.draw_button(4*width/7, height-30);
    stack_button.draw_button(5*width/7, height-30);
    rose_button.draw_button(6*width/7, height-30);
    
}

void buttons_set() {
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

void check_button() {
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
                          stack_button.set_default();
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
