-- Author: Ethan Leventhal
-- Date: Nov 2023
-- Purpose: Building and using tm() notation to describe the multidegree of graphs


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


-- *** Function to give the coefficient of t^i (also s^i) for the tm(s,K)
coefOfTM = inputK -> (
    K := deepSplice inputK;
    -- The first number is i
    i := K#0;
    -- The second number is |S|
    sizeOfS := K#1;
    -- The rest are K
    K = toList drop(K,{0,1});
    -- Shift the coefficient we want by s
    i = i - sizeOfS;
    -- Get all subsets of K
    subsetsOfK := subsets K;
    -- Initialize the sum to be 0
    SUM := 0;
    -- For each subset...
    for j in subsetsOfK do (
	-- Get the sum of the numbers in the subset
    	sumOfJ := sum(j);
    	-- If statement makes the binomial be 0 when the top is negative
    	-- -- (Macaulay2 is too smart and evaluates when the first number is negative!)
    	thisBinomial := if(i-sumOfJ+#K-1 < 0) then 0 else binomial(i-sumOfJ+#K-1,#K-1);
	-- Increase the sum according to the formula I came up with
    	SUM = SUM + ((-1)^#j)*thisBinomial;
	-- Print some info!
	<< j << "\t" << ((-1)^#j) << "\tC(" << i-sumOfJ+#K-1 << "," << #K-1 << ") = " << thisBinomial << endl;
    	);
    SUM
    )


------------------------------------------------------------------------------------------
-- EXPLORATIONS
------------------------------------------------------------------------------------------


-- *** A short bit of code to verify the multidegree of a graph
needsPackage "Graphs";
G = starGraph 7;
G = EdgeIdeals$graph Graphs$edgeIdeal G;
multidegree(mbei(G))


-- *** Examples of calculating multidegrees
n = 6;
m = 6;
tm(1,n:1) -- Star graph
tm(0,n) -- Cycle graph
tm(n,(2*n):1)+n*tm(n-1,3,(2*n-2):1) -- Horned complete graph
tm(0,2*n)+tm(1,n,n-1)+tm(1,n,n-1) -- Barbell graph
tm(0,n+m)+tm(1,n,m-1)+tm(1,m,n-1) -- Barbell graph with two different size bells
tm(0,5)+2*tm(1,3,1)+tm(1,2,2)+tm(2,1,1,1) -- Path graph with 5 vertices
tm(1,n:2) -- Friendship graph (as long as n is bigger than 2)


-- *** Barbell graph with arbitrarily many bells of arbitrary size
-- Define the sizes of the bells (and implicitly, the number of bells)
B = (7,1,7,7,7,7);
-- Get all proper subsets of bells
S = apply(drop(subsets(toList B),-1), i -> toSequence i);
-- Calculate the multidegree for each subset using the formula I came up with in the LaTeX doc
M = for i in S list (
    tm(#i, apply(i, j -> j-1), sum(toList B) - sum(toList i))
    );
-- Sum the multidegrees for all subsets to get the multidegree of the whole thing
sum(M)


-- *** Why does this specific sum of compositions give the Fibonacci numbers?
-- The proof is on the Wikipedia page for the Fibonacci sequence!
n = 6;
SUM = 0;
for i from 0 to floor((n-1)/2) do (
    SUM = SUM + binomial(n-i-1,i)
    )
SUM -- This will equal the (n-1)th Fibonacci number


-- Verifying my coefOfTM() formula
tm(0,2,3,4)
coefOfTM(4,0,2,3,4)
tm(2,2,3,4)
coefOfTM(7,2,2,3,4)
tm(0,13,4,56,2,3,1)
coefOfTM(5,0,13,4,56,2,3,1)
coefOfTM(5,2,13,4,56,2,3,1)


-- Finding the coefficient of t^3 in the multidegree of a path graph with seven vertices
coefOfTM(3,0,7)
coefOfTM(3,1,1,5)
coefOfTM(3,1,2,4)
coefOfTM(3,1,3,3)
coefOfTM(3,1,4,2)
coefOfTM(3,1,5,1)
coefOfTM(3,2,1,1,3)
coefOfTM(3,2,1,3,1)
coefOfTM(3,2,3,1,1)
coefOfTM(3,2,1,2,2)
coefOfTM(3,2,2,1,2)
coefOfTM(3,2,2,2,1)
coefOfTM(3,3,1,1,1,1)


-- Finding the coefficient in the multidegree of a path graph
n = 7; -- Number of vertices
i = 3; -- Desired coefficient
sum flatten for sizeOfS from 0 to floor((n-1)/2) list (
    K = select(compositions(sizeOfS+1, n-sizeOfS), comp -> all(comp, c -> c>0));
    for k in K list (
	k = toSequence k;
	coefOfTM(i,sizeOfS,k)
    	)
    )

coefOfTM(3,0,2,3,4,5)
coefOfTM(8,0,7,19,6,5)



n = 6;
m = 6;
tm(0,n+m)+tm(1,n,m-1)+tm(1,m,n-1)
m = 7;
tm(0,n+m)+tm(1,n,m-1)+tm(1,m,n-1)
m = 8;
tm(0,n+m)+tm(1,n,m-1)+tm(1,m,n-1)
m = 9;
tm(0,n+m)+tm(1,n,m-1)+tm(1,m,n-1)
m = 10;
tm(0,n+m)+tm(1,n,m-1)+tm(1,m,n-1)
