/*class NetworkView {
    ForceNode[] nodes;
    ForceRels[] relations;
    ForceGraph graph;
    
    NetworkView(Data data) {
        nodes = new ForceNode[0];
        relations = new ForceRels[0];
        
        for(int i = 0; i < data.events.length; i++) {
             // Checks destination IP
             if (node_exists(data.events[i].dest_ip) == -1 ) {
                 ForceNode node = new ForceNode(data.events[i].dest_ip);
                 nodes = append(nodes, 
             }  else {
                //stuff 
             }
             
             // Checks source IP
             if (node_exists(data.events[i].src_ip) == -1) {
                //stuff
             } else {
                //more stuff
             }  
        }
    }
    
    int node_exists(String IP) {
        //if it exists then return index. else return -1
    }
}*/
