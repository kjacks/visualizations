class Row {
     float x, y;
     boolean horizontal;
     Canvas[] values;
     float worst_aspect;
     float wid, hgt;
     float ctxt_w, ctxt_h;
     float total_value;
     int level;
     
     Row(float xA, float yA) {
       x = xA;
       y = yA;
       values = new Canvas[0];
     }
}
