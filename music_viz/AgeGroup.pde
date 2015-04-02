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
  
  int find_statement(String statement) {
      for (int i = 0; i < NUM_STATEMENTS; i++) {
          if (statement.equals(music_statements[i])) {
              return i;
          }
      }
      
      //last stament has inconsistent spelling, so it is else case
      return 4;
  }
  
  
}
