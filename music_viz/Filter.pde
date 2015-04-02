class Filter {
  float x, y;
  float wid, hgt;
  
  String mes;
  
  boolean needHelp;
  int helpTimer;
  
  Slider    slider;
  Gen_Check male;
  Gen_Check female;
  
  VisLabel cloud;
  VisLabel par;
  VisLabel pie;
 
  Filter(float _x, float _y, float w, float h) {
    x = _x;
    y = _y;
    wid = w;
    hgt = h;
    
    float s_x = x + 20;
    float s_y = y + 75; 
    float s_w = wid - 400;

    slider = new Slider(x + 10, y + 25, w - 400);

    male   = new Gen_Check(wid - 420,  y + 70, 30, 10, true, "Male");
    female = new Gen_Check(x + 630,    y + 70, 45, 10, true, "Female");   
    
    cloud = new VisLabel(825, y + 15, 120, 70, "cloud1.jpg", false, "A wordcloud, showing the most common words used to describe music samples shown to the user base. Click a word to see a bar graph breakdown of how often each age used that word.");
    par   = new VisLabel(950, y + 15, 120, 70, "par1.jpg", true, "The user base was asked nineteen questions about their opinions on music and technology. Each answer was on a scale of 0 - 100. Each line on the graph corresponds to a single age.");
    pie  = new VisLabel(1075, y + 15, 120, 70, "pie.jpg", false, "The wedges in the chart represent how long, on average, the age range both actively and passively listen to music per 24 hours. An enlarged view is shown to the right.");
  } 
  
  void draw_filter(Range range) {
    fill(100);
    strokeWeight(0);
    rect(x, y, wid, hgt); 
    
    draw_prompt(range);
    slider.draw_slider(); 
    male.draw_gen();
    female.draw_gen();
    cloud.draw_label();
    par.draw_label();
    pie.draw_label();
  }
  
  void draw_prompt(Range range) {
    PFont font;
    font = loadFont("DejaVuSans-12.vlw");
    textFont(font, 12);
       
    stroke(255);
    strokeWeight(1);
    fill(100);
    rect(x + 350, y + 43, 140, 14);
    rect(x + 685, y + 57, 60, 26);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    textLeading(10);
    text("SELECT AGE RANGE", x + 420, y + 50);
    text("SELECT\nGENDER", x + 715, y + 70);
    
    font = loadFont("DejaVuSans-Bold-35.vlw");
    textFont(font, 35);
   
    if(range.curVis.equals("cloud")) {
      mes = "WordCloud";
    } else if(range.curVis.equals("par")) {
      mes = "Parallel Coordinate Graph";
    } else if(range.curVis.equals("pie")) {
      mes = "Time-breakdown Pie Chart";
    } else {
      mes = "Select Vis --->";
    }
    
    text(mes, x + 300, y + 75);
    
    
  }
  
  void help(Range range) {
    cloud.help(range);
    par.help(range);
    pie.help(range);
  }
  
  //////////////////////////////////
  void draw_helper() {

  }
  //////////////////////////////////
  
  Range get_range() {
    Range toRet = new Range();
    boolean m, f;
    
    m = male.active;
    f = female.active;
    
    toRet = slider.get_range(toRet); 
    
    if(m) {
      if(f) {
        toRet.gender = "both";
      } else {
        toRet.gender = "male";
      }
    } else {
      if(f) {
        toRet.gender = "female";
      } else {
        toRet.gender = "neither";
      }
    }
    
    if(cloud.active) {
      toRet.curVis = "cloud";
    } else if(par.active) {
      toRet.curVis = "par";
    } else if(pie.active) {
      toRet.curVis = "pie";
    } else {
      toRet.curVis = "";
    }
    
    return toRet;
  }
  
  void pressed() {
    slider.check_brackets(); 
    male.check_activate(female.active);
    female.check_activate(male.active);
    
    String visp = which();
    
    if(visp.equals("cloud")) {
      cloud.activate();
      par.deactivate();
      pie.deactivate();
    } else if(visp.equals("par")) {
      cloud.deactivate();
      par.activate();
      pie.deactivate();
    } else if(visp.equals("pie")) {
      cloud.deactivate();
      par.deactivate();
      pie.activate();
    }
  }
  
  String which() {
    if(cloud.was_pressed()) {
      return "cloud";
    } else if(par.was_pressed()) {
      return "par";
    } else if(pie.was_pressed()) {
      return "pie";
    } else {
      return "";
    }
  }

  void released() {
    slider.unactivate(); 
  }
  
}

class Range {
  int low;
  int high;
  String gender; //can be male, female, or both
  String curVis; //can be cloud, par, pie, or ""
  
  Range() {
    low = 0;
    high = 93;
    gender = "both"; 
    curVis = "";
  }
}

class Gen_Check {
  float x, y;
  float wid, hgt;
  
  String title;
  
  boolean active;
  boolean deac;
  boolean reac;
  
  boolean err;
  int err_ct;
  
  int transNum;
 
  Gen_Check(float _x, float _y, float w, float h, boolean act, String t) {
    x = _x;
    y = _y;
    wid = w;
    hgt = h;
    active = act;
    title = t;
    deac = false;
    reac = false;
    err  = false;
    err_ct = 0;
    transNum = 0;
  } 
  
  void draw_gen() {
    if(active) {
      if(reac) {
        float col = map(transNum, 0, 30, 70, 200);
        fill(col);
        transNum++;
        
        if(transNum == 30) {
          reac = false;
          transNum = 0;
        }
      } else if (err) {
        fill(200, 0, 0);
        err_ct++;
        if(err_ct == 5) {
          err_ct = 0;
          err = false;
        }
      } else {
        fill(200);
      }
    } else {
      if(deac) {
        float col = map(transNum, 0, 30, 200, 70);
        fill(col);
        transNum++;
        
        if(transNum == 30) {
          deac = false;
          transNum = 0;
        }
      } else {
        fill(70);
      }
    }
   
    
    PFont font;
    font = loadFont("DejaVuSans-20.vlw");
    textFont(font, 20);
    textAlign(CENTER, CENTER);
    textSize(25);
    text(title, x, y);
  }
  
  
  void check_activate(boolean otherAct) {
    if(mouseX > x - wid && mouseX < x + wid) {
      if (mouseY > y - hgt && mouseY < y + hgt) {
        if(active) {
          if(!otherAct) {
            err = true;        
            return;
          }
          active = false;
          deac = true;
        } else {
          active = true;
          reac = true;
        }
      }
    }
  }
}

class VisLabel {
  float x, y;
  float wid, hgt;
  PImage img;
  boolean active;
  boolean deac;
  boolean reac;
  int transNum;
  boolean needHelp;
  int helpTimer;
  String alt;
  float boxHeight;
 
  VisLabel(float _x, float _y, float w, float h, String path, boolean act, String a) {
    x = _x;
    y = _y;
    wid = w;
    hgt = h;
    img = loadImage(path);
    active = act;
    reac = false;
    deac = false;
    transNum = 0;    
    needHelp = false;
    helpTimer = 0;
    alt = a;
    boxHeight = 0;
  }
  
  void draw_label() {
    if (!active) {
      if(deac) {
        float col = map(transNum, 0, 20, 255, 100);
        tint(col);
        
        transNum++;
        if(transNum == 20) {
          transNum = 0;
          deac = false; 
        }
      } else {
        tint(100);
      } 
    } else {
      if(reac) {
        float col = map(transNum, 0, 20, 100, 255);
        tint(col);
        
        transNum++;
        if(transNum == 20) {
          transNum = 0;
          reac = false; 
        }
      } else {
        tint(255);
      }
    }

    image(img, x, y, wid, hgt);
    
    if(mouseX > x && mouseX < (x + wid)) {
      if(mouseY > y && mouseY < (y + hgt)) {
        if(helpTimer < 30) {
          helpTimer++;
        } else {
          needHelp = true;
          if(boxHeight < 200) {
            boxHeight += 20;
          }
        }
      } else {
        needHelp = false;
        helpTimer = 0;
        boxHeight = 0;
      }
    } else {
      needHelp = false;
      helpTimer = 0;
      boxHeight = 0;
    }  
  }
  
  void activate() {
    if(!active) {
      active = true;
      reac = true; 
    }
  }
  
  void deactivate() {
    if(active) {
      active = false;
      deac = true;
    }
  }
  
  void check_activate() {
    if(mouseX > x && mouseX < x + wid) {
      if(mouseY > y && mouseY < y + hgt) {
        if(active) {
          active = false;
          deac = true;
        } else {
          active = true;
          reac = true;
        }
      }
    }
  }
  
  boolean was_pressed() {
    if (mouseX > x && mouseX < x + wid) {
      if(mouseY > y && mouseY < y + hgt) {
        return true;
      }
    }
    
    return false;
  }

  void help(Range range) {
    if(needHelp && !range.curVis.equals("cloud")) {
      PFont font;
      font = loadFont("DejaVuSans-12.vlw");
      textFont(font, 12);
      textAlign(CENTER, CENTER);
      fill(200);
      strokeWeight(0);
      rect(x, y - 200 + hgt + (200 - boxHeight), wid, boxHeight);
      if(boxHeight == 200) {
        fill(0);
        text(alt, x, y - 200 + hgt, wid, boxHeight);
      } 
    }
  }
}


