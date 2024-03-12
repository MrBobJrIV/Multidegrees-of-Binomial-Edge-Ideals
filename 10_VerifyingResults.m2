-- Author: Ethan Leventhal
-- Date: Feb 26 2024
-- Purpose: Checking that the multidegree formulas I found for the paper are correct.
--     	    Most code here is from 9_NotationExploration


------------------------------------------------------------------------------------------
-- SET-UP CODE
------------------------------------------------------------------------------------------


-- *** Make a function to give the multidegree of a complete graph with n vertices
-- -- Be sure to use the following ring when doing computations with the results
R = QQ[t,s];
cm = n -> ( -- cm stands for complete multidegree
    sum(for i from 0 to n-1 list (t^i*s^(n-i-1)))
    );
-- *** Make a function to give the multidegree of the other variables when |S| = n
R = QQ[t,s];
om = n -> ( -- om stands for other multidegree
    (t*s)^n
    );
-- *** Make a function that calculates the multidegree for a certain S
-- -- Input a sequence (or nested sequences) with |S| as the first number the size of each connected component as the rest
tm = s -> ( -- tm stands for total multidegree
    s = deepSplice s;
    om s#0 * product(for i from 1 to #s-1 list (cm s#i))
    );


------------------------------------------------------------------------------------------
-- EXPLORATIONS
------------------------------------------------------------------------------------------


needsPackage "Graphs";
n = 5;


-- Star graphs
multidegree mbei EdgeIdeals$graph Graphs$edgeIdeal starGraph n
-- My formula
t*s


-- Horned complete graphs
G = completeGraph n;
G = addVertices(G, for i from n to 2*n-1 list (i));
G = addVertices(G, for i from 2*n to 3*n-1 list (i));
G = addEdges'(G, flatten for i from 0 to n-1 list {{i,n+i},{i,2*n+i}});
G = EdgeIdeals$graph Graphs$edgeIdeal G;
multidegree mbei G
-- My formula
n*t^(n+1)*s^(n-1)+(n+1)*t^n*s^n+n*t^(n-1)*s^(n+1)


-- Barbell graphs
multidegree mbei EdgeIdeals$graph Graphs$edgeIdeal barbellGraph n
-- My formula
(t^(2*n)-s^(2*n))/(t-s) + 2 * (t*s) * (t^n-s^n)/(t-s) * (t^(n-1)-s^(n-1))/(t-s)
-- or
sum(for i from 0 to 2*n-1 list ((1+2*min(i, 2*n-1-i))*t^i*s^(2*n-1-i)))


-- Cycle graphs
multidegree mbei EdgeIdeals$graph Graphs$edgeIdeal cycleGraph n
-- My formula
(t^n-s^n)/(t-s)


-- Wheel graphs
multidegree mbei EdgeIdeals$graph Graphs$edgeIdeal wheelGraph n
-- My formula
(t^n-s^n)/(t-s)


-- Friendship graphs
multidegree mbei EdgeIdeals$graph Graphs$edgeIdeal friendshipGraph n
-- My formula
(t*s)*((t^2-s^2)/(t-s))^n
-- or
sum(for i from 0 to n list ((binomial(n,i))*t^(i+1)*s^(n-i+1)))
