class Cat_View {
  Data data;
  Cat_Bar[] graphs;
  int num_graphs;
  
  float xl, yt;
  float canvas_w, canvas_h;
  
  Cat_View(Data parsed) {
    num_graphs = 3;
    graphs = new Cat_Bar[num_graphs];
    data = parsed;
    
    for(int i = 0; i < num_graphs; i++) {
      graphs[i] = new Cat_Bar(data.events, data.header[5 + i], 5 + i);
    }
  }
  
  Message draw_cat_view(float x1, float x2, float y1, float y2, Message msg, Rect[] rs) {
    xl = x1;
    yt = y1;
    canvas_w = x2 - x1;
    canvas_h = y2 - y1;
    
    int num_chunks = 2 * num_graphs + 1;
    float spacing = (1.0 / num_chunks) * canvas_w;

    for(int i = 0; i < num_graphs; i++) {
      int mag_num = 2 * i + 1;
      
      msg = graphs[i].draw_graph(x1 + (mag_num * spacing),
                                 x1 + ((mag_num * spacing) + spacing),
                                 y1 + 20,
                                 y2,
                                 msg, rs );
    }     
    
    return msg;
  }  
}

