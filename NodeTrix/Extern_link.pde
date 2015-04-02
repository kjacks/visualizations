class Extern_link {
   String local_name;
   String foreign_name;
   int foreign_id;
   
   Extern_link(int for_node, String loc_name, String for_name) {
       local_name = loc_name;
       foreign_name = for_name;
       foreign_id = for_node;
   }
   
   void print_link() {
       print(local_name, " ", foreign_name, " ", foreign_id, "\n");
   }
}
