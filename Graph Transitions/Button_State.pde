class Button_State {
   String text;
   color col;
   int w, h;
   int pos_x, pos_y;
  
   Button_State(String t, color c, int wt, int ht, int x, int y) {
      text = t;
      col = c;
      w = wt;
      h = ht;
      pos_x = x;
      pos_y = y; 
   }
   
   void setText(String t) { text = t; }
   void setColor(color c) { col = c; }
   void setDim(int wt, int ht) { 
     w = wt;
     h = ht;
   }
   void setPos(int x, int y) {
     pos_x = x;
     pos_y = y;
   }
   
   float getHeight () { return h; }
   float getWidth () { return w; }
   float getPosX () { return pos_x; }
   float getPosY () { return pos_y; }
   
}
