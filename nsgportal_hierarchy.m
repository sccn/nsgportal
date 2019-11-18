digraph G {
    graph [fontname = "helvetica"];
    node [fontname = "helvetica"];
    edge [fontname = "helvetica"];
             
	 edge [color=grey, style=dashed] //All the lines look like this
     size="11,11"
     ratio=compress;
     rankdir=LR;
     concentrate=true;
     
    subgraph plugin {
            compound=true;
         	node [color=lightgrey];
         	eegplugin_nsgportal [shape=box, fontsize=18,  width = 2, height=.5];
        label = "Plugin management";
     }
     
     subgraph cluster0 {
            compound=true;
         	node [color=lightgrey];
         	pop_nsg             [shape=box, fontsize=18,  width = 2, height=.5];
         	pop_nsginfo         [shape=box, fontsize=18,  width = 2, height=.5];
            label = "nsgportal interface";
     }
     
	subgraph cluster1 {
		color=lightgrey;
		compound=true;
		{rank=sink "pop_nsg('update')" "pop_nsg('loadplot')" "pop_nsg('rescan')" "pop_nsg('deletegui')" "pop_nsg('stdout')" "pop_nsg('stderr')" "pop_nsg('stderr')" "pop_nsg('testgui')" "pop_nsg('rungui')" "pop_nsg('outputgui')" "pop_nsg('autorescan)" "listzipcontents" };
		node [style=filled,color=lightgrey fixedsize=true];
		    "GUI call" [shape=oval, width = 2, height=.6, fontsize=16];
    		"pop_nsg('update')"    [shape=box,  width = 2, height=.5];
    		"pop_nsg('loadplot')"  [shape=box,  width = 2, height=.5]; 
    		"pop_nsg('rescan')"    [shape=box,  width = 2, height=.5];
    		"pop_nsg('rescan')"    [shape=box,  width = 2, height=.5];
    		"pop_nsg('deletegui')" [shape=box,  width = 2, height=.5];
    		"pop_nsg('stdout')"    [shape=box,  width = 2, height=.5];
    		"pop_nsg('stderr')"    [shape=box,  width = 2, height=.5];
    		"pop_nsg('testgui')"   [shape=box,  width = 2, height=.5];
    		"pop_nsg('rungui')"    [shape=box,  width = 2, height=.5];
    		"pop_nsg('outputgui')" [shape=box,  width = 2, height=.5];
    		"pop_nsg('autorescan)" [shape=box,  width = 2, height=.5];
    		"listzipcontents"      [shape=box,  width = 2, height=.5];
	 }

	subgraph cluster2 {
	    compound=true;
	    color=lightgrey;
	    {rank=sink "pop_nsg('delete')"  "pop_nsg('output')" "pop_nsg('test')" "pop_nsg('run')"}
		node [style=filled, fixedsize=true];
		    "Command-line call" [shape=oval, width=2, height=.7, fontsize=16, color=lightgrey]; //color=white
    		"pop_nsg('delete')" [shape=box,width=1.8, height=.5];
    		"pop_nsg('output')" [shape=box,width=1.8, height=.5];
    		"pop_nsg('test')"   [shape=box,width=1.8, height=.5];
    		"pop_nsg('run')"    [shape=box,width=1.8, height=.5];
	 }

	subgraph cluster3 {
	    compound=true;
	    decorate= true;
	    {rank=same "nsg_jobs" "nsg_getjobid" "nsg_run" "nsg_info" "nsg_findclientjoburl" "nsg_delete" "nsg_test" "nsg_recurspoll" "isnsgurl" "listzipcontents" "nsg_checknet" "nsg_uilistfiles"}
		color=lightgrey;
		node [style=filled, color=lightgrey, fixedsize=true fontsize=16];
    		"nsg_jobs"               [shape=box, width=2.2, height=.5];
            "nsg_getjobid"           [shape=box, width=2.2, height=.5];
            "nsg_run"                [shape=box, width=2.2, height=.5];
            "nsg_info"               [shape=box, width=2.2, height=.5];
            "nsg_findclientjoburl"   [shape=box, width=2.2, height=.5];
            "nsg_delete"             [shape=box, width=2.2, height=.5];
            "nsg_test"               [shape=box, width=2.2, height=.5];
            "nsg_recurspoll"         [shape=box, width=2.2, height=.5];
            "isnsgurl"               [shape=box, width=2.2, height=.5];
           
            "nsg_checknet"           [shape=box, width=2.2, height=.5];
            "nsg_uilistfiles"        [shape=box, width=2.2, height=.5];
            subgraph cluster4 {
                compound=true;
	            decorate= true;
	            {rank=same  "removeTextTag" "xml2struct" }//"parseXML"
                //"parseXML"               [shape=box, width=2.2, height=.5];
                "removeTextTag"          [shape=box, width=2.2, height=.5];
                "xml2struct"             [shape=box, width=2.2, height=.5];
            }
		label = "Low-level functions";
	 }
	
pop_nsg -> "GUI call" [lhead=cluster1, ltail=cluster0];
pop_nsg -> "Command-line call" [lhead=cluster2, ltail=cluster0 weight=10];

"GUI call" -> {"pop_nsg('update')" "pop_nsg('loadplot')" "pop_nsg('rescan')" "pop_nsg('deletegui')" "pop_nsg('stdout')" "pop_nsg('stderr')" "pop_nsg('stderr')" "pop_nsg('testgui')" "pop_nsg('rungui')" "pop_nsg('outputgui')" "listzipcontents" }
"Command-line call" -> {"pop_nsg('delete')"  "pop_nsg('output')" "pop_nsg('test')" "pop_nsg('run')"};

# eegplugin_nsgportal
eegplugin_nsgportal -> pop_nsg;
eegplugin_nsgportal -> pop_nsginfo;

# isnsgurl

# listzipcontents

# nsg_checknet

# nsg_delete
nsg_delete -> nsg_info;

# nsg_findclientjoburl
nsg_findclientjoburl -> nsg_jobs;

# nsg_getjobid
nsg_getjobid -> nsg_jobs;

# nsg_info

# nsg_jobs
nsg_jobs   -> nsg_info;
nsg_jobs   -> removeTextTag;
nsg_jobs   -> xml2struct;
"GUI call" -> nsg_jobs;

# nsg_recurspoll
nsg_recurspoll -> isnsgurl;
nsg_recurspoll -> nsg_findclientjoburl;
nsg_recurspoll -> nsg_jobs;

# nsg_run
nsg_run -> nsg_info;
nsg_run -> nsg_findclientjoburl;

# nsg_test
nsg_test -> nsg_info;
nsg_test -> nsg_test;

# nsg_uilistfiles

# pop_nsg
pop_nsg -> nsg_checknet;
"GUI call"             -> nsg_getjobid;
"GUI call"             -> nsg_jobs;
"Command-line call"    -> isnsgurl;
"Command-line call"    -> nsg_findclientjoburl;
"pop_nsg('delete')"    -> {nsg_delete, nsg_findclientjoburl, nsg_jobs};
"pop_nsg('output')"    -> nsg_findclientjoburl;
"pop_nsg('loadplot')"  -> {nsg_info,nsg_uilistfiles,nsg_jobs};
"pop_nsg('run')"       -> nsg_run;
"pop_nsg('test')"      -> nsg_test;
"pop_nsg('autorescan)" -> "pop_nsg('rescan')";
"pop_nsg('rescan')"    -> {"pop_nsg('update')", nsg_jobs};
"pop_nsg('deletegui')" -> {"pop_nsg('delete')", "pop_nsg('rescan')"};
"pop_nsg('outputgui')" -> "pop_nsg('output')";
"pop_nsg('testgui')"   -> "pop_nsg('test')";        
"pop_nsg('rungui')"    -> {"pop_nsg('run')", "pop_nsg('rescan')"};  

"pop_nsg('stdout')"   -> nsg_jobs;
"pop_nsg('stderr')"   -> nsg_jobs;
"pop_nsg('output')"   -> nsg_jobs;
"pop_nsg('run')"      -> nsg_jobs;
"Command-line call"   -> nsg_jobs;
# pop_nsginfo
pop_nsginfo -> nsg_info;

# removeTextTag
removeTextTag->removeTextTag;

# xml2struct
xml2struct -> xml2struct;

}