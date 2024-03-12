-- Author: Ethan Leventhal
-- Date: Sep 2023
-- Purpose: A walkthrough in Macaulay2 for how to calculate the multidegree of a graph...
    	 -- ... by combining the multidegrees of its minimal prime ideals
         -- (Before using this file, run all set-up code in 3_GraphToMultidegree.m2)


-- *** First we will walk through part of the example we did with Montano
-- We'll use the path graph with four vertices
numVertices = 4;
R = QQ[a..d];
G = EdgeIdeals$graph {{a,b},{b,c},{c,d}}


-- *** Let's calculate the height of the prime ideal P_G corresponding to a certain S
-- Pick a subset S of the set of vertices (flatten entries vars R)
S = {b}
-- Remove those vertices (and all of its edges) from the graph
T = flatten entries vars R - set S
newG = inducedGraph(G, T)
-- Get the number of connected components of the new graph
numComp = #connectedGraphComponents(newG)
-- Find the height = |S| + (n - c(G_T))
heightForThePrimeIdealOfThatS = #S + (numVertices - numComp)


-- *** Next we can find P_S(G) for S = {b}
S = {b}
-- First, remove the points in S from the graph
T = flatten entries vars R - set S
newG = inducedGraph(G, T, OriginalRing => true)
-- Then take each connected component in the new graph...
componentList = connectedGraphComponents(newG)
-- ... but ignore the vertex we removed...
-- (in the general code below I actually skip this step; see the comment there for explanation)
componentList = componentList - set {S}
-- ... and complete them
completedList = for i from 0 to #componentList-1 list (
    completeGraph componentList#i
    )
-- Now make ideals from those components
idealList = for i from 0 to #completedList-1 list (
    mbei completedList#i
    )
-- Also make an ideal out of the variables in S
variablesinS = flatten apply(S,i -> {x_i,y_i})
idealOfOtherVariables = ideal(variablesinS)
-- Now add the ideals of the components and the bonus variables to get the final ideal
idealOfS = idealOfOtherVariables + sum(idealList)
-- And for fun, we can look at the multidegree!
multidegree(idealOfS)
-- This gives us the multidegree of one of the prime ideals of G!
-- To find the multidegree of G, we would repeat this process for all prime ideals with minimal height.


------------------------------------------------------------------------------------------


-- *** Now we will repeat the above steps in general to find the multidegree of G!
-- First, define the graph
-- numVertices = 9;
-- R = QQ[a..i];
-- G = EdgeIdeals$graph {{a,c},{b,c},{d,f},{e,f},{g,i},{h,i},{c,f},{f,i},{i,c}}
numVertices = 6;
R = QQ[a..f];
G = EdgeIdeals$graph {{a,c},{b,c},{d,f},{e,f},{c,f}}
-- numVertices = 11;
-- R = QQ[a..k];
-- G = EdgeIdeals$graph {{a,b},{a,c},{a,d},{b,c},{b,d},{c,d},{c,e},{e,d},{a,f},{a,g},{b,f},{b,g},{f,g},{g,h},{h,f},{a,i},{a,j},{b,i},{b,j},{i,j},{j,k},{k,i}}
numVertices = 6;
R = QQ[a..f];
G = EdgeIdeals$graph {{a,d},{b,e},{a,f},{b,f},{c,f}};



-- *** Find the height of P_S(G) for all possible subsets S of vertices
allSubsets = subsets flatten entries vars R;
allHeights = for i from 0 to #allSubsets-1 list (
    S = allSubsets#i;
    T = flatten entries vars R - set S;
    newG = inducedGraph(G, T);
    numComp = #connectedGraphComponents(newG);
    #S + (numVertices - numComp)
    )


-- *** Find which S give the lowest height
minHeight = min(allHeights)
minHeightSList = allSubsets_(positions(allHeights, i -> i == minHeight))


-- *** Find the multidegree of P_S(G) for all S that gave the minimum height
allMultidegrees = for i from 0 to #minHeightSList-1 list (
    S = minHeightSList#i;
    T = flatten entries vars R - set S;
    newG = inducedGraph(G, T, OriginalRing => true);
    componentList = connectedGraphComponents(newG);
    -- This next line doesn't work because the elements of componentList are lists while those in S are not
    -- However, we don't actually need to remove the points in S because they are singletons...
    -- ... so they only contribute zero ideals to the result, which don't matter
    -- So I have commented it out
    -- componentList = componentList - set {S};
    completedList = for i from 0 to #componentList-1 list (
    	completeGraph componentList#i
    	);
    idealList = for i from 0 to #completedList-1 list (
    	mbei completedList#i
    	);
    variablesinS = flatten apply(S,i -> {x_i,y_i});
    idealOfOtherVariables = ideal(variablesinS);
    -- Macaulay2 struggles to add these ideals (issues with "different" rings), so the following doesn't always work
    -- -- idealOfS = idealOfOtherVariables + sum(idealList);
    -- -- multidegree idealOfS
    -- Instead of adding the ideals and getting the multidegree,
    -- ... we can find the multidegrees and then multiply them to get the same result!
    -- This works because, as I discovered, the multidegree of a graph with disjoint components...
    -- ... is equal to the product of the multidegrees of each component.
    -- Macaulay2 cannot take the multidegree of the empty ideal, so to avoid issues...
    -- ... we skip the components that have just one vertex
    theseMultidegrees = for j from 0 to #completedList-1 list (
	if(#(componentList#j) == 1) then continue else multidegree(mbei completedList#j)
	);
    -- ... and we ignore the idealOfOtherVariables when there are no other variables
    multidegreeOfOtherVariables = if (#variablesinS == 0) then 1 else multidegree(idealOfOtherVariables);
    -- As explained above, now we just multiply them all together to get the final multidegree!
    -- Note that all coefficients of these multidegrees are ones...
    --- ... but their product is NOT necessarily all ones.
    multidegreeOfOtherVariables*product(theseMultidegrees)
)


-- *** Finally, you add all of the multidegrees together to get the multidegree of G
sum(allMultidegrees)


-- *** Tada, we are done! That was the very long way to do the following:
multidegree mbei G


------------------------------------------------------------------------------------------


-- *** Remarks and questions are now in the google doc :D


-- *** Just some testing, to list the minHeightSList for each graph in graphList...
-- ... to see which ones have S = {} in the list and which do not
R = QQ[a..f];
graphList = generateGraphs(R, OnlyConnected => true);
allSubsets = subsets flatten entries vars R;
verticesList = flatten entries vars R;
allSubsets = subsets verticesList;
for i from 0 to #graphList-1 do (
      G = graphList#i;
      allHeights = for j from 0 to #allSubsets-1 list (
          S = allSubsets#j;
          T = verticesList - set S;
          newG = inducedGraph(G, T);
          numComp = #connectedGraphComponents(newG);
          #S + #verticesList - numComp
          );
      minHeight = min(allHeights);
      minHeightSList = allSubsets_(positions(allHeights, j -> j == minHeight));
      << i
      -- I am not printing multidegree degree because it is equal to minHeight
      -- << "\t Multideg: " << degree multidegree mbei graphList#i;
--      << "\t minHeight: " << minHeight;
--      (M,C) = coefficients multidegree mbei graphList#i;
--      << "\t isMultFree: " << (max entries C_0 == 1);
      << "\t minHeightList: " << minHeightSList << endl;
      );


-- *** The tm() function and related explorations have been moved to their own file!
