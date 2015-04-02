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
  String gender;
  boolean clicked;
  int clicked_index;
  int barx1, barx2;
  int bary1, bary2;
  boolean show_cloud;
  boolean redraw;
  
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
    show_cloud = true;
    wc = w;
    data = d;
    clicked = false;
    barx1 = 20;
    bary1 = 525;
    barx2 = 820;
    bary2 = 595;
    gender = "both";
    redraw = false;
  }
  
  int[] get_freqs(Range range, String gen) {
    gender = gen;
    int[] freqs = data.get_freqs(range, gender);
    
    
    freq_range = max(freqs) - min(freqs);
    
    return freqs;
  }
  
  void set_weights(WordCram w, int[] freqs) {
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
  
  void draw_cloud(Range range) {
      //print(clicked, "\n");
    if (show_cloud == true) {
      if (freq_range != 0) {
        print("drawinggggg\n");
          wc.drawAll();
          if (wc.hasMore()) {
            //print("drawing more\n");
             wc.drawNext();
          }
          prev_freq_range = freq_range;
      }
      
      if (clicked == true) {
          fill(255);
          noStroke();
          rect(0, bary1, barx2 - barx1, bary2 - bary1);
          //print("drawing bars\n");
          print(clicked_index);
          draw_bars(range, words[clicked_index], false);
      } else {
          textAlign(LEFT);
          textSize(15);
          text("Click word to see distribution", barx1, bary2);
      }
      
    } else {
      fill(255);
      noStroke();
      rect(0, 0, width, 600);
      draw_bars(range, words[clicked_index], true);
      draw_wordlist();
      
      textSize(15);
      textAlign(LEFT, TOP);
      text("Show Wordcloud", width/3, 570);
    }
      
  }
  
  boolean freq_changed() {
    if (freq_range == prev_freq_range) {
      return false;
    } else {
      return true;
    }
  }
  
  //code below for generating bar graphs
  
  void check_click() {
    if (show_cloud == true) {
      check_click_wc();
    } else {
      check_click_bar();
    }
  }
  
  void check_click_wc() {
    Word clicked_w = wc.getWordAt(mouseX, mouseY);
    if (clicked_in_bar() == false) {
      if (clicked_w == null){
        clicked = false;
        fill(255);
        noStroke();
        rect(0, bary1 - 15, barx2 - barx1, bary2 - bary1 +15);
        //print("no word clicked\n");
      } else {
        clicked = true;
        //print(clicked_w, "\n");
        String[] split_line = splitTokens(clicked_w.toString(), " ");
        String word = split_line[0];
        clicked_index = get_word_index(word);
      }
    }
    
    print("\n", clicked, " ", show_cloud, "\n");
    
    if ((clicked_in_bar() == true) && (clicked == true)) {
        print("hiding cloud");
        show_cloud = false;
    } else {
        print("showing cloud");
        show_cloud = true;
    }
  }
    
  void check_click_bar() {
     print("checking bar ", mouseX, " ", mouseY, "\n");
     check_wordlist();
     if ((mouseX > 380) && (mouseX < 550) && (mouseY > 550) && (mouseY < 590)) {
        print("back to wordcloud\n");
        fill(255);
        noStroke();
        rect(0,0,width, 600);
        show_cloud = true;
        redraw = true;
     } 
  }
  
  boolean clicked_in_bar() {
    if (mouseX > barx1 && mouseX < barx2 && mouseY > bary1 && mouseY < bary2) {
        return true;
    } else {
        return false;
    }
  }
  
  int get_word_index(String w) {
      for (int i = 0; i < words.length; i++) {
        if (w.equals(words[i])) {
          return i;
        }
      }
      clicked = false;
      return -1;
  }
  
  void draw_bars(Range range, String word, boolean with_axes) {
     int[] bar_stats = data.get_bar_stats(clicked_index, gender);
     if (with_axes == true) {
       bar = new WordBar(bar_stats, 0, 20, width*2/3 + 35, 550, with_axes);
     } else {
       bar = new WordBar(bar_stats, barx1, bary1, barx2, bary2, with_axes);
     }
     bar.draw_graph(range, word);
  }
  
  void draw_wordlist() {
     int x = 2*width/3;
     int y_interval = (580/words.length) * 3;
     int curr_y = 0;
     int i = 0;
     textAlign(LEFT, TOP);
     textSize(12);
     
     for (i = 0; i < words.length/3; i++) {
        text(words[i], x, curr_y);
        curr_y += y_interval;
     }
     
     x += 100;
     curr_y = 0;
     
     for (i=i; i < 2* words.length/3; i++) {
        text(words[i], x, curr_y);
        curr_y += y_interval;
     }
     
     x += 100;
     curr_y = 0;
     
     for (i=i; i < words.length; i++) {
        text(words[i], x, curr_y);
        curr_y += y_interval;
     }
  }
  
  void check_wordlist() {
     int x = 2*width/3;
     int y_interval = (580/words.length) * 3;
     int curr_y = 0;
     int i = 0;
     
     for (i = 0; i < words.length/3; i++) {
        if (check_word(x, curr_y) == true) {
            clicked_index = i;
        }
        curr_y += y_interval;
     }
     
     x += 100;
     curr_y = 0;
     
     for (i=i; i < 2* words.length/3; i++) {
        if (check_word(x, curr_y) == true) {
            clicked_index = i;
        }
        curr_y += y_interval;
     }
     
     x += 100;
     curr_y = 0;
     
     for (i=i; i < words.length; i++) {
        if (check_word(x, curr_y) == true) {
            clicked_index = i;
        }
        curr_y += y_interval;
     }
  }
  
  boolean check_word(int x, int y) {
      if (mouseX > x && mouseX < x+100 && mouseY > y && mouseY < y+12) {
        return true;
      } else {
        return false;
      }
  }
}


