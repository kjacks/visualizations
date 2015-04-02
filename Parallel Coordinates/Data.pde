class Data { 
  String[] header;
  int num_cols;
  float[][] vals;

  void parse(String file) {
    String[] lines = loadStrings(file);
    String[] split_line;

    readHeader(lines[0]);
    num_cols = header.length;
    vals = new float[num_cols][lines.length - 1];

    //print(lines.length);
    for (int k = 0; k < num_cols; k++) {
      for (int i = 1; i < lines.length; i++) {
        split_line = splitTokens(lines[i], ",");
        vals[k][i-1] = float(split_line[k]);
      }
    }

    //printArray(vals[1]);
  }

  void readHeader(String line1) {
    header = new String[8];

    //given CSV has header delimited by ',' & ' '
    header = splitTokens(line1, ",");
    /*print("Headers: \n");
     printArray(header);
     print('\n');*/
  }
  
  int get_num_cols() { return num_cols; }
  int get_num_rows() { return vals[0].length; }
  String get_header(int index) { return header[index]; };
}