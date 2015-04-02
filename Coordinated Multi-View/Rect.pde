class Rect {
  int xleft, xright, ytop, ybot;
  
  Rect() {
    xleft = 0;
    xright = 0;
    ytop = 0;
    ybot = 0;
  }
  
  Rect(int x1, int x2, int y1, int y2) {
    set_dim(x1, x2, y1, y2);
  }
  
  void draw_rect() {
      fill(color(171,217,233), 50);
      stroke(color(171,217,233));
      rect(xleft, ytop, xright-xleft, ybot-ytop);
  }
  
  void set_dim(int x1, int x2, int y1, int y2) {
    if (x1 < x2) {
       xleft = x1;
       xright = x2;
    } else {
       xleft = x2;
       xright = x1;
    }
    
    if (y1 < y2) {
        ytop = y1;
        ybot = y2;
    } else {
        ytop = y2;
        ybot = y1;
    }
  }
}
