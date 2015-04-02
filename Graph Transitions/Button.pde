class Button {
  Button_State[] states;
  boolean isect;
  int curr_state;

  Button() {
    isect = false;
    curr_state = 0;
    states = new Button_State[0];
  }
  
  void draw_button(int x, int y) {
     states[curr_state].pos_x = x - (states[curr_state].w/2);
     states[curr_state].pos_y = y - (states[curr_state].h/2);
    
     int pos_x = states[curr_state].pos_x;
     int pos_y = states[curr_state].pos_y;
     int w = states[curr_state].w;
     int h = states[curr_state].h;
     String text = states[curr_state].text;
     color c = states[curr_state].col;
    
     fill(c);
     rect(pos_x, pos_y, w, h);
     textSize(10);
     fill(0,0,0);
     textAlign(CENTER, CENTER);
     text(text, pos_x + (w/2), pos_y + (h/2));
  }
  
  void add_state(String T, int wt, int ht, int x, int y, color c) {
     Button_State new_state = new Button_State(T, c, wt, ht, x, y);
     states = (Button_State[])append(states, new_state);
  }
  
  void update() {
    curr_state = 1;
  }
  
  void set_default() {
    curr_state = 0; 
  }
  
  boolean intersect (int mousex, int mousey) {
       int pos_x = states[curr_state].pos_x;
       int pos_y = states[curr_state].pos_y;
       int w = states[curr_state].w;
       int h = states[curr_state].h;
       
       if (mousex < (pos_x + w) && mousex > pos_x) {
           if (mousey < (pos_y + h) && mousey > pos_y) {
             update();
             return true;
           }
       }
       
       return false;
   }
   
   int getState() { return curr_state; }
   
}
