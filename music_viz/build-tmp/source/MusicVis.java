import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.geom.Area; 
import java.awt.geom.Rectangle2D; 
import java.awt.Shape; 
import wordcram.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MusicVis extends PApplet {






int screenWidth = 1200;
int screenHeight = 700;

Parser   parser;
Display  toShow;
Slider   slider;
Filter   filter;
WordCram wc;
Range    range;
Range    prev_range;
boolean clicked;

//PGraphics canvas = this.createGraphics(screenWidth - 100, screenHeight - 100, P2D\\);
PImage image = createImage(1000, 650, RGB);
Shape imageShape = new ImageShaper().shape(image, 0xff000000);
ShapeBasedPlacer placer = new ShapeBasedPlacer(imageShape);

public void setup() {
  size(screenWidth, screenHeight);
  background(255);
  frameRate(60);

  parser = new Parser();
  UserData data = parser.parse("../merged.csv");
  wc = new WordCram(this);
  //wc.withCustomCanvas(this.canvas);
  toShow = new Display(wc, data);
  filter = new Filter(0, 600, 1200, 100);
  prev_range = new Range();
  prev_range.low = 0;
  prev_range.high = 93;
  clicked = false;


  /*
  if (frame != null) {
   frame.setResizable(true);
   }
   */
}


public void draw() {
  //background(255);
  filter.draw_filter();
  
  range = filter.get_range();
  if (range.low >= range.high) {
    range.high = range.low + 1;
  }
  
  toShow.get_freqs(range);
  
  if(!mousePressed) {
    if (range_changed() == true) {
      wc = new WordCram(this);
      fill(255);
      noStroke();
      rect(0, 0, 1200, 600);
    }
  }
  
  toShow.draw_graphs(wc, range);
  
  
  //print("Range: ", range.low, " to ", range.high, "\n");
  //find range from slider
  //pass range into Display's draw
  //display has range, pulls data, updates vizs
}

public boolean range_changed() {
  if((range.low == prev_range.low) && (range.high == prev_range.high) && (range.curVis.equals(prev_range.curVis))) {
      return false;
  } else {
      prev_range = range;
      return true;
  }
}

/* events */

public void mouseClicked() {
  toShow.set_click();
}

public void mousePressed() {
  filter.pressed();
}

public void mouseReleased() {
  filter.released();
}

class MusicPref {
    float   listen_own;
    int     num_listen_own;
    float   listen_own_avg;
    float   listen_back;
    int     num_listen_back;
    float   listen_back_avg;
}

class AgeGroup {
  final int NUM_QS = 20;
  final int NUM_WORDS = 82;
  final int NUM_STATEMENTS = 6;
  boolean contains_data;
  int[]   word_freqs;    //size 80, each index = same word
  float[] total_q_score; 
  int[]   num_per_q; //if performance issues, fix this first
  float   listen_own;
  int     num_listen_own;
  float   listen_back;
  int     num_listen_back;
  String[]  music_statements = {
                "Music is no longer as important as it used to be to me",
                "Music means a lot to me and is a passion of mine",
                "I like music but it does not feature heavily in my life",
                "Music has no particular interest for me",
                "Music is important to me but not necessarily more important than other hobbies or interests",
                "Display all"};
  MusicPref[]  prefs; 
  
  AgeGroup() {
     word_freqs    = new int[NUM_WORDS];
     
     total_q_score   = new float[NUM_QS];
     
     num_per_q = new int[NUM_QS];
     
     contains_data = false; //handle this differently?
     
     prefs = new MusicPref[NUM_STATEMENTS];
     
     for (int i = 0; i < NUM_STATEMENTS; i++) {
       prefs[i] = new MusicPref();
     }
     
  }
  
  public int find_statement(String statement) {
      for (int i = 0; i < NUM_STATEMENTS; i++) {
          if (statement.equals(music_statements[i])) {
              return i;
          }
      }
      
      //last stament has inconsistent spelling, so it is else case
      return 4;
  }
  
  
}
class Cloud {
  boolean active;
  
  float x_coord;
  float y_coord;
  float hgt;
  float wid; 
  
  WordCram wc;
  UserData data;
  WordBar bar;
  int freq_range;
  int prev_freq_range = 0;
  String gender = "female";
  boolean clicked;
  int clicked_index;
  int barx1, barx2;
  int bary1, bary2;
  
  String[] words = {"Uninspired","Sophisticated","Aggressive","Edgy","Sociable","Laid back","Wholesome",
    "Uplifting","Intriguing","Legendary","Free","Thoughtful","Outspoken","Serious","Good lyrics",
    "Unattractive","Confident","Old","Youthful","Boring","Current","Colourful","Stylish","Cheap",
    "Irrelevant","Heartfelt","Calm","Pioneer","Outgoing","Inspiring","Beautiful","Fun","Authentic",
    "Credible","Way out","Cool","Catchy","Sensitive","Mainstream","Superficial","Annoying","Dark",
    "Passionate","Not authentic","Good Lyrics","Background","Timeless","Depressing","Original",
    "Talented","Worldly","Distinctive","Approachable","Genius","Trendsetter","Noisy","Upbeat",
    "Relatable","Energetic","Exciting","Emotional","Nostalgic","None of these","Progressive","Sexy",
    "Over","Rebellious","Fake","Cheesy","Popular","Superstar","Relaxed","Intrusive","Unoriginal",
    "Dated","Iconic","Unapproachable","Classic","Playful","Arrogant","Warm","Soulful"};
  
  Cloud(WordCram w, UserData d) {
    wc = w;
    data = d;
    clicked = false;
    barx1 = 35;
    bary1 = 525;
    barx2 = 879;
    bary2 = 595;
  }
  
  public int[] get_freqs(Range range, String gen) {
    int[] freqs = data.get_freqs(range, gender);
    gender = gen;
    
    freq_range = max(freqs) - min(freqs);
    
    return freqs;
  }
  
  public void set_weights(WordCram w, int[] freqs) {
    wc = w;
    //wc.withColors(color(134, 56, 57), color(32, 68, 110), color(187, 5, 100));
    
    Word[] wordArray = new Word[words.length];
    for (int i = 0; i < words.length; i++) {
      wordArray[i] = new Word(words[i], freqs[i]);
      if (freqs[i] < freq_range/3) {
        wordArray[i].setProperty("value", "low");
      } else if (freqs[i] > 2*freq_range/3) {
        wordArray[i].setProperty("value", "high");
      } else {
        wordArray[i].setProperty("value", "medium");
      }
    }
    
    wc.fromWords(wordArray);
    wc.withColorer( new WordColorer() {
      public int colorFor(Word w) {
         if (w.getProperty("value") == "low") {
           return color(134, 56, 57);
         } else if (w.getProperty("value") == "medium") {
           return color(32, 68, 110);
         } else if (w.getProperty("value") == "high") {
           return color(187, 5, 100);
         }
         
         return 0;
      } 
    });
  }
  
  public void draw_cloud(Range range) {
      print(clicked, "\n");
      if (freq_range != 0) {
          wc.drawAll();
          if (wc.hasMore()) {
            print("drawing more\n");
             wc.drawNext();
          }
          prev_freq_range = freq_range;
      }
      
      if (clicked == true) {
          fill(255);
          noStroke();
          rect(barx1, bary1, barx2 - barx1, bary2 - bary1);
          print("drawing bars\n");
          draw_bars(range);
      }
      
  }
  
  public boolean freq_changed() {
    if (freq_range == prev_freq_range) {
      return false;
    } else {
      return true;
    }
  }
  
  //code below for generating bar graphs
  
  public void check_click() {
    Word clicked_w = wc.getWordAt(mouseX, mouseY);
    
    if (clicked_w == null) {
      clicked = false;
      print("no word clicked\n");
    } else {
      clicked = true;
      print(clicked_w, "\n");
      String[] split_line = splitTokens(clicked_w.toString(), " ");
      String word = split_line[0];
      clicked_index = get_word_index(word);
    }
  }
  
  public int get_word_index(String w) {
      for (int i = 0; i < words.length; i++) {
        if (w.equals(words[i])) {
          return i;
        }
      }
      clicked = false;
      return -1;
  }
  
  public void draw_bars(Range range) {
     int[] bar_stats = data.get_bar_stats(clicked_index, gender);
     bar = new WordBar(bar_stats, barx1, bary1, barx2, bary2);
     bar.draw_graph(range);
  }
}
class Display {
  //data for visualizations
  UserData data;      //contains an array of AgeGroups for m & f
  
  //list of visualizations, may be active or nah
  Cloud    cloud; 
  ParGraph par_graph;
  PieControl pies;
  /* more to be added */
  
  int[] word_freqs;

  Display(WordCram wc, UserData d) {
    data = d;
    cloud = new Cloud(wc, data);
    pies = new PieControl(data);
    par_graph = new ParGraph(data);
  }
  
  //returns true if frequencies change
  public boolean get_freqs(Range range) {
      word_freqs = cloud.get_freqs(range, range.gender);
      return cloud.freq_changed();
//      par_graph.draw_graph(0, 0, width, height-100, range, range.gender);
  }

  // pass gender from Musicvis
  public void draw_graphs(WordCram wc, Range range) {
      String gender = "both";
      
      if(range.curVis.equals("cloud")) {
        cloud.set_weights(wc, word_freqs);
        cloud.draw_cloud(range);
      } else if(range.curVis.equals("par")) {
        par_graph.draw_graph(0, 0, width, height-100, range, range.gender);
      } else if(range.curVis.equals("pie")) {
        pies.draw_pies(range, range.gender);
      } else if(range.curVis.equals("tbd2")) {
        
      }
  }
  
  public void set_click() {
      pies.check_click();
      cloud.check_click();
  }
  
 
}
class Filter {
  float x, y;
  float wid, hgt;
  
  Slider    slider;
  Gen_Check male;
  Gen_Check female;
  
  VisLabel cloud;
  VisLabel par;
  VisLabel pie;
  VisLabel tbd2;
 
  Filter(float _x, float _y, float w, float h) {
    x = _x;
    y = _y;
    wid = w;
    hgt = h;
    
    float s_x = x + 20;
    float s_y = y + 75; 
    float s_w = wid - 400;

    slider = new Slider(x + 20, y + 25, w - 400);

    male   = new Gen_Check(wid - 470, y + 72, 30, 10, true, "Male");
    female = new Gen_Check(x + 570,    y + 72, 45, 10, true, "Female");   
    
    cloud = new VisLabel(835, y + 25, 85, 50, "HistoricGoat.jpg", true);
    par   = new VisLabel(925, y + 25, 85, 50, "SadGoat.jpg", false);
    pie  = new VisLabel(1015, y + 25, 85, 50, "PattyGoat.jpg", false);
    tbd2  = new VisLabel(1105, y + 25, 85, 50, "VikingsGoat.jpg", false);
  } 
  
  public void draw_filter() {
    fill(100);
    strokeWeight(0);
    rect(x, y, wid, hgt); 
    
    draw_prompt();
    slider.draw_slider(); 
    male.draw_gen();
    female.draw_gen();
    cloud.draw_label();
    par.draw_label();
    pie.draw_label();
    tbd2.draw_label();
  }
  
  public void draw_prompt() {
    PFont font;
    font = loadFont("DejaVuSans-20.vlw");
    textFont(font, 20);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);
    textLeading(18);
    text("SELECT AGE AND\nGENDER DEMOGRAPHIC", x + 200, y + 65);
    
  }
  
  
  public Range get_range() {
    Range toRet = new Range();;
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
    } else if(tbd2.active) {
      toRet.curVis = "tbd2";
    } else {
      toRet.curVis = "";
    }
    
    return toRet;
  }
  
  public void pressed() {
    slider.check_brackets(); 
    male.check_activate();
    female.check_activate();
    
    String visp = which();
    
    if(visp.equals("cloud")) {
      cloud.activate();
      par.deactivate();
      pie.deactivate();
      tbd2.deactivate();
    } else if(visp.equals("par")) {
      cloud.deactivate();
      par.activate();
      pie.deactivate();
      tbd2.deactivate();
    } else if(visp.equals("pie")) {
      cloud.deactivate();
      par.deactivate();
      pie.activate();
      tbd2.deactivate();
    } else if(visp.equals("tbd2")) {
      cloud.deactivate();
      par.deactivate();
      pie.deactivate();
      tbd2.activate();
    }
  }
  
  public String which() {
    if(cloud.was_pressed()) {
      return "cloud";
    } else if(par.was_pressed()) {
      return "par";
    } else if(pie.was_pressed()) {
      return "pie";
    } else if(tbd2.was_pressed()) {
      return "tbd2";
    } else {
      return "";
    }
  }

  public void released() {
    slider.unactivate(); 
  }
  
}

class Range {
  int low;
  int high;
  String gender; //can be male, female, or both
  String curVis; //can be cloud, par, pie, or tbd2
}

class Gen_Check {
  float x, y;
  float wid, hgt;
  
  String title;
  
  boolean active;
  boolean deac;
  boolean reac;
  
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
    transNum = 0;
  } 
  
  public void draw_gen() {
    if(active) {
      if(reac) {
        float col = map(transNum, 0, 30, 70, 200);
        fill(col);
        transNum++;
        
        if(transNum == 30) {
          reac = false;
          transNum = 0;
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
    textSize(12);
    text("Show", x, y - 18);
  }
  
  
  public void check_activate() {
    if(mouseX > x - wid && mouseX < x + wid) {
      if (mouseY > y - hgt && mouseY < y + hgt) {
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
}

class VisLabel {
  float x, y;
  float wid, hgt;
  PImage img;
  boolean active;
  boolean deac;
  boolean reac;
  int transNum;
 
  VisLabel(float _x, float _y, float w, float h, String path, boolean act) {
    x = _x;
    y = _y;
    wid = w;
    hgt = h;
    img = loadImage(path);
    active = act;
    reac = false;
    deac = false;
    transNum = 0;
  }
  
  public void draw_label() {
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
  }
  
  public void activate() {
    if(!active) {
      active = true;
      reac = true; 
    }
  }
  
  public void deactivate() {
    if(active) {
      active = false;
      deac = true;
    }
  }
  
  public void check_activate() {
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
  
  public boolean was_pressed() {
    if (mouseX > x && mouseX < x + wid) {
      if(mouseY > y && mouseY < y + hgt) {
        return true;
      }
    }
    
    return false;
  }
}


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
  int[][] colors;
  int[] color_list;
  boolean curve;
  boolean flip;
  boolean[] flipped_cols;
  String[] headers;
  Range prev;

  ParGraph (UserData d) {
    //initializations for final project
    num_cols = d.NUM_QS + 1;
    num_rows = 93;
    headers = new String[num_cols];
    data = d;

    //default initializations
    // data = d;
    // mins = new float[num_cols];
    // maxes = new float[num_cols];
    // find_bounds();
    // x_coords = new float[num_cols];
    // y_coords = new float[num_cols][num_rows];
    for(int i = 0; i < num_cols; i++) {
    	headers[i] = "Q" + str(i);
    }
    headers[headers.length - 1] = "Age";
    num_labels = headers.length;
    labels = new float[num_cols][num_labels];
    label_coords = new float[num_cols][num_labels];
    pg = null;
    colored_col = num_cols - 1;
    hover_col = -1;
    curve = false;
    flip = false;
    flipped_cols = new boolean[num_cols];
    for (int i = 0; i < flipped_cols.length; i++) {
      flipped_cols[i] = false;
    }
    generate_colors();
    prev = new Range();
    prev.low = 0;
    prev.high = 0;
    prev.gender="";
  }

  public void draw_graph(int x_in, int y_in, int w_in, int h_in, Range r, String g) {
    x = x_in;
    y = y_in;
    w = w_in;
    h = h_in;

    fill(255);
    noStroke();
    rect(x, y, w, h);

    range = r;
    gender = g;

    if (range.low != prev.low || range.high != prev.high || range.gender != prev.gender) {
	    calculate_data(r,g);
		calculate_axes();
		calc_pts();
		calc_labels();
    	calc_colors();
	}

	draw_axes();
	draw_lines();
	draw_pts();
	draw_labels();

	prev = r;
  }

  public void calculate_data(Range r, String g) {
  	num_rows = range.high - range.low;

    vals = data.get_qs_avg(range, gender);
    printArray(vals[vals.length-1]);
    // float[] ages = new float[num_rows];
    // for(int i = range.low; i < range.high; i++) {
    // 	ages[i-range.low] = float(i);
    // }
    // vals = (float[][])append(vals, ages);

	mins = new float[num_cols];
    maxes = new float[num_cols];
    find_bounds();
    x_coords = new float[num_cols];
    y_coords = new float[num_cols][num_rows];
  }

  public void generate_colors() {
  	colors = new int[num_cols][num_rows];
    color_list = new int[num_labels-1];
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

  public void find_bounds() {
    for (int i = 0; i < num_cols; i++) {
    	printArray(vals[i]);
      mins[i] = min(vals[i]);
      maxes[i] = max(vals[i]);
    }
  }

  public void calculate_axes() {
    x_spacing = w/(num_cols+1);
    for (int i = 0; i < x_coords.length; i++) {
      x_coords[i] = x + x_spacing * (i+1);
    }

    y_top = y+20;
    y_bott = y + h - 40;
  }

  public void calc_pts() {
    for (int i = 0; i < num_cols; i++) {
      for (int k = 0; k < num_rows; k++) {
        y_coords[i][k] = map(vals[i][k], mins[i], maxes[i], y_bott, y_top);
      }
    }
    for (int i = 0; i < flipped_cols.length; i++) {
      if (flipped_cols[i]) { 
        flip_pts(i);
      }
    }
  }

  public void calc_labels() {
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

  public void calc_colors() {
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

  public void draw_axes() {
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

      line(x_coords[i], y_top, x_coords[i], y_bott);
      textSize(10);
      textAlign(CENTER);
      text(headers[i], x_coords[i], y_bott + 20);

      strokeWeight(1);
      stroke(0);
      fill(0);
    }
  }

  public void draw_pts() {
    for (int i = 0; i < num_cols; i++) {
      for (int k = 0; k < num_rows; k++) {
        fill(0, 0, 0);
        ellipse(x_coords[i], y_coords[i][k], 5, 5);
      }
    }
  }

  public void draw_lines() {
    if (curve) {
      noFill();
      // int num_cols = num_cols;
      for (int i = 0; i < (num_rows); i++) {
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
      for (int i = 0; i < num_rows; i++) {
        for (int k = 0; k < num_cols - 1; k++) {
          stroke(colors[k][i]);
          line(x_coords[k], y_coords[k][i], x_coords[k+1], y_coords[k+1][i]);
          stroke(0, 0, 0);
        }
      }
    }
  }

  public void draw_labels() {
    for (int i = 0; i < num_cols; i++) {
      for (int k = 0; k < num_labels; k++) {
        fill(0, 0, 0);
        textSize(10);
        textAlign(RIGHT, CENTER);
        float len = y_bott - y_top;
        text(labels[i][k], x_coords[i]-5, label_coords[i][k]);
      }
    }
  }

  public void col_change(int mousex) {
    // int num_cols = num_cols;
    for (int i = 0; i < num_cols; i++) {
      if (mousex > (width/num_cols)*i && mousex < (width/num_cols)*(i+1)) {
        colored_col = i;
      }
    }
  }

  public void hover(int mousex) {
    // int num_cols = num_cols;
    for (int i = 0; i < num_cols; i++) {
      if (mousex > (w/num_cols)*i && mousex < (w/num_cols)*(i+1)) {
        hover_col = i;
      }
    }
  }

  public void flip_dim() { 
    flipped_cols[hover_col] = true;
  }
  public void unflip() { 
    flipped_cols[hover_col] = false;
  }

  public void flip_pts(int i) {
    //print("flipping points\n");
    for (int k = 0; k < num_rows; k++) {
      y_coords[i][k] = map(vals[i][k], maxes[i], mins[i], y_bott, y_top);
      //print("flipped: ", y_coords[i][0], "\n");
    }
  }

  public void flip_labels(int i) {
    float y_spacing = (y_bott - y_top)/(num_labels-1);
    for (int k = 0; k < num_labels; k++) {
      float label_spacing = (maxes[i] - mins[i])/(num_labels-1);
      float label = maxes[i] - (label_spacing*k);
      labels[i][k] = label;
      label_coords[i][k] = y_bott - (y_spacing*k);
    }
  }

  public void view_bezier() { 
    curve = true;
  }
  public void view_line() { 
    curve = false;
  }
}
class Parser {
  UserData data;
  int num_quest;
  int num_words;
  int quest_index;
  int word_index;
  
  Parser() {
    data = new UserData();
    num_quest = 19;
    num_words = 82;
    quest_index = 8;
    word_index = 27;
  }
  
  public UserData parse(String file) {
    String[] lines = loadStrings(file);
    String[] split_line;
    
    for (int i = 1; i < lines.length; i++) {
      split_line = splitTokens(lines[i], ",");
      
      getUser(split_line);
      
    }
    
    //printtest();
    
    return data;
  }
  
  public void getUser(String[] split_line) {
    String gender = split_line[1];
    int age = PApplet.parseInt(split_line[2]);
    if (age == -1) {return;}
    
    if (gender.equals("Female")) {
      data.girls[age].contains_data = true;
      
      for (int i = 0; i < num_quest; i++) {
         data.girls[age].total_q_score[i] += PApplet.parseFloat(split_line[quest_index + i]);
         data.girls[age].num_per_q[i] += 1;
      }
      
      for (int i = 0; i < num_words; i++) {
         data.girls[age].word_freqs[i] += PApplet.parseInt(split_line[word_index + i]);
      }
      
      assign_pref(age, gender, split_line);
      
    } else {
      data.boys[age].contains_data = true;
      
      for (int i = 0; i < num_quest; i++) {
         data.boys[age].total_q_score[i] += PApplet.parseFloat(split_line[quest_index + i]);
         data.boys[age].num_per_q[i] += 1;
      }
      
      for (int i = 0; i < num_words; i++) {
         data.boys[age].word_freqs[i] += PApplet.parseInt(split_line[word_index + i]);
      }
      
      assign_pref(age, gender, split_line);
      
    }
  }
  
  public void assign_pref(int age, String gender, String[] split_line) {
      int state_index = data.boys[0].find_statement(split_line[5]);
    
         if (PApplet.parseInt(split_line[6]) != -1) {
           if (gender.equals("Female")) { 
              data.girls[age].prefs[state_index].listen_own += PApplet.parseInt(split_line[6]);
              data.girls[age].prefs[state_index].num_listen_own += 1;
           } else {
              data.boys[age].prefs[state_index].listen_own += PApplet.parseInt(split_line[6]);
              data.boys[age].prefs[state_index].num_listen_own += 1;      
           }
         }
      
         if (PApplet.parseInt(split_line[7]) != -1) {
           if (gender.equals("Female")) {
             data.girls[age].prefs[state_index].listen_back += PApplet.parseInt(split_line[7]);
             data.girls[age].prefs[state_index].num_listen_back += 1;
           } else {
             data.boys[age].prefs[state_index].listen_back += PApplet.parseInt(split_line[7]);
             data.boys[age].prefs[state_index].num_listen_back += 1;
           }
         }
  }
  
  public void printtest() {
     for (int i = 0; i < 82; i++) {
        print(data.girls[40].word_freqs[i], "\n");
     } 
  }
  
}
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
  int text_color;  //(200, 150, 200)
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

  public void draw_graph() {
    draw_title(); 
    find_angles();
    find_diameter();
    draw_chart();
  }
  
  public void draw_title() {
    fill(150, 0, 150);
    stroke(150, 0, 150);
    textAlign(CENTER);
    textSize(20);
    text("Average Time Spent:", piex, 42);
    
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
    list_own_angle = PApplet.parseFloat(360) * data.listen_own_avg / total_time;
    list_back_angle = PApplet.parseFloat(360) * data.listen_back_avg / total_time;
    rem_angle = PApplet.parseFloat(360) - list_own_angle - list_back_angle;
  }

  

  public void draw_chart() {
      print("drawing pie\n");
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
  
  public void draw_words(float lastAngle, float ownAngle, String message) {
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
  
  public void draw_vals(float lastAngle, float ownAngle, float val) {
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

  
  public void find_diameter() {
    if (width > height) {
      diameter = height/2;
    } else {
      diameter = width/2;
    }
  }
}



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
  
  public void draw_pies(Range range, String gender) {
     fill(255);
     noStroke();
     rect(0, 0, 1200, 581);

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
       print(todraw.num_listen_own, "\n");
     }
     
     
     pie = new PieChart(todraw);
     pie.draw_graph();
  }
  
  public void print_header() {
     fill(0);
     stroke(0);
     textAlign(LEFT, TOP);
     textSize(17);
     text("Filter based on respondents' statements:", statements_x1, statements_y1 - 30);
     line(statements_x1, statements_y1 - 12, statements_x2 - 135, statements_y1 - 12 );
  }
  
  public void print_statements() {
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
  
  public void check_click() {
    print("in check click\n");
    int curr_y = statements_y1;
    if((mouseX > statements_x1) && (mouseX < statements_x2)) {
      print("within statement area\n");
      for (int i = 0; i < NUM_STATEMENTS; i++) {
         print("mousey is: ", mouseY, " curry is: ", curr_y, "curry + interval is: ", curr_y + statement_yinterval, "\n");
         if((mouseY >= curr_y) && (mouseY < (curr_y + statement_yinterval))) {
             print("printing", data.girls[0].music_statements[i], "\n");
             clicked = i;
         }
         curr_y += statement_yinterval;

      }
    }
  }
  
  
}
/*************************************************************************/
/*                            BRACKET CLASS                              */
/*************************************************************************/
class Bracket {
  float x, y;                       //pos on slide line
  float w, h;                       //static width and height
  float int_l, int_r, int_t, int_b; //box for intersecting
  float l_bound, r_bound;           //
  int val;                          //value held on slider bar
  boolean isLeft;
  boolean active;                   //currently being dragged
 
  Bracket(float _x, float _y, float _l, float _r, int start, boolean l) {
    x = _x;
    y = _y;
    l_bound = _l;
    r_bound = _r;
    w = 8;
    h = 30;
    
    int_l = x - w/2;
    int_r = x + w/2;
    int_t = y - h/2;
    int_b = y + h/2;
    
    val = start;
    isLeft = l;
    active = false;
  } 
  
  public void draw_self() {
    float x2;
    
    if (isLeft) {
      x2 = x + (w/2);
    } else {
      x2 = x - (w/2);
    }
    
    stroke(200, 0, 0);
    strokeWeight(5);
    
    line(x, y - (h/2), x,  y + (h/2)); //vert part of bracket
    line(x, y - (h/2), x2, y - (h/2)); //top horiz of bracket
    line(x, y + (h/2), x2, y + (h/2)); //bot horiz of bracket
  }
  
  public void draw_val() {
    fill(255);
    strokeWeight(0);
    rect(0, 580, 1200, 20);
    float rect_x = x - (2 * w);
    float rect_y = y - (1.5f * h);
    float rect_w = 4 * w;
    float rect_h = .75f * h;
    strokeWeight(1);
    //noStroke();
    fill(255);
    rect(rect_x, rect_y, rect_w, rect_h, 4); 
    
    PFont font;
    //must be located in data directory in sketchbook
    font = loadFont("UbuntuMono-Bold-16.vlw");
    textFont(font, 16);    
    textAlign(CENTER, CENTER);
     
    fill(200, 0, 0);
    text(val, x, (y - 1.125f * h));
    
  }
  
  public void check_click() {
    if((mouseX > int_l && mouseX < int_r) && (mouseY > int_t && mouseY < int_b)) {
      active = true;
    } 
  }
  
  public void move(float oth_x, int oth_v) {
    if(active) {
      float lb, rb;
      int lbv, rbv;
      
      //determining bracket's range
      if(isLeft) {
        lb = l_bound;
        rb = oth_x;
        lbv = 0;
        rbv = oth_v;
      } else {
        lb = oth_x;
        rb = r_bound;
        lbv = oth_v;
        rbv = 93;
      }
            
      float curr, l, r;
      curr = map(val, 0, 93, l_bound, r_bound);
      l    = map(val - 1, 0, 93, l_bound, r_bound);
      r    = map(val + 1, 0, 93, l_bound, r_bound);
              
      if ((abs(mouseX - l) < abs(mouseX - curr)) && (val != lbv)) {
         val--;
         x = l;
         int_l = x - w/2;
         int_r = x + w/2;
      } else if ((abs(mouseX - r) < abs(mouseX - curr)) && (val != rbv)) {
         val++;
         x = r;
         int_l = x - w/2;
         int_r = x + w/2;
      }
    } 
  }
  
  public void unactivate() {
    active = false; 
  }
}

/*************************************************************************/
/*                             SLIDER CLASS                              */
/*************************************************************************/

class Slider {
  float x, y;
  float wid;
  
  Bracket left, right;
 
  Slider(float _x, float _y, float w) {
    x = _x;
    y = _y;
    wid = w;
    
    left  = new Bracket(x,       y, x, x + wid, 0,  true);
    right = new Bracket(x + wid, y, x, x + wid, 93, false); 
  } 
  
  public void draw_slider() {
    if(mousePressed) {
      move_brackets();
    }

    draw_range();    
  }
  
  public void draw_range() {
    stroke(70);
    strokeWeight(4);
    float x1 = x;
    float x2 = x + wid;
    //float yn  = y + (hgt / 2);
    line(x1, y, x2, y);
    draw_notches(x1, x2);
  }
  
  public void draw_notches(float xl, float xr) {
    float xloc;
    int l_id = left.val;
    int r_id = right.val;
    for(int i = 0; i < 94; i++) {
      xloc = lerp(xl, xr, (i / 93.0f));
      line(xloc, y - 8, xloc, y + 8);
      
      if(i == l_id) {
        left.draw_self(); 
        if (left.active) {
          left.draw_val();
        }
        stroke(200);
        strokeWeight(4);
      }
      
      if(i == r_id) {
        right.draw_self(); 
        if (right.active) {
          right.draw_val();
        }
        stroke(70);
        strokeWeight(4);
      }
    }
  }
  
  public Range get_range(Range toRet) {
    toRet.low = left.val;
    toRet.high = right.val;

    return toRet;
  } 
  
  public void check_brackets() {
    if(left.val == right.val) {
      if(left.val == 0) {
        right.check_click();
      } else {
        left.check_click();
      }
    } else {
      left.check_click();
      right.check_click();
    }
  }
  
  public void move_brackets() {
    left.move(right.x, right.val);
    right.move(left.x, left.val);
  }
  
  public void unactivate() {
    left.unactivate();
    right.unactivate(); 
  }
  
  
}
class UserData {
  final int MAXAGE = 95;
  final int NUM_QS = 19;
  final int NUM_WORDS = 82;
  final int NUM_STATEMENTS = 5;
  
  AgeGroup[] boys;
  AgeGroup[] girls;
  
  
  UserData() {
    boys = new AgeGroup[MAXAGE];
    girls = new AgeGroup[MAXAGE];
    
    for (int i = 0; i < MAXAGE; i++) {
      girls[i] = new AgeGroup();
      boys[i] = new AgeGroup();
    }
  }
  
  public int[] get_freqs(Range range, String gender) {
    int[] total = new int[NUM_WORDS];
    for (int i = range.low; i < range.high; i++) {
      if (i < 0) {i = 0;}
      for (int j = 0; j < NUM_WORDS; j++) {
        if (gender.equals("female")) {
          total[j] += girls[i].word_freqs[j];
        } else if (gender.equals("male")) {
          total[j] += boys[i].word_freqs[j];
        } else {
          total[j] += girls[i].word_freqs[j];
          total[j] += boys[i].word_freqs[j];
        }
      }
    }
    
    return total;
  }
  
  public int[] get_bar_stats(int word_index, String gender) {
     int[] toret = new int[MAXAGE];
     
     //just for testing
     gender = "both";
     
     for (int i = 0; i < MAXAGE; i++) {
        if (gender.equals("female")) {
          toret[i] = girls[i].word_freqs[word_index];
        } else if (gender.equals("male")) {
          toret[i] = boys[i].word_freqs[word_index];
        } else {
          toret[i] += girls[i].word_freqs[word_index];
          toret[i] += boys[i].word_freqs[word_index];
        }
        //print(toret[i], "\n");
      }
      
      return toret;
   }
   
  public MusicPref[] get_pie_stats(Range range, String gender) {
      MusicPref[] toret = new MusicPref[NUM_STATEMENTS];
      for (int i = 0; i < NUM_STATEMENTS; i++) {
        toret[i] = new MusicPref();
      }
      
      for (int i = range.low; i < range.high; i++) {
        for (int j = 0; j < NUM_STATEMENTS; j++) {
           if(gender.equals("female")) {
              toret[j].listen_own += girls[i].prefs[j].listen_own;
              toret[j].num_listen_own += girls[i].prefs[j].num_listen_own;
              toret[j].listen_back += girls[i].prefs[j].listen_back;
              toret[j].num_listen_back += girls[i].prefs[j].num_listen_back;
           } else if(gender.equals("male")) {
              toret[j].listen_own += boys[i].prefs[j].listen_own;
              toret[j].num_listen_own += boys[i].prefs[j].num_listen_own;
              toret[j].listen_back += boys[i].prefs[j].listen_back;
              toret[j].num_listen_back += boys[i].prefs[j].num_listen_back;
           } else {
              toret[j].listen_own += girls[i].prefs[j].listen_own;
              toret[j].num_listen_own += girls[i].prefs[j].num_listen_own;
              toret[j].listen_back += girls[i].prefs[j].listen_back;
              toret[j].num_listen_back += girls[i].prefs[j].num_listen_back;
              toret[j].listen_own += boys[i].prefs[j].listen_own;
              toret[j].num_listen_own += boys[i].prefs[j].num_listen_own;
              toret[j].listen_back += boys[i].prefs[j].listen_back;
              toret[j].num_listen_back += boys[i].prefs[j].num_listen_back;
           }
        } 
      }
      
      for (int j = 0; j < NUM_STATEMENTS; j++) {
          toret[j].listen_own_avg = toret[j].listen_own / toret[j].num_listen_own;
          toret[j].listen_back_avg = toret[j].listen_back / toret[j].num_listen_back;
      }
      
      return toret;
  }
  
  public float[][] get_qs_avg(Range range, String gender) {
    float[][] total = new float[NUM_QS+1][0];
    for (int i = range.low; i < range.high; i++) {
      float[] row = new float[NUM_QS+1];
      int index = i - range.low;
      print(index);
      row[NUM_QS] = i;
      for (int j = 0; j < NUM_QS; j++) {
        if (gender.equals("female")) {
          if(girls[index].num_per_q[j] == 0) {
            row[j] = 0;
          } else {
            row[j] = girls[index].total_q_score[j]/girls[index].num_per_q[j];
          }
        } else if (gender.equals("male")) {
          if(boys[index].num_per_q[j] == 0) {
            row[j] = 0;
          } else {
            row[j] = boys[index].total_q_score[j]/boys[index].num_per_q[j];
          }
        } else {
          if(girls[index].num_per_q[j] == 0) {
            row[j] = 0;
          } else {
            row[j] = girls[index].total_q_score[j]/girls[index].num_per_q[j];
          }

          if(boys[index].num_per_q[j] == 0) {
            row[j] += 0;
          } else {
            row[j] += boys[index].total_q_score[j]/boys[index].num_per_q[j];
          }
          row[j] = row[j]/2;
        }
      }
      total = (float[][])append(total, row);
      //printArray(total[total.length-1]);
    }
    return total;
  }
}
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
  
  WordBar(int[] vs, int x1, int y1, int x2, int y2) {
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
  }
  
  public void draw_graph(Range range) {
    get_coords();
    draw_bars(range);
  }
  
  public void get_coords() {
    y_coords = new float[num_ages];
    x_coords = new float[num_ages];
    int curr_x = canvas_x1;
    
    for (int i = 0; i < num_ages; i++) {
       float ratio = vals[i]/max_val;
       y_coords[i] = (PApplet.parseFloat(canvas_h) - PApplet.parseFloat(canvas_h)*ratio) + canvas_y1;
       x_coords[i] = curr_x;
       curr_x += interval;
    }
  }
  
  public void draw_bars(Range range) {
     for (int i = 0; i < num_ages; i++) {
        if((i >= range.low) && (i <= range.high)) {
            fill(0);
        } else {
            fill(125);
        }
        rect(x_coords[i]+x_spacing, y_coords[i], bar_width, canvas_y2 - y_coords[i]);
     }
    
  }
  
  
}
/*class Display {
  //data for visualizations
  UserData data;      //contains an array of AgeGroups for m & f
  
  //list of visualizations, may be active or nah
  Cloud    cloud; 
  //ParGraph par_graph;
   more to be added 
  
  int[] word_freqs;

  Display(WordCram wc, UserData d) {
    data = d;
    cloud = new Cloud(wc, data);
    //par_graph = new ParGraph(data);
  }
  
  //returns true if frequencies change
  void get_freqs(Range range) {
      word_freqs = cloud.get_freqs(range, "female");
      //return cloud.freq_changed();
  }

  void draw_graphs(WordCram wc) {
      cloud.set_weights(wc, word_freqs);
      cloud.draw_cloud();
      
  }
  
  void set_click() {
      cloud.check_click();
  }
  
}

import java.awt.geom.Area;
import java.awt.geom.Rectangle2D;
import java.awt.Shape;
import wordcram.*;

int screenWidth = 1200;
int screenHeight = 700;

Parser   parser;
Display  toShow;
Slider   slider;
Filter   filter;
WordCram wc;
Range    range;
Range    prev_range;
boolean clicked;

//PGraphics canvas = this.createGraphics(screenWidth - 100, screenHeight - 100, P2D\\);
PImage image = createImage(1000, 650, RGB);
Shape imageShape = new ImageShaper().shape(image, #000000);
ShapeBasedPlacer placer = new ShapeBasedPlacer(imageShape);

void setup() {
  size(screenWidth, screenHeight);
  background(255);
  frameRate(60);

  parser = new Parser();
  UserData data = parser.parse("../merged.csv");
  wc = new WordCram(this);
  //wc.withCustomCanvas(this.canvas);
  toShow = new Display(wc, data);
  filter = new Filter(0, 600, 1200, 100);
  prev_range = new Range();
  prev_range.low = 0;
  prev_range.high = 93;
  clicked = false;


  /*
  if (frame != null) {
   frame.setResizable(true);
   }
   
}


void draw() {
  //slider.draw_slider();
  filter.draw_filter();
  
  range = filter.get_range();
  if (range.low >= range.high) {
    range.high = range.low + 1;
  }
  
  toShow.get_freqs(range);
  
  if(!mousePressed) {
    if (range_changed() == true) {
      if(range_changed() == true) {print("changed\n");}
      wc = new WordCram(this);
      fill(255);
      noStroke();
      rect(0, 0, 1200, 600);
    }
  }
  
  toShow.draw_graphs(wc);
  
  
  //print("Range: ", range.low, " to ", range.high, "\n");
  //find range from slider
  //pass range into Display's draw
  //display has range, pulls data, updates vizs
}

boolean range_changed() {
  if((range.low == prev_range.low) && (range.high == prev_range.high)) {
      return false;
  } else {
      prev_range = range;
      return true;
  }
}


void mouseClicked() {
  toShow.set_click();
}

void mousePressed() {
  filter.pressed();
}

void mouseReleased() {
  filter.released();
}


class UserData {
  final int MAXAGE = 95;
  final int NUM_QS = 20;
  final int NUM_WORDS = 82;
  
  AgeGroup[] boys;
  AgeGroup[] girls;
  
  
  UserData() {
    boys = new AgeGroup[MAXAGE];
    girls = new AgeGroup[MAXAGE];
    
    for (int i = 0; i < MAXAGE; i++) {
      girls[i] = new AgeGroup();
      boys[i] = new AgeGroup();
    }
  }
  
  int[] get_freqs(Range range, String gender) {
    int[] total = new int[NUM_WORDS];
    for (int i = range.low; i < range.high; i++) {
      for (int j = 0; j < NUM_WORDS; j++) {
        if (gender.equals("female")) {
          total[j] += girls[i].word_freqs[j];
        } else if (gender.equals("male")) {
          total[j] += boys[i].word_freqs[j];
        } else {
          total[j] += girls[i].word_freqs[j];
          total[j] += boys[i].word_freqs[j];
        }
      }
    }
    
    return total;
  }
  
  int[] get_bar_stats(int word_index, String gender) {
     int[] toret = new int[MAXAGE];
     
     //just for testing
     gender = "both";
     
     for (int i = 0; i < MAXAGE; i++) {
        if (gender.equals("female")) {
          toret[i] = girls[i].word_freqs[word_index];
        } else if (gender.equals("male")) {
          toret[i] = boys[i].word_freqs[word_index];
        } else {
          toret[i] += girls[i].word_freqs[word_index];
          toret[i] += boys[i].word_freqs[word_index];
        }
        //print(toret[i], "\n");
      }
      
      return toret;
   }
  
  
}

*/
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MusicVis" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
