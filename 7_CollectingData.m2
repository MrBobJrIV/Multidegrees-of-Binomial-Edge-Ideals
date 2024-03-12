-- Author: Ethan Leventhal
-- Date: Sep 2023
-- Purpose: Code for Dr. Montano to run over the weekend to collect data!
         -- It will run for increasing numbers of vertices until terminated
         -- Note: it saves the data to the file "dataCollectedStorageFile" after each round of calculations
         -- (Before using this file, run all set-up code in 3_GraphToMultidegree.m2)


-- *** Define some variables and functions which will be helpful
-- Create a function to increment a value in a list
increment = (L,i) -> L#i = L#i + 1;
-- Create a function to return the time since it was last called
timer = (i := currentTime(); () -> (j = currentTime() - i; i = currentTime(); j))
-- Define the "one", "two", and "three" values to use during data collection
QQ[a..e];
(M,C) = coefficients multidegree mbei EdgeIdeals$graph {{a,d},{b,d},{a,e},{b,e},{c,e}};
one = (entries C_0)_0;
two = (entries C_0)_1;
three = (entries C_0)_2;


-- *** Collect data
-- Define list to store resulting data
dataCollected = {{"                   n","           numGraphs"," numMultiplicityFree","  numMinCoefOne","  numMinCoefTwo","numMinCoefThree","  numUnexpectedZeros"}};
-- Start at n = 2 vertices and increase n forever (until the program is terminated)
n = 2;
while true do (
    -- Print message
    << " " << timer() << " seconds to restart the loop." << endl;
    
    -- Print message
    << endl << "Started calculating for " << n << " vertices at:" << endl;
    run "date";
    
    -- For the current number of vertices n, generate all connected graphs with that many vertices
    R = QQ[x_1..x_n];
    graphList = generateGraphs(R, OnlyConnected => true);
    -- If you want all graphs, connected and disconnected, do this instead
    -- -- graphList = drop(generateGraphs(R), 1);
    -- Create variables to store the data we are collecting
    -- -- Index i in the list corresponds to the count for graphs of degree i
    numGraphs = new MutableList from n:0;
    numMultiplicityFree = new MutableList from n:0;
    numMinCoefOne = new MutableList from n:0;
    numMinCoefTwo = new MutableList from n:0;
    numMinCoefThree = new MutableList from n:0;
    numUnexpectedZeros = new MutableList from n:0;
    
    -- Print message
    << " " << timer() << " seconds to generate graphs." << endl;
    
    -- Loop through every graph in the list (with "time" to track how long it takes)
    for i from 0 to #graphList-1 do (
    	-- Get the multidegree of the current graph
    	thisMultidegree := multidegree fbei graphList#i;
    	-- Store the degree of the multidegree
    	degreeOfMultidegree := (degree thisMultidegree)#0;
    	increment(numGraphs, degreeOfMultidegree);
    	-- Get the list of coefficients of the multidegree
    	(M,C) := coefficients(thisMultidegree);
	C = entries C_0;
    	-- Count if it is multiplicity free (only zeros and ones)
    	if(max C == 1) then increment(numMultiplicityFree, degreeOfMultidegree);
    	-- Count if it has a minimum coefficient above one
    	if(first C == one) then increment(numMinCoefOne, degreeOfMultidegree);
    	-- Count if it has a minimum coefficient above two
    	if(first C == two) then increment(numMinCoefTwo, degreeOfMultidegree);
    	-- Count if it has a minimum coefficient above three
    	if(first C == three) then increment(numMinCoefThree, degreeOfMultidegree);
    	-- Count if it has unexpected zeros
    	if (degreeOfMultidegree - 1 > #C) then increment(numUnexpectedZeros, degreeOfMultidegree);
	);
    
    -- Print message
    << " " << timer() << " seconds to collect data." << endl;
    
    -- Update the data in a list
    dataCollected = append(dataCollected, {n,
	new List from numGraphs,
	new List from numMultiplicityFree,
	new List from numMinCoefOne,
	new List from numMinCoefTwo,
	new List from numMinCoefThree,
	new List from numUnexpectedZeros});
    -- Save that data to a file
    "dataCollectedStorageFile" << toExternalString(dataCollected) << endl << close;
    -- Increment the number of vertices
    n = n + 1;
    
    -- Print message
    << " " << timer() << " seconds to store data." << endl;
    );


-- *** Read the data from the file
-- dataCollected = value get "dataCollectedStorageFile";
dataCollected = value get "dataCollectedStorageFile";


-- *** Display data by category
-- Note that this ignores categorization by degree of multidegree
(
<< endl;
<< (dataCollected#0)#0 << ":\t";
for j from 1 to #dataCollected-1 do (
	<< (dataCollected#j)#0 << "\t";
	);
<< endl;
for i from 1 to #(dataCollected#0)-1 do (
    << (dataCollected#0)#i << ":\t";
    for j from 1 to #dataCollected-1 do (
	<< sum((dataCollected#j)#i) << "\t";
	);
    << endl;
    );
)


-- *** Display data by number of vertices
-- Index i in a list corresponds to the count for graphs whose multidegree has dimension i
(
<< endl;
for i from 1 to #dataCollected-1 do (
    << "Graphs with " << (dataCollected#i)#0 << " vertices:" << endl;
    for j from 1 to #(dataCollected#i)-1 do (
	<< (dataCollected#0)#j
	<< " =\t"
	<< (dataCollected#i)#j
	<< "\ttotal = "
	<< sum((dataCollected#i)#j)
	<< endl;
	);
    << endl;
    );
)
