Data data;
Para_Coord graph;
int screenWidth = 800;
int screenHeight = 800;

void setup() {
  size(screenWidth, screenHeight);
  if (frame != null) {
    frame.setResizable(true);
  }

  data = new Data();
  data.parse("iris2.csv");
  graph = new Para_Coord(data);
}

void draw() {
  background(255, 255, 255);
  graph.draw_graph(0, 0, width, height);
}

void mouseClicked() {
  //Coloring of graph will change to dimension being hovered over
  graph.col_change(mouseX);
}

void mouseMoved() {
  //Axis being hovered over/near will turn green
  graph.hover(mouseX);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      //Hitting left arrow shows hacky version of a curved graph
      graph.view_bezier();
    } else if (keyCode == DOWN) {
      //Hitting down arrow will flip the dimension being hovered over if it was not already flipped
      graph.flip_dim();
    } else if (keyCode == UP) {
      //Hitting the up arrow will unflip the dimension being hovered over if it is flipped
      graph.unflip();
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      graph.view_line();
    } else if (keyCode == DOWN) {
      //graph.unflip();
    }
  }
}

