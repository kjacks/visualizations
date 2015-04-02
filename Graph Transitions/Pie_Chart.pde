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
  color text_color;  //(200, 150, 200)
  float avg_ang;
  
  //variables for transition
  int phase;
  color dum_text_color;
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

  void draw_graph() {
    make_canvas(); 
    find_angles();
    draw_chart();
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
    float total = 0;
    angles = new float[0];
    for (int i = 0; i < data.name.length; i++) {
      total += data.values[0][i];
    }
    for (int k = 0; k < data.name.length; k++) {
      float angle = float(360) * data.values[0][k] / total;
      angles = append(angles, angle);
    }
  }

  void draw_chart() {
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
  
  void draw_chart_r() {
      find_diameter();
  
      if(phase == 0) {          //normal draw
          make_chart(text_color, false, false, false, false);
      } else if (phase == 1) {  //fading text color out
          make_chart(dum_text_color, false, false, false, false);
      } else if (phase == 2) {  //shrinking graph
          make_chart(255, true, false, false, false);
      } else {  //smoothing wedges
          make_chart(255, true, false, true, false);
      }
  }
  
  void draw_chart_rev() {
    find_diameter();
  
        //make_chart(text color,     wedge locations, wedge rotation)
        //make_chart(color text_c,   bool spreading,  bool rotating)
      if((phase == 0) || (phase == 1)) { //just coming out of bar & initialize
          make_chart(255, true, true, true, true);
      } else if (phase == 2) {  //expand wedges
          make_chart(255, true, true, true, true);
      } else if (phase == 3) {  //wedges rotate back home
          make_chart(255, true, true, true, false);
      } else if (phase == 4) {  //wedges reconvene
          make_chart(255, true, true, false, false);
      } else if (phase == 5) {  //graph expands
          make_chart(255, true, false, false, false);
      } else {                  //fade text back in
          make_chart(dum_text_color, false, false, false, false);
      }
  }


  void make_chart(color text_c, boolean shrink, boolean spread, boolean rotate, boolean collapse) {
      float lastAngle = 0;
      
      for (int i = 0; i < data.values[0].length; i++) {
          float gray = map(i, 0, data.values[0].length, 0, 255);
          fill(150, gray, 150);
         
          if(!shrink && !spread && !rotate && !collapse) {
              arc(width/2, height/2, diameter, diameter, lastAngle, lastAngle + radians(angles[i]), PIE);
              draw_words(text_c, lastAngle, i);
          } else if (shrink && !spread && !rotate && !collapse) {
              arc(width/2, height/2, dum_dia, dum_dia, lastAngle, lastAngle + radians(angles[i]), PIE);
          } else if (shrink && !spread && rotate && !collapse) {  //special pie_to_rose mode
              arc(width/2, height/2, dum_dia, dum_dia, radians(dum_last_ang[i]), radians(dum_last_ang[i] + dum_angles[i]), PIE);
          } else if (shrink && spread && !rotate && !collapse) {
              arc(spread_loc[i], dum_height[i], dum_dia, dum_dia, lastAngle, lastAngle + radians(angles[i]), PIE);
          } else if (shrink && spread && rotate && !collapse) {
              arc(spread_loc[i], dum_height[i], dum_dia, dum_dia, dum_last_ang[i], dum_last_ang[i] + radians(angles[i]), PIE);
          } else {//(shrink && spread && rotate && collapse)
              arc(spread_loc[i], dum_height[i], dum_dia, dum_dia, dum_last_ang[i], radians(dum_angles[i]), PIE);
          }
          
          lastAngle += radians(angles[i]);
      }
  }
  
  void draw_words(color c, float lastAngle, int i) {
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
  
  void find_diameter() {
    if (width > height) {
      diameter = height/2;
    } else {
      diameter = width/2;
    }
  }
   
   boolean pie_to_bar(float[] y_coords, float[] x_coords, float bar_w) {
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
   
   boolean bar_to_pie(float[] y_coords, float[] x_coords, float bar_w) {
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
   
   boolean pie_to_line(float[] y_coords, float[] x_coords) {
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
   
   int set_ptol_dummy() {
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
   
   int set_ptob_dummy() {
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
   
   int set_btop_dummy(float[] y_coords, float[] x_coords, float w) {
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
   
   int change_text_col() {
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
   
   int colorize_text() {
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
   
   int shrink_graph() {
       dum_dia = lerp(dum_dia, 20, .05);
       
       if(dum_dia < dum_dia_target + .1) {
         return 1;
       } else {
         return 0;
       }
   }
   
   int expand_graph() {
       dum_dia = lerp(dum_dia, diameter, .05);
       
       if (dum_dia > diameter - .1) {
         return 1;
       } else {
         return 0;
       }
   }
   
   int spread_wedges(float[] y_coords, float[] x_coords, float bar_w) {
     for (int i = 0; i < spread_loc.length; i++) {
         spread_loc[i] = lerp(spread_loc[i], x_coords[i]-(bar_w/4), .1);
         dum_height[i] = lerp(dum_height[i], y_coords[i], .05);
         angles[i] = lerp(angles[i], 0, .05);
     }  
      
     for (int k = 0; k < dum_height.length; k++) {
         if (int(dum_height[k]) != int(y_coords[k])) {
              return 0; 
         }
      }
      return 1;
   }
   
   int condense_wedges() {
     int count = 0;
     
     for (int i = 0; i < spread_loc.length; i++) {
         spread_loc[i] = lerp(spread_loc[i], width/2, .1);
         dum_height[i] = lerp(dum_height[i], height/2, .05);
         //angles[i] = lerp(angles[i], 0, .05);
         if(! (spread_loc[i] > width/2 - .1 && spread_loc[i] < width/2 + .1)) {
             count++;
         }
     }  
      
     if (count > 0) {
       return 0;
     } else {
       return 1;
     }
   }
   
   int spread_to_line(float[] y_coords, float[] x_coords) {
     dum_dia = lerp(dum_dia, 1, .05); 
     
      for (int i = 0; i < dum_height.length; i++) {
         dum_height[i] = lerp(dum_height[i], y_coords[i], .05);
         spread_loc[i] = lerp(spread_loc[i], x_coords[i], .05);
         angles[i] = lerp(angles[i], 0, .05);
      }
   
      for (int k = 0; k < dum_height.length; k++) {
         if (int(dum_height[k]) != int(y_coords[k])) {
              return 0; 
         }
      }
      return 1;
   }
   
   int rotate_wedges() {
       //dum_dia = lerp(dum_dia, 1, .02);
       int count = 0;
       for (int i = 0; i < dum_last_ang.length; i++) {
           dum_last_ang[i] = lerp(dum_last_ang[i], 0, .1);
           
           if (!((dum_last_ang[i] > ((0) - .01)) && (dum_last_ang[i] < ((0) + .01)))) {
               count++;
           }
       }
       
       if(count > 1) {
         return 0;
       } else {
         return 1;
       }
   }
   
   int unrotate_wedges() {
       int count = 0;
       for (int i = 0; i < dum_last_ang.length; i++) {
           dum_last_ang[i] = lerp(dum_last_ang[i], dum_last_ang_corr[i], .1);
           
           if(!(dum_last_ang[i] > dum_last_ang_corr[i] - .1)) {
               count++;
           }
       }
       
       if (count > 0) {
         return 0;
       } else {
         return 1;
       }
   }
   
   int collapse_wedges() {
       int count = 0;
       for(int i = 0; i < dum_angles.length; i++) {
           dum_angles[i] = lerp(dum_angles[i], 0, .05);
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
   
   int inflate_wedges() {
      int count = 0;
      for(int i = 0; i < dum_angles.length; i++) {
         //print("Dum angle: ", dum_angles[i], " angle: ", angles[i], "\n");
         dum_angles[i] = lerp(dum_angles[i], angles[i], .05);
         if(dum_angles[i] > angles[i] - .1) {
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
   
   int shrink_wedges(float bar_w) {
       //print("BAR WIDTH: ", bar_w, "\n");
       dum_dia = lerp(dum_dia, -4, .02);
       
       if(dum_dia < bar_w*2) {
         return 1;
       } else {
         return 0;
       }
   }
   
   int grow_wedges(float bar_w) {
       dum_dia = bar_w;
       return 1;
   }
   
   boolean line_to_pie(float[] y_coords, float[] x_coords, float bar_w) {
     return bar_to_pie(y_coords, x_coords, bar_w);
   }
   
   boolean pie_to_rose() {
       if(phase == 0) {
           phase += set_ptor_dummy();
       } else if (phase == 1) {
           phase += change_text_col();
       } else if (phase == 2) {
           phase += shrink_graph();
       } else if (phase == 3) {
           phase += make_angles_even();
       } else {
         make_canvas(); 
         find_angles();
         draw_chart_r();
         phase = 0;
         return true;
       }
       
       make_canvas(); 
       find_angles();
       draw_chart_r();

       return false;
   }


   int set_ptor_dummy() {
       dum_text_color = text_color;
       dum_dia = diameter;
       dum_dia_target = 150;
       dum_angles = new float[data.values[0].length];
       dum_last_ang = new float[data.values[0].length];
       float ang_trak = 0;
       avg_ang = 360.0 / num_points;
       
       for(int i = 0; i < data.values[0].length; i++) {
           dum_angles[i] = angles[i];
           dum_last_ang[i] = ang_trak;
           ang_trak += angles[i];

       }
     
       return 1;
   }
   
   int make_angles_even() {
      int count = 0;
      
      for(int i = 0; i < dum_angles.length; i++) {
        // print("angle: ", dum_angles[i], " last_ang: ", dum_last_ang[i], "\n");
         dum_angles[i] = lerp(dum_angles[i], avg_ang, .1);
         dum_last_ang[i] = lerp(dum_last_ang[i], (i) * avg_ang, .1);
        
         if (!(dum_angles[i] > (avg_ang) - .1 && dum_angles[i] < (avg_ang) + .1)) {
            count++;
         }
      }
     
     if (count > 0) {
       return 0;
     } else {
       return 1;
     } 
   }
   
}
  


