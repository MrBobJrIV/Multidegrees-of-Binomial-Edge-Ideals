-- Author: Ethan Leventhal
-- Date: Sep 2023
-- Purpose: Testing conjectures for Montano!
         -- (Before using this file, run all set-up code in 3_GraphToMultidegree.m2)


-- *** Get all chordal graphs
R = QQ[a..f];
graphList = generateGraphs(R, OnlyConnected => true);
graphList = for i from 0 to #graphList-1 list (
    if EdgeIdeals$isChordal(graphList#i) then graphList#i else continue
    );
coef(graphList);


-- *** Get all planar graphs
R = QQ[a..g];
graphList = generateGraphs(R, OnlyConnected => true);
graphList = onlyPlanar(graphList, true);
graphList = apply(graphList, i -> stringToGraph(i, R));
coef(graphList);


-- *** Count the number of multipicity-free graphs (multiplicities that only contain zeros and ones)
-- I calculated up to h (8 vetices)
R = QQ[a..e];
graphList = generateGraphs(R, OnlyConnected => true);
#graphList
count = 0;
for i from 0 to #graphList-1 do (
    (M,C) = coefficients(multidegree mbei graphList#i, Monomials=>monomialList);
    if(max entries C_0 == 1) then count = count + 1;
    );
count


-- *** List the graphs with minimum nonzero coefficient greater than 1
-- I calculated up to h (8 vertices)
R = QQ[a..h];
graphList = generateGraphs(R, OnlyConnected => true);
#graphList
-- Make an arbitrary graph to get the correct "one" element
QQ[a..b];
(M,C) = coefficients multidegree mbei EdgeIdeals$graph {{a,b}};
one = (entries C_0)_0;
-- Loop to get desired graphs
graphList = for i from 0 to #graphList-1 list (
    (M,C) = coefficients(multidegree mbei graphList#i, Monomials=>monomialList);
    if(not(member(one,entries C_0))) then graphList#i else continue
    );
coef(graphList);


-- *** Compare the multidegrees of a graph and its complement
R = QQ[a..e];
graphList = generateGraphs(R, OnlyConnected => true);
graphList = flatten for i from 0 to #graphList-1 list (
    {graphList#i, EdgeIdeals$complementGraph(graphList#i)}
    );
coef(graphList);


-- *** Examine multidegrees of graphs with certain properties using Nauty
R = QQ[a..f];
graphList = generateGraphs(R, OnlyConnected => true);
s = buildGraphFilter {"Regular" => true};
graphList = filterGraphs(graphList, s);
coef(graphList);


-- *** Examine multidegrees of graphs with certain properties using Graphs
needsPackage "Graphs";
R = QQ[a..f];
graphList = generateGraphs(R, OnlyConnected => true);
graphList = for i from 0 to #graphList-1 list (
    if(isTree(Graphs$graph EdgeIdeals$edges graphList#i)) then graphList#i else continue
    );
coef(graphList);


-- *** Examine multidegrees of certain types of graphs using Graphs
needsPackage "Graphs";
graphList = for n from 2 to 10 list (
    EdgeIdeals$graph Graphs$edgeIdeal lollipopGraph n
    );
-- Using optional argument of coef() because I don't know how many vertices the graphs will have
coef(graphList, ShowZeros => false);


-- *** Examine what happens when we add/remove edges to a graph
R = QQ[a..e];
graphList = generateGraphs(R, OnlyConnected => true);
for i from 0 to #graphList-1 do (
    coef({graphList#i});
    coef(addEdges graphList#i);
    << endl;
    );


-- *** List the graphs with the same multidegree as graph G
-- View and pick which graph is G
R = QQ[a..f];
graphList = generateGraphs(R, OnlyConnected => true);
coef(graphList);
G = graphList#8
-- Get the multidegree of G and then loop through the list to find all matching graphs
(M,myCoefficients) = coefficients(multidegree mbei G, Monomials=>monomialList);
graphList = for i from 0 to #graphList-1 list (
    (M,C) = coefficients(multidegree mbei graphList#i, Monomials=>monomialList);
    if (C == myCoefficients) then graphList#i else continue
    );
coef(graphList);


-- *** Sort the list of graphs by multidegree
R = QQ[a..f];
graphList = generateGraphs(R, OnlyConnected => true);
tempList = for i from 0 to #graphList-1 list (
    (M,C) = coefficients(multidegree mbei graphList#i, Monomials=>monomialList);
    {flatten entries C, i}
    );
tempList = sort(tempList);
graphList = apply(tempList, i -> graphList_(i_1));
coef(graphList);


-- *** List the graphs with zeros where we expect ones
R = QQ[a..g];
graphList = generateGraphs(R, OnlyConnected => true);
graphList = for i from 0 to #graphList-1 list (
    thisMultidegree = multidegree mbei graphList#i;
    (M,C) = coefficients(thisMultidegree);
    if ((degree thisMultidegree)#0 - 1 > #(entries C)) then graphList#i else continue
    );
coef(graphList);


-- *** What if we look at disconnected graphs?
R = QQ[a..f];
graphList = generateGraphs(R) - set generateGraphs(R, OnlyConnected => true);
-- Remove the first graph in the list, which has no edges
graphList = drop(graphList, 1);
coef(graphList);
-- Here's the list of connected graphs for comparison
graphList = generateGraphs(R, OnlyConnected => true);
coef(graphList);
#graphList


-- *** Take the disjoint union of two graphs
needsPackage "Graphs";
R = QQ[a..d];
graphList = generateGraphs(R, OnlyConnected => true);
coef(graphList);
-- Get graphs (in EdgeIdeals format)
H = graphList#1;
G = graphList#2;
-- Change them to Graphs format
H = Graphs$graph EdgeIdeals$edges H;
G = Graphs$graph EdgeIdeals$edges G;
-- Get the union
I = disjointUnion({H, G});
-- Change all back to EdgeIdeals format
H = EdgeIdeals$graph Graphs$edgeIdeal H;
G = EdgeIdeals$graph Graphs$edgeIdeal G;
I = EdgeIdeals$graph Graphs$edgeIdeal I;
-- Get coefficients
-- Keep in mind the union will have more vertices, so extend monomialList accordingly...
coef({H,G,I});
-- ... or use the optional argument of coef() to ignore zeros
coef({H,G,I}, ShowZeros => false);
