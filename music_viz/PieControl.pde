class PieControl {
  final int NUM_STATEMENTS = 6;
  UserData   data;
  MusicPref[]  pie_stats;
  PieChart pie;
  int statements_x1, statements_x2;
  int statements_y1, statements_y2;
  int statement_yinterval;
  int piex1, piex2;
  int piey1, piey2;
  int clicked;
  
  PieControl(UserData d) {
    data = d;
    statements_x1 = 20;
    statements_y1 = 475;
    statements_x2 = 500;
    statements_y2 = 600;
    statement_yinterval = 20;
    clicked = 5;
    
    piex1 = 0;
    piey1 = 0;
    piex2 = width;
    piey2 = height - 100;
  }
  
  void draw_pies(Range range, String gender) {
     fill(255);
     noStroke();
     rect(0, 0, 1200, 600);

     pie_stats = data.get_pie_stats(range, gender);
     print_header();
     print_statements();
     MusicPref todraw;
     if (clicked == 5) {
       todraw = new MusicPref();
       for (int i = 0; i < NUM_STATEMENTS - 1; i++) {
          todraw.listen_own_avg += pie_stats[i].listen_own_avg;
          todraw.listen_back_avg += pie_stats[i].listen_back_avg;
       } 
       
       todraw.listen_own_avg = todraw.listen_own_avg/5;
       todraw.listen_back_avg = todraw.listen_back_avg/5;
       
     } else {
       todraw = pie_stats[clicked];
       
     }
     
     
     pie = new PieChart(todraw);
     pie.draw_graph();
  }
  
  void print_header() {
     fill(0);
     stroke(0);
     textAlign(LEFT, TOP);
     textSize(17);
     text("Click to filter by respondents' opinions towards music:", statements_x1, statements_y1 - 30);
     line(statements_x1, statements_y1 - 12, statements_x2 - 135, statements_y1 - 12 );
  }
  
  void print_statements() {
     fill(255);
     noStroke();
     //rect(statements_x1, statements_y1, statements_x2-statements_x1, statements_y2-statements_y1);
     int curr_y = statements_y1;
     stroke(0);
     textSize(10);
     textAlign(LEFT, TOP);
     for (int i = 0; i < NUM_STATEMENTS; i++) {
       if(i == clicked) {
           fill(0, 100, 255);
       } else {
           fill(0);
       }
       
       text(data.girls[0].music_statements[i], statements_x1, curr_y);
       curr_y += statement_yinterval;
     }
    
  }
  
  void check_click() {
    //print("in check click\n");
    int curr_y = statements_y1;
    if((mouseX > statements_x1) && (mouseX < statements_x2)) {
      //print("within statement area\n");
      for (int i = 0; i < NUM_STATEMENTS; i++) {
         //print("mousey is: ", mouseY, " curry is: ", curr_y, "curry + interval is: ", curr_y + statement_yinterval, "\n");
         if((mouseY >= curr_y) && (mouseY < (curr_y + statement_yinterval))) {
             //print("printing", data.girls[0].music_statements[i], "\n");
             clicked = i;
         }
         curr_y += statement_yinterval;

      }
    }
  }
  
  
}
