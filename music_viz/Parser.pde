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
  
  UserData parse(String file) {
    String[] lines = loadStrings(file);
    String[] split_line;
    
    for (int i = 1; i < lines.length; i++) {
      split_line = splitTokens(lines[i], ",");
      
      getUser(split_line);
      
    }
    
    //printtest();
    
    return data;
  }
  
  void getUser(String[] split_line) {
    String gender = split_line[1];
    int age = int(split_line[2]);
    if (age == -1) {return;}
    
    if (gender.equals("Female")) {
      data.girls[age].contains_data = true;
      
      for (int i = 0; i < num_quest; i++) {
         data.girls[age].total_q_score[i] += float(split_line[quest_index + i]);
         data.girls[age].num_per_q[i] += 1;
      }
      
      for (int i = 0; i < num_words; i++) {
         data.girls[age].word_freqs[i] += int(split_line[word_index + i]);
      }
      
      assign_pref(age, gender, split_line);
      
    } else {
      data.boys[age].contains_data = true;
      
      for (int i = 0; i < num_quest; i++) {
         data.boys[age].total_q_score[i] += float(split_line[quest_index + i]);
         data.boys[age].num_per_q[i] += 1;
      }
      
      for (int i = 0; i < num_words; i++) {
         data.boys[age].word_freqs[i] += int(split_line[word_index + i]);
      }
      
      assign_pref(age, gender, split_line);
      
    }
  }
  
  void assign_pref(int age, String gender, String[] split_line) {
      int state_index = data.boys[0].find_statement(split_line[5]);
    
         if (int(split_line[6]) != -1) {
           if (gender.equals("Female")) { 
              data.girls[age].prefs[state_index].listen_own += int(split_line[6]);
              data.girls[age].prefs[state_index].num_listen_own += 1;
           } else {
              data.boys[age].prefs[state_index].listen_own += int(split_line[6]);
              data.boys[age].prefs[state_index].num_listen_own += 1;      
           }
         }
      
         if (int(split_line[7]) != -1) {
           if (gender.equals("Female")) {
             data.girls[age].prefs[state_index].listen_back += int(split_line[7]);
             data.girls[age].prefs[state_index].num_listen_back += 1;
           } else {
             data.boys[age].prefs[state_index].listen_back += int(split_line[7]);
             data.boys[age].prefs[state_index].num_listen_back += 1;
           }
         }
  }
  
  void printtest() {
     for (int i = 0; i < 82; i++) {
        print(data.girls[40].word_freqs[i], "\n");
     } 
  }
  
}
