
/*
- find ultimate root
  - starting with first relation, check if parent is child of any other rel
    - if yes, set this as new root, starting back at beginning of array, check array for this id
    - if no, this is the ultimate root
    
loop through rel array, starting with first parent as ultimate root

int ult_root = relations[0].parent;

for ( int i = 0; i < relations.length; i++) {
   if (relations[i].child == ult_root) {
      ult_root = relations[i].parent;
      i = -1;
   } 
}
    
- make canvas for ultimate root, store as element in class


set_links(ult_root);

- search rels for it as parent
    - if found, recurse with child's id
    - if not found, is leaf
      - loop through leaf array to find and add leaf value
      
set_links
      
*/
