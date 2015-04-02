/*************************************************************************/
/*                            BRACKET CLASS                              */
/*************************************************************************/
class Bracket {
  float x, y;                       //pos on slide line
  float w, h;                       //static width and height
  float int_l, int_r, int_t, int_b; //box for intersecting
  float l_bound, r_bound;           //
  int val;                          //value held on slider bar
  boolean isLeft;
  boolean active;                   //currently being dragged
 
  Bracket(float _x, float _y, float _l, float _r, int start, boolean l) {
    x = _x;
    y = _y;
    l_bound = _l;
    r_bound = _r;
    w = 8;
    h = 30;
    
    int_l = x - w/2;
    int_r = x + w/2;
    int_t = y - h/2;
    int_b = y + h/2;
    
    val = start;
    isLeft = l;
    active = false;
  } 
  
  void draw_self() {
    float x2;
    
    if (isLeft) {
      x2 = x + (w/2);
    } else {
      x2 = x - (w/2);
    }
    
    stroke(200, 0, 0);
    strokeWeight(5);
    
    line(x, y - (h/2), x,  y + (h/2)); //vert part of bracket
    line(x, y - (h/2), x2, y - (h/2)); //top horiz of bracket
    line(x, y + (h/2), x2, y + (h/2)); //bot horiz of bracket
  }
  
  void draw_val() {
    float rect_x = x - (1.5 * w);
    float rect_y = y + .5 * h;
    float rect_w = 3 * w;
    float rect_h = .5 * h;
    stroke(200, 0, 0);
    strokeWeight(1);
    //noStroke();
    fill(255);
    rect(rect_x, rect_y, rect_w, rect_h, 4); 
    
    PFont font;
    //must be located in data directory in sketchbook
    font = loadFont("UbuntuMono-Bold-13.vlw");
    textFont(font, 13);    
    textAlign(CENTER, CENTER);
     
    fill(200, 0, 0);
    text(val, x, (y +.75 * h));
    
  }
  
  void check_click() {
    if((mouseX > int_l && mouseX < int_r) && (mouseY > int_t && mouseY < int_b)) {
      active = true;
    } 
  }
  
  void move(float oth_x, int oth_v) {
    if(active) {
      float lb, rb;
      int lbv, rbv;
      
      //determining bracket's range
      if(isLeft) {
        lb = l_bound;
        rb = oth_x;
        lbv = 0;
        rbv = oth_v;
      } else {
        lb = oth_x;
        rb = r_bound;
        lbv = oth_v;
        rbv = 93;
      }
            
      float curr, l, r;
      curr = map(val, 0, 93, l_bound, r_bound);
      l    = map(val - 1, 0, 93, l_bound, r_bound);
      r    = map(val + 1, 0, 93, l_bound, r_bound);
              
      if ((abs(mouseX - l) < abs(mouseX - curr)) && (val != lbv)) {
         val--;
         x = l;
         int_l = x - w/2;
         int_r = x + w/2;
      } else if ((abs(mouseX - r) < abs(mouseX - curr)) && (val != rbv)) {
         val++;
         x = r;
         int_l = x - w/2;
         int_r = x + w/2;
      }
    } 
  }
  
  void unactivate() {
    active = false; 
  }
}

/*************************************************************************/
/*                             SLIDER CLASS                              */
/*************************************************************************/

class Slider {
  float x, y;
  float wid;
  
  Bracket left, right;
 
  Slider(float _x, float _y, float w) {
    x = _x;
    y = _y;
    wid = w;
    
    left  = new Bracket(x,       y, x, x + wid, 0,  true);
    right = new Bracket(x + wid, y, x, x + wid, 93, false); 
  } 
  
  void draw_slider() {
    if(mousePressed) {
      move_brackets();
    }

    draw_range();    
  }
  
  void draw_range() {
    stroke(70);
    strokeWeight(4);
    float x1 = x;
    float x2 = x + wid;
    //float yn  = y + (hgt / 2);
    line(x1, y, x2, y);
    draw_notches(x1, x2);
  }
  
  void draw_notches(float xl, float xr) {
    float xloc;
    int l_id = left.val;
    int r_id = right.val;
    for(int i = 0; i < 94; i++) {
      xloc = lerp(xl, xr, (i / 93.0));
      line(xloc, y - 8, xloc, y + 8);
      
      if(i == l_id) {
        left.draw_self(); 
        if (left.active) {
          left.draw_val();
        }
        stroke(200);
        strokeWeight(4);
      }
      
      if(i == r_id) {
        right.draw_self(); 
        if (right.active) {
          right.draw_val();
        }
        stroke(70);
        strokeWeight(4);
      }
      
      if(i % 10 == 0) { 
        if (i < l_id || i > r_id) {
          fill(70);
        } else {
          fill(200);
        }
        
        PFont font;
        font = loadFont("UbuntuMono-Regular-13.vlw");
        textFont(font, 13);    
        textAlign(CENTER, CENTER);
        text(i, xloc, y - 18); 
      }
    }
  }
  
  Range get_range(Range toRet) {
    toRet.low = left.val;
    toRet.high = right.val;

    return toRet;
  } 
  
  void check_brackets() {
    if(left.val == right.val) {
      if(left.val == 0) {
        right.check_click();
      } else {
        left.check_click();
      }
    } else {
      left.check_click();
      right.check_click();
    }
  }
  
  void move_brackets() {
    left.move(right.x, right.val);
    right.move(left.x, left.val);
  }
  
  void unactivate() {
    left.unactivate();
    right.unactivate(); 
  }
  
  
}
