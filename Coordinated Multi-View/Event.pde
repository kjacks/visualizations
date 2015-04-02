class Event {
     float time;
     String src_ip;
     String src_port;
     String dest_ip;
     String dest_port;
     String priority;
     String operation;
     String protocol;
     
     Event(float t, String sip, String sport, String dip, 
           String deport, String prior, String op, String proto) {
         time = t;
         src_ip = sip;
         src_port = sport;
         dest_ip = dip;
         dest_port = deport;
         priority = prior;
         operation = op;
         protocol = proto;     
     }
}
