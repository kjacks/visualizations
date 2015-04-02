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
