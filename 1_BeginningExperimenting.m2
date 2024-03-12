needsPackage "Graphs"
needsPackage "BinomialEdgeIdeals"
needsPackage "NautyGraphs"
needsPackage "Nauty"


-- *** Get the multidegree of a random simple graph with 4 vertices
M = fillMatrix(mutableMatrix(ZZ,4,4),Height => 2,UpperTriangular => true)
M = M + transpose M
G = graph(matrix M)
multidegree(bei(G))


-- *** Get the multidegree of 10 random simple graphs with n vertices
-- Possibly disconnected
-- Might have zero edges, which throws an error
n = 4;
for i from 0 to 9 do (
    print multidegree(bei(graph(matrix(M = fillMatrix(mutableMatrix(ZZ,n,n),Height => 2,UpperTriangular => true); M + transpose M))))
    )


-- *** Function to convert a binary list into an adjacency matrix
-- n is the number of vertices
-- binaryList stores how to fill in the matrix; must have length (n-1) + ... + 2 + 1 = binomial(n,2)
toAdjacencyMatrix = (n,binaryList) -> (
    -- Create empty matrix of the correct size
    M = mutableMatrix(ZZ,n,n);
    -- Make a pointer to keep track of where we are in the binary list
    i = 0;
    -- Loop through the upper traingle of the matrix and fill it in according to the binary list
    for row from 0 to n-1 do (
    	for col from row+1 to n-1 do (
	    if 1 == binaryList_i then (
	    	M_(row,col) = 1;
	    	);
    	    i = i + 1;
	    );
    	);
    M = M + transpose M
    )


-- *** Function to convert a number into a list of its digits in binary
-- n is the number to convert; must be greater than 0
-- l is the desired length of the resulting list to force padded zeros (if too small it will have no effect)
toBinaryList = (n,l) -> (
    -- Define a list to store any needed beginning zeros
    beginningZeros = {};
    -- Loop to add any needed zeros to the beginning
    while n < (2^(l-1)) do (
    	beginningZeros = append(beginningZeros,0);
    	l = l - 1;
    	);
    -- Define a list to store the binary
    binaryList = {};
    -- Loop
    while n > 0 do (
    	binaryList = prepend(n%2,binaryList);
    	n = floor(n/2);
    	);
    -- Print the final binary list
    binaryList = join(beginningZeros,binaryList)
    )


-- *** Get all multidegrees of simple matrices with n vertices
n = 4;
-- l is how many edges are in a graph with n vertices, so this is how long our binary list must be
l = binomial(n,2);
megaList = for i from 1 to 2^l-1 list (multidegree(bei(graph(matrix(toAdjacencyMatrix(n,toBinaryList(i,l)))))))
-- Get the unique multidegrees
uniqueList = unique(megaList)
-- Count how many times each multidegree appears
uniqueCountList = for i in uniqueList list number(megaList, m -> m == i)


-- *** Experimenting with Dr. Montano
G = graph({1,2,3}, matrix {{0,1,1},{1,0,1},{1,1,0}})
I = bei(G)
-- hilbertPolynomial(ring I/I)
-- dim I
multidegree I
-- This is convenient but not helpful because it has the wrong grading

-- If we do it manually, we can set up the grading so that the degrees of x's and y's are separate
R = QQ[x_1..x_3,y_1..y_3, Degrees => {{1,0},{1,0},{1,0},{0,1},{0,1},{0,1}}]
M = matrix {{x_1..x_3},{y_1..y_3}}
I = minors(2,M)
multidegree I -- We are interested in the coefficients (in this example it is 1,1,1)
I = ideal (-x_2*y_1+x_1*y_2,-x_3*y_1+x_1*y_3)
multidegree I -- This one has only two edges, and it has coefficients 1,2,1

-- I copied the source code for bei and modified it to use the right grading
xx:=vars(23);
yy:=vars(24);
mbei = method (Options => {Field=>QQ,TermOrder=>Lex,Permanental=>false})
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
-- This makes a function mbei() exactly like bei() except it uses the correct grading!


-- *** Use Nauty to get all graphs (up to isomorphism) with certain properties
-- Define a ring to specify the number of vertices
R = QQ[a,b,c,d]
-- Create a list of all connected graphs with those vertices
graphList = generateGraphs(R, OnlyConnected => true)
-- Filter the list to only include graphs with certain properties
s = buildGraphFilter {"Diameter" => 2}
graphList = filterGraphs(graphList, s)
multidegreesList = for g in graphList list (multidegree(mbei(edges g)))
coefficientsList = for i in multidegreesList do ((M,C) = coefficients(i); print transpose matrix C_0)
