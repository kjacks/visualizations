class Heatmap {
  float time_min, time_max;
  float time_interval;
  int num_intervals;
  Data data;
  int[][] hmap;
  String[] ports;
  float[] intervals;
  int canvas_w, canvas_h;
  int interval_w, interval_h;
  int min_val, max_val;
  int buffer_w, buffer_h;
  float[] mess_times;
  String[] mess_ports;
  

  Heatmap(Data parsed) {
    data = parsed;
    time_min = 100000;
    time_max = 0;
    time_interval = 0;
    num_intervals = 31;
    ports = new String[0];
    intervals = new float[num_intervals];
    find_fields();
    time_interval = (time_max - time_min)/(num_intervals-1);
    find_intervals();
    hmap = new int[ports.length][num_intervals];
    fill_hmap();
    find_val_bounds();
    mess_times = new float[0];
    mess_ports = new String[0];
  }

  void find_fields() {
    for (int i = 0; i < data.events.length; i++) {
      if (data.events[i].time < time_min) {
        time_min = data.events[i].time;
      } 
      if (data.events[i].time > time_max) {
        time_max = data.events[i].time;
      }
      if (find_port(data.events[i].dest_port) == -1) {
        ports = append(ports, data.events[i].dest_port);
      }
    }
    
    ports = sort(ports);
  }
/*
  void find_num_ports() {
    for (int i = 0; i < data.events.length; i++) {
      if (find_port(data.events[i].dest_port) == -1) {
        ports = append(ports, data.events[i].dest_port);
      }
    }
  }
*/
  void find_intervals() {
    float curr_time = time_min;
    
    for (int i = 0; i < num_intervals; i++) {
      intervals[i] = curr_time;
      curr_time += time_interval;
    }
  }

  int find_port(String curr) {
    for (int i = 0; i < ports.length; i++) {
      if (curr.equals(ports[i])) {
        return i;
      }
    }
    return -1;
  }

  void fill_hmap() {
    for (int i = 0; i < data.events.length; i++) {
      hmap[find_port(data.events[i].dest_port)][which_interval(data.events[i].time)] += 1;
    }
  }

  void find_val_bounds() {
    for (int i = 0; i < ports.length; i++) {
      for (int j = 0; j < num_intervals; j++) {
        if (hmap[i][j] < min_val) {
          min_val = hmap[i][j];
        }
        if (hmap[i][j] > max_val) {
          max_val = hmap[i][j];
        }
      }
    }
  }

  int which_interval(float curr) {
    float difference = curr - time_min;
    return floor(difference/time_interval);
  }

  Message draw_heatmap(int x1, int x2, int y1, int y2, Message message, Rect[] rects) {
    /*message.add_src_ip("*.2.130-140");
    message.add_dest_ip("*.1.0-10");
    message.add_priority("Info");*/
    mess_times = new float[0];
    mess_ports = new String[0];
    check_message(message);
    if(intersect(x1, y1 - 15, x2, y2)) {
        message.dest_port = new String[0];
        message.time = new float[0];
    }
    
    buffer_w = 90;
    buffer_h = 50;
    canvas_w = (x2 - x1) - buffer_w;
    canvas_h = (y2 - y1) - buffer_h;

    interval_w = canvas_w/(num_intervals);
    interval_h = canvas_h/(ports.length);

    int curr_x = x1 + buffer_w;
    int curr_y = y1;
    float c;

    draw_axis_labels(x1, x2, y1, y2);

    fill(255);
    stroke(0);
    textAlign(CENTER, CENTER);
    for (int i = 0; i < ports.length; i++) {
      for (int j = 0; j < num_intervals; j++) {
        c = map(hmap[i][j], min_val, max_val, 0, 255);
            
        if (intersect(curr_x, curr_y, curr_x + interval_w, curr_y + interval_h) || 
          rect_intersect(rects, curr_x, curr_y, curr_x + interval_w, curr_y + interval_h)) {
          fill(50, 50, 50);
          message.add_time(intervals[j]);
          message.add_dest_port(ports[i]);
        } else if (in_mess_arrays(intervals[j], ports[i])) {
        //else if ((message.in_dest_port(ports[i]) == message.in_time(intervals[j])) && (message.in_time(intervals[j]) != -1)) {
          fill(50, 255, 50);
          
        } else {
          fill(c, 195 - c, 255 - c);
        }

        rect(curr_x, curr_y, interval_w, interval_h);
        fill(0);
        //text(hmap[i][j], curr_x + interval_w/2, curr_y + interval_h/2);
        curr_x += interval_w;
      }
      curr_y += interval_h;
      curr_x = x1 + buffer_w;
    }
    
    return message;
  }
  
  void check_message(Message message) {
     boolean found = false;
     for (int i = 0; i < data.events.length; i++) {
        found = false;
        found = check_priority(message, data.events[i].priority);
        if (found == false) {found = check_operation(message, data.events[i].operation);}
        if (found == false) {found = check_protocol(message, data.events[i].protocol);}
        if (found == false) {found = check_dest_ip(message, data.events[i].dest_ip);}
        if (found == false) {found = check_src_ip(message, data.events[i].src_ip);}
        
        if (found == true) {
            mess_times = append(mess_times, data.events[i].time);
            mess_ports = append(mess_ports, data.events[i].dest_port);
        }
     }
  }

  
  boolean check_src_ip(Message message, String src_ip) {
      for (int i = 0; i < message.src_ip.length; i++) {
         if (src_ip.equals(message.src_ip[i])) {
             return true;
         }
      }
      return false;
  }
  
  boolean check_dest_ip(Message message, String dest_ip) {
      for (int i = 0; i < message.dest_ip.length; i++) {
         if (dest_ip.equals(message.dest_ip[i])) {
             return true;
         }
      }
      return false;
  }
  
  boolean check_priority(Message message, String priority) {
      for (int i = 0; i < message.priority.length; i++) {
         if (priority.equals(message.priority[i])) {
             return true;
         }
      }
      return false;
  }
  
  boolean check_operation(Message message, String operation) {
      for (int i = 0; i < message.operation.length; i++) {
         if (operation.equals(message.operation[i])) {
             return true;
         }
      }
      return false;
  }
  
  boolean check_protocol(Message message, String protocol) {
      for (int i = 0; i < message.protocol.length; i++) {
         if (protocol.equals(message.protocol[i])) {
             return true;
         }
      }
      return false;
  }

  boolean in_mess_arrays(float time, String dest_port) {
      for (int i = 0; i < mess_times.length; i++) {
          if (time == mess_times[i]) {
              if (dest_port.equals(mess_ports[i])) {
                  return true;
              }
          }
      }
      
      return false;
  }

  boolean intersect(int x1, int y1, int x2, int y2) {
    if ((mouseX > x1 && mouseX < x2) && (mouseY > y1 && mouseY < y2)) {
      return true;
    } else {
      return false;
    }
  }
  
  boolean rect_intersect(Rect[] rects, int x1, int y1, int x2, int y2) {
    for (int i = 0; i < rects.length; i++) {
        if(is_in(rects[i], x1, y1) || is_in(rects[i], x1, y2) ||
            is_in(rects[i], x2, y1) || is_in(rects[i], x2, y2)) {
                return true;
        }
    }
      return false;
  }    
      
  boolean is_in(Rect r, int x, int y) {
      if ((x > r.xleft && x < r.xright) && (y > r.ytop && y < r.ybot)) {
          return true;
      } else {
          return false;
      } 
  }

  void draw_axis_labels(int x1, int x2, int y1, int y2) {
    int curr_x = x1 + buffer_w/3;
    int curr_y = y1;
    float curr_time = time_min;


    textAlign(CENTER, CENTER);
    for (int i = 0; i < ports.length; i++) {
      fill(0);
      text(ports[i], curr_x + interval_w/2, curr_y + interval_h/2);
      curr_y += interval_h;
    }

    curr_x = buffer_w;

    for (int i = 0; i < num_intervals; i++) {
      curr_time = intervals[i];
      fill(0);
      textSize(10);
      translate(curr_x + interval_w/2, curr_y + buffer_h/2);
      rotate(PI/2);
      text(convert_time(curr_time), 0, 0);
      rotate(-PI/2);
      translate(-(curr_x + interval_w/2), -(curr_y + buffer_h/2));
      curr_x += interval_w;
    }
  }

  String convert_time(float total) {
    int hour, minutes, seconds;

    hour = floor(total/3600);
    minutes = floor(total%3600/60);
    seconds = floor(total%3600)%60;

    String s = str(hour) + ":" + str(minutes) + ":" + str(seconds);

    return s;
  }
  /*  
   void print_hmap() {
   for (int i = 0; i < ports.length; i++) {
   print(ports[i], ": - ");
   for (int j = 0; j < num_intervals; j++) {
   print(hmap[i][j], " ");
   }
   print("\n"); 
   }
   }
   */
}


