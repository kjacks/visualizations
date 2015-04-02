int screenWidth = 600;
int screenHeight = 400;

Parser parser;
Canvas root;
Treemap treemap;

void setup() {
    // PUT INPUT FILE NAME HERE
    String file = "hierarchy2.shf";
    
    size(screenWidth, screenHeight);
    if (frame != null) {
      frame.setResizable(true);
    }
  
    parser = new Parser();
    root = parser.parse(file);
    treemap = new Treemap(root);
}

void draw() {
    treemap.draw_treemap();
}

void mouseClicked() {
    int clicked_node = treemap.intersect(mouseX, mouseY);
    
    if (mouseButton == LEFT) {
        treemap.zoom_in(clicked_node);
    } else {
        treemap.zoom_out(clicked_node);
    }
}

void mouseMoved() {
    root.intersect(mouseX, mouseY);
}
