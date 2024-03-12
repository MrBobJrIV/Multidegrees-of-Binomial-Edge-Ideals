 -- Author: Ethan Leventhal
-- Date: Oct 2023
-- Purpose: A file dedicated to finding which S give minimal primes with minimal height


------------------------------------------------------------------------------------------
-- SECTION ONE: Set-up code, to be run once at the beginning of the session
------------------------------------------------------------------------------------------


-- *** Import the packages we will need
needsPackage "Visualize"; -- Automatically loads Graphs and Posets, which we also need


-- *** This function calculates which subsets we actually need using our theories
-- -- This function expects the graph to be in the Graphs format, not the EdgeIdeals format
-- -- It removes subsets that contain a simplicial vertex (those with complete neighborhoods)
-- -- It removes subsets that are too big
improveSubsets = (G) -> (
    -- Store the list of vertices
    verticesList := vertices G;
    -- This sub-function determines if the neighbors of a vertex form a clique (a complete graph)
    isSimplicial := (G, v) -> (
    	N := toList neighbors(G, v);
	-- This is in an if statement because inducedSubgraph throws an error if N == {}
	if(#N != 0) then (
	    -- The neighborhood is complete iff the complement has no edges, i.e. has #N singletons
    	    numberOfComponents complementGraph inducedSubgraph(G, N) == #N
	    ) else (
	    -- If N == {}, meaning it is an isolated vertex, then consider it simplicial
	    true
	    )
    	);
    -- Get the list of vertices that are not simplicial
    verticesListWithoutSimplicials := select(verticesList, i -> not isSimplicial(G, i));
    -- Create a list of subsets of vertices that don't include simplicial vertices
    mySubsets := subsets verticesListWithoutSimplicials;
    -- Calculate (n-1)/2, because we can ignore S bigger than that
    maximumSize := floor((#verticesList-1)/2);
    -- List only the subsets that have an acceptable size
    select(mySubsets, i -> #i <= maximumSize)
    );


-- *** This function returns a hash table of pairs (subset, height of that subset in the graph)
-- -- This function expects the graph to be in the Graphs format, not the EdgeIdeals format
computeHeightsHashTable = (G, mySubsets) -> (
    -- Store the list of vertices
    verticesList := vertices G;
    -- This sub-function returns the height of a given subset
    heightOfS := S -> (
    	T := verticesList - set S;
	-- This is in an if statement because inducedSubgraph throws an error if T == {}
	if(#T != 0) then (
	    numComp := numberOfComponents(inducedSubgraph(G, T));
	    ) else (
	    numComp = 0;
	    );
	#S + #verticesList - numComp
    	);
    -- Create a list of pairs (subset, height) for all subsets
    hashTableList := for i from 0 to #mySubsets-1 list (
    	(mySubsets#i, heightOfS(mySubsets#i))
    	);
    -- Turn that list into a hash table
    hashTable(hashTableList)
    );


-- *** This function returns (sorted) the keys with minimum value in a hash table
keysWithMinValue = (myHashTable) -> (
    myList := {};
    minimum := min values myHashTable;
    scanPairs(myHashTable, (k,v) -> if v==minimum then (myList = append(myList, k)));
    sort myList
);


-- *** Make a function to draw the Hasse diagram for a graph
drawDiagram = (myHashTable) -> (
    -- Create poset using the subsets in the hash table (sorting so that the diagram looks nice)
    P := poset(sort keys myHashTable, isSubset);
    -- Relabel the diagram so that each subset is labeled by its height
    P = labelPoset(P, myHashTable);
    -- Visualize the diagram
    visualize(P, Warning => false);
    );


------------------------------------------------------------------------------------------
-- SECTION TWO: After setting up, use the following code to test examples!
------------------------------------------------------------------------------------------


-- *** Open a port to use for visualizations
openPort "8080";


-- *** Define the graph we want to study (using the constructor from Graphs, not EdgeIdeals)
G = graph {{a,b},{b,c},{c,a},{d,e},{e,f},{f,d},{f,c},{d,g}}; -- My go-to example
G = graph {{a,b},{b,c}}; -- Path graph
G = graph {{a,c},{b,c},{d,f},{e,f},{c,f}}; -- 2s on the ends
G = completeGraph 6; -- Complete graph
G = Graphs$graph EdgeIdeals$adjacencyMatrix (generateRandomGraphs(QQ[a..j], 1, 0.2))#0; -- Random graph


-- *** If you want, visualize the graph (and make changes!)
G = visualize G;


-- *** Choose how to define the subsets you want to use in the visualization
-- OPTION ONE: Create a list of all subsets of vertices
mySubsets = subsets vertices G;
-- OPTION TWO: Create a list of only the subsets we need to consider
mySubsets = improveSubsets(G);


-- *** Create a hash table of the height of all subsets of vertices in G
-- -- Note that computation time is linear with respect to the number of subsets
-- -- ... (which doubles when the number of vertices increases by one)
-- -- On Ethan's computer it takes 40 seconds for 15 vertices and all subsets
myHashTable = computeHeightsHashTable(G, mySubsets);


-- *** If you want, print the S with minimal height
scan(keysWithMinValue(myHashTable), i -> (<< i << endl));


-- *** Draw the diagram for the specified hash table of subsets and their heights
-- -- Note that the diagram is too big to be useful for graphs with more than 7 vertices
-- -- Sometimes Macaulay2 throws an error and puts you into the debugger.
-- -- ... You can tell because the input line says ii25 instead of i25.
-- -- ... Say "end" to leave the debugger.
drawDiagram(myHashTable);


-- *** Close the port when finished visualizing
closePort();


------------------------------------------------------------------------------------------
-- SECTION THREE: This code prints all minimal S for many graphs in a list
------------------------------------------------------------------------------------------


-- *** Choose how to create a list of graphs to check
-- OPTION ONE: Make all connected graphs of a given number of vertices
graphList = generateGraphs(QQ[a..f], OnlyConnected => true);
-- OPTION TWO: Make only trees (set the second parameter |E|=|V|-1)
graphList = generateGraphs(QQ[a..g], 6, OnlyConnected => true);


-- *** Loop through graphList and print all minimal S for each graph
for i from 0 to #graphList-1 do (
      G := Graphs$graph EdgeIdeals$adjacencyMatrix graphList#i;
      mySubsets := improveSubsets(G);
      myHashTable := computeHeightsHashTable(G, mySubsets);
      << i << "\t" << keysWithMinValue(myHashTable) << endl;
      );


-- *** Loop through graphList and print all minimal S for the graphs without {} minimal
for i from 0 to #graphList-1 do (
      G := Graphs$graph EdgeIdeals$adjacencyMatrix graphList#i;
      mySubsets := improveSubsets(G);
      myHashTable := computeHeightsHashTable(G, mySubsets);
      minS := keysWithMinValue(myHashTable);
      if(not(member({}, minS))) then (
      	  << i << "\t" << minS << endl;
      	  ) else continue;
      );



  

------------------------------------------------------------------------------------------
-- SECTION FOUR: Printing the lists of all heights
------------------------------------------------------------------------------------------


-- *** For each graph in the list, calculate the list of heights. Store the results in a big list
graphList = generateGraphs(QQ[a..d]);
bigList = for i from 0 to #graphList-1 list (
    G := Graphs$graph EdgeIdeals$adjacencyMatrix graphList#i;
    verticesList := vertices G;
    heightOfS := S -> (
    	T := verticesList - set S;
	if(#T != 0) then (
	    numComp := numberOfComponents(inducedSubgraph(G, T));
	    ) else (
	    numComp = 0;
	    );
	#S + #verticesList - numComp
    	);
    mySubsets := subsets vertices G;
    myHeightsList := for i from 0 to #mySubsets-1 list (
    	heightOfS(mySubsets#i)
    	);
    << myHeightsList << endl;
    myHeightsList
    );
-- Does every graph (up to isomorphism) have a unique diagram (i.e. unique list of heights)?
#bigList
#unique(bigList)
-- -- These numbers are the same, so it looks like it!


-- *** Print the subsets with heights and have the ability to...
-- ... add extra vertices that are skipped, so that the lists line up nicely
mySubsets = subsets {a,b,d};
moreSubsets = subsets {a,b,c,d};
for i from 0 to #moreSubsets-1 do (
    if(member(moreSubsets#i, mySubsets)) then (
	<< moreSubsets#i;
	) else (
	<< " no ";
	);
    )

-- unifnished
mySubsets = subsets {a,b,d};
moreSubsets = subsets {a,b,c,d};
for i from 0 to #moreSubsets-1 do (
    if(member(moreSubsets#i, mySubsets)) then (
	<< moreSubsets#i << "\t";
	) else (
	<< "\-\-\t";
	);
    )
