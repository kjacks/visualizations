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
  
  int[] get_freqs(Range range, String gender) {
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
   
  MusicPref[] get_pie_stats(Range range, String gender) {
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
  
  float[][] get_qs_avg(Range range, String gender) {
    float[][] total = new float[NUM_QS+1][range.high-range.low];
    for (int i = range.low; i < range.high; i++) {
      boolean no_data = false;
      int index = i - range.low;
      for (int j = 0; j < NUM_QS; j++) {
        if (gender.equals("female")) {
          if(girls[index].num_per_q[j] == 0) {
            total[j][index] = -1;
            no_data = true;
          } else {
            total[j][index] = girls[index].total_q_score[j]/girls[index].num_per_q[j];
          }
        } else if (gender.equals("male")) {
          if(boys[index].num_per_q[j] == 0) {
            total[j][index] = -1;
            no_data = true;
          } else {
            total[j][index] = boys[index].total_q_score[j]/boys[index].num_per_q[j];
          }
        } else {
          if(girls[index].num_per_q[j] == 0) {
            total[j][index] = -1;
            no_data = true;
          } else {
            total[j][index] = girls[index].total_q_score[j]/girls[index].num_per_q[j];
          }

          if(boys[index].num_per_q[j] == 0) {
            total[j][index] += -1;
            no_data = true;
          } else {
            total[j][index] += boys[index].total_q_score[j]/boys[index].num_per_q[j];
          }
          total[j][index] = total[j][index]/2;
        }
        //printArray(girls[i].num_per_q);
      }
      if (no_data) {
        total[NUM_QS][index] = -1;
      } else {
        total[NUM_QS][index] = i;
      }
    }
    
    return total;
  }
}
