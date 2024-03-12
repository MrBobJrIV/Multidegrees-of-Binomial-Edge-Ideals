-- Author: Ethan Leventhal
-- Date: Sep 2023
-- Purpose: Useful processes I've discovered, kept here for future reference


-- *** Visualize a graph G
needsPackage "Visualize";
openPort "8080";
-- Make a graph from the Graphs constructor
G = Graphs$graph {{a,b},{a,c},{b,c}};
-- -- If you make a graph from the EdgeIdeal constructor, do the following instead
-- G = EdgeIdeals$graph {{a,b},{a,c},{b,c}};
-- G = visualize Graphs$graph EdgeIdeals$edges G;
-- Note that visualize accepts AND returns graphs of the Graphs type
G = visualize G;
coef({EdgeIdeals$graph Graphs$edgeIdeal G}, ShowZeros => false);
closePort();


-- *** Convert from EdgeIdeals type to Graph type
-- -- Note that my old method of using edges instead of matrix lost isolated vertices
G = Graphs$graph EdgeIdeals$adjacencyMatrix G;
-- *** Convert from Graph type to EdgeIdeals type
G = EdgeIdeals$graph Graphs$edgeIdeal G;


-- *** Store graphList in a file
"graphStorageFile" << toExternalString(graphList) << endl << close;
-- *** Read graphList from a file
graphList = value get "graphStorageFile";


-- *** Get all graphs of a given number of vertices
-- Define a ring to specify the number of vertices of the graph
R = QQ[a..f];
-- Create a list of all connected graphs with those vertices
graphList = generateGraphs(R, OnlyConnected => true);
-- Filter the list to only include graphs with certain properties
s = buildGraphFilter {"Regular" => true};
graphList = filterGraphs(graphList, s);


-- *** Make a list manually
R = QQ[a..f];
G = EdgeIdeals$graph {{a,b},{b,c},{c,d},{d,e},{e,f},{f,a}};
R = QQ[a..g];
H = EdgeIdeals$graph {{a,b},{b,c},{c,d},{d,e},{e,f},{f,g},{g,a}};
graphList = {G, H};


-- *** Make a list of path graphs with 2 to 7 vertices
graphList = for i from 2 to 7 list (
    R = QQ[x_1..x_i];
    EdgeIdeals$graph for j from 1 to i-1 list {x_j,x_(j+1)}
    );


-- *** Make a megalist of all graphs with 2 to 6 vertices
graphList = flatten for i in b..f list (
    R = QQ[a..i];
    generateGraphs(R, OnlyConnected => true)
    );


-- *** Find the vertices that are height-reducing and have n height-reducing neighbors
testHeightReducing = (G, n) -> (
    verticesList := vertices G;
    isHeightReducing := (G,v) -> (
    	numberOfComponents(G) + 1 < numberOfComponents(deleteVertex(G,v))
    	);
    -- Select the vertices which are heightReducers
    verticesListOfHeightReducers := select(verticesList, i -> isHeightReducing(G, i));
    -- Refine the list to only include height reducers that don't neighbor other height reducers
    select(verticesListOfHeightReducers, i -> n ==  #(neighbors(G,i) * set verticesListOfHeightReducers))
    );
