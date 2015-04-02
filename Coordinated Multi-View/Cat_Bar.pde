class Cat_Bar {
  String title;
  Event[] data_big;
  String[] data;
  int num_points;
  int index_key;

  float xl, xr;
  float yt, yb;
  float wid, hgt;

  int num_fields;
  String[] fields;

  color highlight_mouse;
  color highlight_message;

  Cat_Bar(Event[] parsed, String category, int _key) {
    xl = 0;
    xr = 0;
    yt = 0;
    yb = 0;
    wid = 0;
    hgt = 0;
    highlight_mouse = color(255, 200, 0);
    highlight_message = color(255, 170, 0);

    data_big = parsed;
    title = category;
    index_key = _key;

    num_points = data_big.length;
    data = new String[num_points];
    extract_data();

    num_fields = 0;
    fields = new String[0];
    find_fields();
  }

  void extract_data() {
    switch(index_key) {
    case 5: //Syslog priority
      for (int i = 0; i < num_points; i++) {
        data[i] = data_big[i].priority;
      }
      break;
    case 6: //Operation
      for (int i = 0; i < num_points; i++) {
        data[i] = data_big[i].operation;
      }
      break;
    case 7: //Protocol
      for (int i = 0; i < num_points; i++) {
        data[i] = data_big[i].protocol;
      }
      break;
    default:
      print("ERROR: Data headings not in expected format");
    }
  }

  void find_fields() {
    for (int i = 0; i < num_points; i++) {
      if (!member(data[i], fields)) {
        fields = append(fields, data[i]);
        num_fields++;
      }
    }
  }

  boolean member(String data, String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (data.equals(array[i])) {
        return true;
      }
    } 
    return false;
  }

  Message draw_graph(float xl, float xr, float yt, float yb, Message msg, Rect[] rs) {
    make_canvas(xl, xr, yt, yb); 
    print_header();
    msg = draw_bars(msg, rs);

    return msg;
  }

  void make_canvas(float _xl, float _xr, float _yt, float _yb) {
    yt = _yt;
    yb = _yb;
    xl = _xl;
    xr = _xr;

    wid = xr - xl;
    hgt = yb - yt;
  }

  void print_header() {
    textSize(10);
    fill(200, 0, 0);
    text(title, ((xl + xr) / 2), (yt - 12));
  }

  Message draw_bars(Message msg, Rect[] rs) {
    float run_top = yt;
    float temp_h = 0;

    for (int i = 0; i < num_fields; i++) {
      float field_percent = (count_occurrence(fields[i], data) / num_points);    
      temp_h = field_percent * hgt;

      //draw original rectangle
      if (num_fields == 1) {
        fill(0, 195, 255);
      } else {
        fill(map(i, 0, num_fields - 1, 0, 255), map(i, 0, num_fields - 1, 195, 0), map(i, 0, num_fields - 1, 255, 0));
      }

      rect(xl, run_top, wid, temp_h);

      //draw highlight rectangle on top          
      if (intersect(mouseX, mouseY, xl, xl + wid, run_top, run_top + temp_h) || rect_touch(rs, xl, xl+wid, run_top, run_top + temp_h)) {
        fill(highlight_mouse);
        msg = add_to_msg(fields[i], msg);
        rect(xl, run_top, wid, temp_h);
      } else {
        fill(highlight_message);
        msg = clear_from_msg(fields[i], msg);
        float highlight_percent = find_highlight(msg, fields[i]);
        float highlight_top = (1 - highlight_percent) * (temp_h) + run_top;
        rect(xl, highlight_top, wid, highlight_percent * temp_h);
      }

      //add chunk label
      fill(0, 0, 0);
      if (temp_h < 10) {
        text(fields[i], (xl + xr) / 2, run_top - 6);
      } else {
        text(fields[i], (xl + xr) / 2, run_top + (temp_h / 2));
      }

      //update for next chunk
      run_top += temp_h;
    }
    
    return msg;
  }

  float find_highlight(Message msg, String field) {
    int[] hl_ind = new int[0];
    int hl_count = 0;
    float chunk_count = count_occurrence(field, data);

    for (int i = 0; i < num_points; i++) {
      //determine if point even falls into chunk
      switch(index_key) {
      case 5: //Syslog priority
        if (field.equals(data_big[i].priority)) {
          hl_ind = append(hl_ind, i);
        }
        break;
      case 6: //Operation
        if (field.equals(data_big[i].operation)) {
          hl_ind = append(hl_ind, i);
        }
        break;
      case 7: //Protocol
        if (field.equals(data_big[i].protocol)) {
          hl_ind = append(hl_ind, i);
        }
        break;
      }
    } 
    
    //if in chunk, check if in message
    if (hl_ind.length > 0) {
      for(int i = 0; i < hl_ind.length; i++) {
        
        if(pass_heat(data_big[hl_ind[i]], msg.time, msg.dest_port) || 
           pass_net(data_big[hl_ind[i]], msg.src_ip, msg.dest_ip)) {
          
             hl_count++;
        }
      }
    }
    return hl_count / chunk_count;
  }
  
  boolean pass_heat(Event e, float[] time, String[] dest_port) {
    if(time.length == 0 && dest_port.length == 0) {
      return false;
    } else {
      return ((is_in_array_flt(e.time, time) && is_in_array(e.dest_port, dest_port)));
    }
  }
  
  boolean pass_net(Event e, String[] src_ip, String[] dest_ip) {
    if(src_ip.length == 0 && dest_ip.length == 0) {
      return false;
    } else {
      return ((is_in_array(e.src_ip, src_ip)) || (is_in_array(e.dest_ip, dest_ip)));
    }
  }
  
  boolean is_in_array_flt(float val, float[] arr) {
    for(int i = 0; i < arr.length; i++) {
      if(val == arr[i]) {
        return true;
      }
    }
    return false; 
  }
  
  boolean is_in_array(String val, String[] arr) {
    for(int i = 0; i < arr.length; i++) {
      if(val.equals(arr[i])) {
        return true;
      }
    }
    return false;
  }

  float count_occurrence(String s, String[] array) {
    float count = 0;
    for (int i = 0; i < num_points; i++) {
      if (s.equals(array[i])) {
        count++;
      }
    } 

    return count;
  }

  boolean intersect(int xp, int yp, float xl, float xr, float yt, float yb) {
    if ((xp > xl) && (xp < xr)) {
      if ((yp > yt) && (yp < yb)) {
        return true;
      }
    }

    return false;
  }
  
  boolean rect_touch(Rect[] rs, float xl, float xr, float yt, float yb) {
    boolean touching = false;
    for(int i = 0; i < rs.length; i++) {
      if(!(rs[i].xleft > xr || rs[i].xright < xl || rs[i].ytop > yb || rs[i].ybot < yt)) {
        touching = true;
      }
    }
         
    return touching;
  }
  
  Message add_to_msg(String name, Message msg) {
    switch(index_key) {
      case 5: //Syslog priority
        //msg.priority = new String[0];
        msg.priority = append(msg.priority, name);
        break;
      case 6: //Operation
        //msg.operation = new String[0];
        msg.operation = append(msg.operation, name);
        break;
      case 7: //Protocol
        //msg.protocol = new String[0];
        msg.protocol = append(msg.protocol, name);
        break;
    }
      
    return msg;
  }
  
  Message clear_from_msg(String name, Message msg) {
    switch(index_key) {
      case 5: //Syslog priority
        String[] temp = new String[0];
        for(int i = 0; i < msg.priority.length; i++) {
          if(msg.priority[i] != name) {
            temp = append(temp, msg.priority[i]);
          }
        }
        msg.priority = temp;
        break;
      case 6: //Operation
        String[] temp2 = new String[0];
        for(int i = 0; i < msg.operation.length; i++) {
          if(msg.operation[i] != name) {
            temp2 = append(temp2, msg.operation[i]);
          }
        }
        msg.operation = temp2;
        break;
      case 7: //Protocol
        String[] temp3 = new String[0];
        for(int i = 0; i < msg.protocol.length; i++) {
          if(msg.protocol[i] != name) {
            temp3 = append(temp3, msg.protocol[i]);
          }
        }
        msg.protocol = temp3;
        break;
    }
      
    return msg;
  }
  
}

