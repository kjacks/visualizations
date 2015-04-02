int screenWidth = 1000;
int screenHeight = 1000;

Parser parser;
Node root;
Graph graph;

void setup() {
    // PUT INPUT FILE NAME HERE
    String file = "data1.csv";
    
    frameRate(30);
    
    size(screenWidth, screenHeight);
    if (frame != null) {
      frame.setResizable(true);
    }
  
    parser = new Parser();
    graph = parser.parse(file);
}

void draw() {
   background(255);
    graph.calc_forces();
    graph.draw_graph(); 
}

void mouseMoved() {
    graph.intersect(mouseX, mouseY);
}

void mouseDragged() {
    graph.drag(mouseX, mouseY);
}

void mouseReleased() {
    graph.undrag(); 
}
/*
void keyPressed() {
    graph.k_h = 0;
}

void keyReleased() {
    graph.k_h = .2;
}
*/
