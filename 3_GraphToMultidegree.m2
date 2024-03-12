-- Author: Ethan Leventhal
-- Date: Sep 2023
-- Purpose: Sets up a function to concisely calculate multidegrees of a list of graphs


-- *** Import the Nauty package to create and use graphs
-- Note this also automatically also installs EdgeIdeals, SimplicialComplexes, Polyhedra, and FourTiTwo
needsPackage "Nauty";


-- *** Define the variables to use in the binomial edge ideals
xx:=vars(23);
yy:=vars(24);


-- *** This method was taken and modified from the BinomialEdgeIdeal package source code
-- It returns the multidegree of a graph (with the correct grading so that x's and y's are counted separately)
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


-- *** This is a stripped-down version of the previous method to be as fast as possible
fbei = G -> (
v:=vertices(G);
e:=apply(edges(G),toList);
R:=QQ[(for vv in v list x_(vv))|(for vv in v list y_(vv)),
    Degrees=>(for vv in v list {1,0})|(for vv in v list {0,1})];
return ideal for ee in e list (xx_(ee_0))_R*(yy_(ee_1))_R-(yy_(ee_0))_R*(xx_(ee_1))_R;
);


-- *** Make a list of all possible monomials for graphs up to n vertices
n := 8;
-- Make an arbitrary graph to get the correct ring when making the monomials
R := ring multidegree mbei EdgeIdeals$graph(QQ[a..b], {{a,b}});
-- Make a and b back into symbols so that they don't have lingering values
a = symbol a;
b = symbol b;
-- Loop to create all monomials
monomialList := flatten for i from 1 to n-1 list (
    for j from 0 to i list (
	R_{i-j,j}
	)
    );


-- *** Function to calculate and print coefficients of multidegrees of all graphs in the list
-- To use, call coef(graphList);
-- Use the optional argument by calling coef(graphList, ShowZeros => false); to ignore zeros
coef = {ShowZeros => true} >> o -> graphList -> (
    if o.ShowZeros then (
    	for i from 0 to #graphList-1 do (
    	    (M,C) := coefficients(multidegree(fbei(graphList#i)), Monomials=>monomialList);
    	    << i << ":\t" << transpose matrix C_0 << "\tVertices: " << #(vertices graphList#i) << "\tEdges: " << EdgeIdeals$edges graphList#i << endl;
    	    );
    	) else (
        for i from 0 to #graphList-1 do (
    	    myMultidegree := multidegree(fbei(graphList#i));
	    (M,C) := coefficients(myMultidegree);
    	    << i << ":\t" << transpose matrix C_0;
	    if not(o.ShowZeros) then (<< "   Degree: " << degree(myMultidegree));
	    << "   Vertices: " << #(vertices graphList#i) << "  Edges: " << EdgeIdeals$edges graphList#i << endl;
    	    );
    	);
    );

















