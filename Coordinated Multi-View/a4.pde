//This is the controller pretty much

int screenWidth = 800;
int screenHeight = 800;
Data data;
Heatmap heatmap;
Message message;
Cat_View categ;
ForceGraph graph;
int heatmap_x1, heatmap_x2;
int heatmap_y1, heatmap_y2;
float cat_x1, cat_x2;
float cat_y1, cat_y2;
int graph_x1, graph_x2;
int graph_y1, graph_y2;
int press_x, press_y;
Rect[] rects;
Rect curr;
int curr_section;

void setup() {
  size(screenWidth, screenHeight);
  if (frame != null) {
    frame.setResizable(true);
  }
  data = new Data();
  data.parse("data_aggregate.csv");

  graph_x1 = 0;
  graph_x2 = 2 * width/3 - 20;
  graph_y1 = 0;
  graph_y2 = 2 * height/3 - 75;

  graph = new ForceGraph(data, graph_x2 - graph_x1, graph_y2 - graph_y1);
  heatmap = new Heatmap(data);
  categ = new Cat_View(data);
  message = new Message();
  rects = new Rect[0];
  press_x = -1;
  press_y = -1;
}

void draw() {
  background(255, 255, 255);

  heatmap_x1 = 0;
  heatmap_x2 = width;
  heatmap_y1 = 2 * height/3;
  heatmap_y2 = height;

  cat_x1 = 2 * width/3;
  cat_x2 = width;
  cat_y1 = height/15;
  cat_y2 = 2 * height/3 - 20;

  graph_x1 = 0;
  graph_x2 = 2 * width/3;
  graph_y1 = 0;
  graph_y2 = 2 * height/3;
  graph.calc_forces();

  message = heatmap.draw_heatmap(heatmap_x1, heatmap_x2, heatmap_y1, heatmap_y2, message, rects);
  message = graph.draw_graph(graph_x1, graph_x2, graph_y1, graph_y2, message, rects);
  //fill(0, 0, 0);
  message = categ.draw_cat_view(cat_x1, cat_x2, cat_y1, cat_y2, message, rects);
  
  draw_rects();
}

void mouseMoved() {
  graph.intersect(mouseX, mouseY);
}

void mouseClicked(MouseEvent e) {
  if (e.getButton() == RIGHT) {
    rects = new Rect[0];
    message = new Message();
  }
}

void mousePressed(MouseEvent e) {
  if (e.getButton() == RIGHT) {
    rects = new Rect[0];
    message = new Message();
  }
  press_x = mouseX;
  press_y = mouseY;
  curr_section = which_section(press_x, press_y);
  //print(curr_section);

  curr = new Rect(press_x, mouseX, press_y, mouseY);
  rects = (Rect[])append(rects, curr);
}

void mouseDragged(MouseEvent e) {
  if (e.getButton() == RIGHT) {
    rects = new Rect[0];
    message = new Message();
    return;
  }
  int bounded_x, bounded_y;
  if ((press_x != -1) && (press_y != -1)) {
    if (curr_section == which_section(mouseX, mouseY)) {
        curr.set_dim(press_x, mouseX, press_y, mouseY);
    } else {
        bounded_x = mouseX;
        bounded_y = mouseY;
        if (curr_section == 0) {
           if (mouseX > cat_x1) {
             bounded_x = int(cat_x1);
           }
           if (mouseY > heatmap_y1) {
             bounded_y = heatmap_y1;
           }
        } else if (curr_section == 1) {
           if (mouseX < cat_x1) {
             bounded_x = int(cat_x1);
           }
           if (mouseY > heatmap_y1) {
             bounded_y = heatmap_y1;
           }
        } else {
           if (mouseY < heatmap_y1) {
             bounded_y = heatmap_y1;
           }
        }
      
        curr.set_dim(press_x, bounded_x, press_y, bounded_y);
    }
  }

  //graph.drag(mouseX, mouseY);
}

void draw_rects() {
  for (int i = 0; i < rects.length; i++) {
    rects[i].draw_rect();
  }
}

int which_section(int x, int y) {
    if (y < heatmap_y1) {
      if (x < cat_x1) {
          return 0;
      } else {
          return 1;
      }
    } else {
      return 2;
    }
}

