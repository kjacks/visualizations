class ForceNode {
  String id;
  float mass;
  ForceNode parent;
  float dist_to_parent;
  int num_children;
  float x, y;
  float fx, fy;
  float vx, vy;
  float ax, ay;
  float KE;
  boolean intersect;
  boolean highlight;
  boolean drag;
  float radius;

  ForceNode() {
    id = "0";
    mass = 0;
    dist_to_parent = 0;
    num_children = 0;
    x = random(10, width-10);
    y = random(10, height-10);
    fx = 0;
    fy = 0;
    vx = 0;
    vy = 0;
    ax = 0;
    ay = 0;
    KE = 0;
    intersect = false;
    drag = false;
    radius = 0;
    highlight = false;
    //events = new Event[0];
  }

  ForceNode(String i, float mas, int canvas_w, int canvas_h) {
    id = i;
    mass = mas;
    dist_to_parent = 0;
    num_children = 0;
    x = random(10, canvas_w-10);
    y = random(10, canvas_h-10);
    fx = 0;
    fy = 0;
    vx = 0;
    vy = 0;
    ax = 0;
    ay = 0;
    KE = 0;
    intersect = false;
    drag = false;
    radius = crunch();
  }

  float crunch() {
    return (map(mass, 1, 10, 1, 10));
  }

  void update_position(float damp_const, float x1, float x2, float y1, float y2) {
    //assuming t = 1 frame
    float t = 1;

    if (!drag) {
      //x
      ax = fx/mass;
      x = x + vx*t + .5*ax*(t*t);
      vx = damp_const * (vx + ax*t);

      //y
      ay = fy/mass;
      y = y + vy*t + .5*ay*(t*t);
      vy = damp_const * (vy + ay*t);

      KE = .5 * mass * ((vx*vx) + (vy*vy));
    }

    if (x < x1 + 10) { 
      x = x1 + 10;
    }
    if (y < y1 + 10) { 
      y = y1 + 10;
    }
    if (x > x2 - 10) { 
      x = x2 - 10;
    }
    if (y > y2 - 10) { 
      y = y2 - 10;
    }
  }

  boolean intersect (int mousex, int mousey) {
    float distance;
    distance = sqrt(((mousex - x) * (mousex - x)) + ((mousey - y) * (mousey - y)));
    if (distance < radius) { 
      intersect = true;
    } else {
      intersect = false;
    }
    return intersect;
  }

  boolean drag (int mousex, int mousey) {
    if (intersect) {
      drag = true;
      x = float(mousex);
      y = float(mousey);
      return true;
    }
    return false;
  }
}

