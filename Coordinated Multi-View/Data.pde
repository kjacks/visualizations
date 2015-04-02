class Data { 
  String[] header;
  int num_cols;
  Event[] events;

  //Modularity: Could've taken in delimeters
  void parse(String file) {
    String[] lines = loadStrings(file);
    String[] split_line;

    readHeader(lines[0]);

    events = new Event[lines.length - 1];
    for (int i = 1; i < lines.length; i++) {
      split_line = splitTokens(lines[i], ",");
      events[i - 1] = new Event(convert_time(split_line[0]), split_line[1], split_line[2], 
      split_line[3], split_line[4], split_line[5], 
      split_line[6], split_line[7]);
    }
  }

  void readHeader(String line1) {
    header = new String[8];

    //given CSV has header delimited by ',' & ' '
    header = splitTokens(line1, ",");
    /*print("Headers: \n");
     printArray(header);
     print('\n');*/
  }

  float convert_time(String input) {
    float hours, minutes, seconds;

    if (input.charAt(1) == ':') {
      hours = new Float(input.substring(0, 1));
      minutes = new Float(input.substring(2, 4));
      seconds = new Float(input.substring(5, 7));
    } else {
      hours = new Float(input.substring(0, 2));
      minutes = new Float(input.substring(3, 5));
      seconds = new Float(input.substring(6, 8));
    }

    float total = 3600 * hours + 60 * minutes + seconds;

    //print(hour, " ", minutes, " ", seconds, " ", total);

    return total;
  }
}

