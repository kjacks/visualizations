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
  boolean get_freqs(Range range) {
    word_freqs = cloud.get_freqs(range, range.gender);
    return cloud.freq_changed();
    //      par_graph.draw_graph(0, 0, width, height-100, range, range.gender);
  }

  // pass gender from Musicvis
  void draw_graphs(WordCram wc, Range range) {

    if (range.curVis.equals("cloud")) {
      cloud.set_weights(wc, word_freqs);
      cloud.draw_cloud(range);
    } else if (range.curVis.equals("par")) {
      par_graph.draw_graph(0, 0, width, height-100, range, range.gender);
    } else if (range.curVis.equals("pie")) {
      pies.draw_pies(range, range.gender);
    } else if (range.curVis.equals("tbd2")) {
    }
  }

  void set_click() {
    if (range.curVis.equals("pie")) {
      pies.check_click();
    } else if (range.curVis.equals("cloud")) {
      cloud.check_click();
    } else if (range.curVis.equals("par")) {
      par_graph.col_change(mouseX);
    }
  }

  void mousemove() {
    if (range.curVis.equals("par")) {
      par_graph.hover(mouseX);
    }
  }

  void keypress(int keyCode) {
    if (range.curVis.equals("par")) {
      if (keyCode == DOWN) {
        //Hitting down arrow will flip the dimension being hovered over if it was not already flipped
        par_graph.flip_dim();
      } else if (keyCode == UP) {
        //Hitting the up arrow will unflip the dimension being hovered over if it is flipped
        par_graph.unflip();
      } else if (keyCode == LEFT) {
        par_graph.generate_colors(); 
      }
    }
  }

  void keyrel(int keyCode) {
    if (range.curVis.equals("par")) {
      if (keyCode == DOWN) {
        //par_graph.unflip();
      }
    }
  }
}

