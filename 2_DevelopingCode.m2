-- Import the Nauty package to create and use graphs
-- Note this also automatically also installs EdgeIdeals, SimplicialComplexes, Polyhedra, and FourTiTwo
needsPackage "Nauty";


-- This method was taken and modified from the BinomialEdgeIdeal package source code
-- It returns the multidegree of a graph (with the correct grading so that x's and y's are counted separately)
xx:=vars(23);
yy:=vars(24);
mbei = method (Options => {Field=>QQ,TermOrder=>Lex,Permanental=>false});
mbei List := Ideal => opts -> E -> (mbei(graph E,opts));
mbei Graph := Ideal => opts -> G -> (
v:=vertices(G);
c:=0;
e:=apply(edges(G),toList);
R:=(opts.Field)[(for vv in v list xx_(vv))|(for vv in v list yy_(vv)),
    MonomialOrder=>opts.TermOrder,
    Degrees=>(for vv in v list {1,0})|(for vv in v list {0,1})]; -- This is the added line
if opts.Permanental then c=1 else c=-1;
return ideal for ee in e list (xx_(ee_0))_R*(yy_(ee_1))_R+c*(yy_(ee_0))_R*(xx_(ee_1))_R;
);


-- Define a ring to specify the number of vertices
R = QQ[a..f];
-- Create a list of all connected graphs with those vertices
graphList = generateGraphs(R, OnlyConnected => true);
-- Get the number of graphs
numGraphs = #graphList;
-- -- Filter the list to only include graphs with certain properties
-- s = buildGraphFilter {"Diameter" => 2};
-- graphList = filterGraphs(graphList, s);
-- Create a list of the multidegrees of each graph
multidegreeList = for g in graphList list (multidegree(mbei(g)));

-- -- Create a list of just the coefficients of those multidegrees
-- -- Only shows nonzero coefficients; use the procedure below to see all coefficients
-- coefficientList = for i in multidegreesList list ((M,C) = coefficients(i); print transpose matrix C_0);

-- -- Create a list of all monomials that appear in the list
-- -- OUTDATED i did it better below so that you don't need to have the graphs beforehand
-- step1 = apply(multidegreeList, monomials);
-- step2 = apply(step1, entries);
-- step3 = apply(step2, flatten);
-- step4 = flatten step3;
-- monomialList = unique step4;
-- print monomialList;
-- Create a list of the coefficients of those multidegrees, including the zero coefficients!
coefficientList = for i from 0 to numGraphs-1 list (
    (M,C) = coefficients(multidegreeList#i, Monomials=>monomialList);
    transpose matrix C_0
    ) do (
    (M,C) = coefficients(multidegreeList#i, Monomials=>monomialList);
    << "Graph " << i << ": " << transpose matrix C_0 << " " << EdgeIdeals$edges graphList#i << endl;
    );


-- Make my own list of monomials so that I don't have to generate the entire list of graphs
R = ring multidegree mbei EdgeIdeals$graph {{a,b},{b,c}}; -- Get the correct ring from scratch
-- Get the multidegrees of graphs with n vertices
n = 7;
monomialList = for i from 1 to n-1 list (
    for j from 0 to i list (
	R_{i-j,j}
	)
    )
monomialList = flatten monomialList

-- Get the coefficients of a graph
monomialList
R = QQ[a..g]
G = EdgeIdeals$graph {{a,b},{b,c},{c,d},{d,e},{e,f},{f,g},{g,a}}
(M,C) = coefficients(multidegree mbei G, Monomials => monomialList);
transpose matrix C_0


-- Visualize a graph
needsPackage "Visualize";
G = graphList#0;
H = graphList#4;
openPort "8080"; -- DANGER, this lets hackers into your computer
visualize graph EdgeIdeals$edges G;
visualize graph EdgeIdeals$edges H;
closePort();
