class PieChart {
  String x_axis;
  String y_axis;
  float y_max;
  int num_slices;
  float total_time;
  int canvas_x1, canvas_x2;
  int canvas_y1, canvas_y2;
  int canvas_w, canvas_h;
  int piex, piey;
  int slicex, slicey;
  int isect;
  float list_own_angle;
  float list_back_angle;
  float rem_angle;
  MusicPref data;
  
  //variables matt made global
  float diameter; //set during draw function
  color text_color;  //(200, 150, 200)
  float avg_ang;
  

  PieChart(MusicPref d) {
    data = d;
    num_slices = 3;
    text_color = color(200, 150, 200);
    total_time = 24;
    piex = width/5;
    piey = height/3;
    slicex = width/2 - 100;
    slicey = height/2 - 70;
  }

  void draw_graph() {
    draw_title(); 
    find_angles();
    find_diameter();
    draw_chart();
  }
  
  void draw_title() {
    fill(150, 0, 150);
    stroke(150, 0, 150);
    textAlign(CENTER);
    textSize(20);
    text("Average Time Per Day Spent Listening to Music", piex, 42);
    
  }

  void make_canvas() {
    canvas_y1 = 40;
    canvas_y2 = height - 90;
    canvas_x1 = 60;
    canvas_x2 = width - 60;

    canvas_w = canvas_x2 - canvas_x1;
    canvas_h = canvas_y2 - canvas_y1;
  }

  void find_angles() {
    list_own_angle = float(360) * data.listen_own_avg / total_time;
    list_back_angle = float(360) * data.listen_back_avg / total_time;
    rem_angle = float(360) - list_own_angle - list_back_angle;
  }

  

  void draw_chart() {
      
      float lastAngle = 0;
         noStroke();
         //float gray = map(i, 0, data.values[0].length, 0, 255);
         fill(200, 100, 200);
         arc(piex, piey, diameter, diameter, 0, 0 + radians(list_own_angle), PIE);
         textSize(13);
         text("Listening to own music", slicex + diameter/2, slicey - 10);
         arc(slicex, slicey, diameter*3, diameter*3, 0, 0 + radians(list_own_angle), PIE);
         draw_vals(lastAngle, radians(list_own_angle), data.listen_own_avg);
         lastAngle += radians(list_own_angle);
         fill(150, 0, 150);
         arc(piex, piey, diameter, diameter, lastAngle, lastAngle + radians(list_back_angle), PIE);
         arc(slicex, slicey, diameter*3, diameter*3, lastAngle, lastAngle + radians(list_back_angle), PIE);
         draw_words(lastAngle, radians(list_back_angle), "Listening to background music");
         draw_vals(lastAngle, radians(list_back_angle), data.listen_back_avg);
         lastAngle += radians(list_back_angle);
         fill(220, 220, 255);
         arc(piex, piey, diameter, diameter, lastAngle, lastAngle + radians(rem_angle), PIE);
         //draw_words(lastAngle, radians(rem_angle));
          
  }
  
  void draw_words(float lastAngle, float ownAngle, String message) {
      //translate
      translate(slicex, slicey);
      rotate(lastAngle + ownAngle);
      translate(diameter/3 - 17, 0);

      //print words
      textSize(13);
      textAlign(BASELINE);
      text(message, 0, 20); 

      //un-translate
      translate(-diameter/3 + 17, 0);
      rotate(-lastAngle -ownAngle);
      translate(-slicex, -slicey);
  }
  
  void draw_vals(float lastAngle, float ownAngle, float val) {
      //translate
      translate(slicex, slicey);
      rotate(lastAngle + ownAngle);
      translate(diameter*3/2 + 10, 0);

      //print words
      String v = nf(val, 1, 2);
      String message = v + " hours";
      
      textSize(12);
      textAlign(BASELINE);
      text(message, 0, 0);

      //un-translate
      translate(-diameter*3/2 - 10, 0);
      rotate(-lastAngle - ownAngle);
      translate(-slicex, -slicey);
  }

  
  void find_diameter() {
    if (width > height) {
      diameter = height/2;
    } else {
      diameter = width/2;
    }
  }
}



