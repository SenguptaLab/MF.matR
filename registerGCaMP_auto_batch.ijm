run("Clear Results");
if (isOpen("ROI Manager")) {
     selectWindow("ROI Manager");
     run("Close");
  };
// Read the arguments passed from the shell script
args = getArgument();         // args is a single string: "value1,value2"
print(args);
parts = split(args, ",");

filename = parts[0];
prominence = parts[1];

// Example: show the arguments
print("filename: " + filename);
print("prominence: " + prominence);

if (filename=="") exit ("No argument!");
open(filename);

dir = File.getParent(filename);
fname = File.nameWithoutExtension();
fname2 = replace(fname,"_MMStack_Pos0.ome","");
options = "prominence=" + prominence + " exclude output=[Point Selection]";

// PARAMETERS
prominence = prominence; // adjust as needed
roiRadius = 10;   // radius for sampling around maxima
rectWidth = 60;
rectHeight = 60;

// Duplicate original image to work on
//run("Duplicate...", "title=WorkImage");

// Run Find Maxima to get point ROIs
run("Find Maxima...", options);

roiManager("Add");
roiCount = roiManager("count");

if (roiCount == 0) {
    showMessage("No maxima found.");
    exit();
}

// Initialize variables to store best result
maxMedian = -1;
bestX = 0;
bestY = 0;

// Loop through each point ROI
for (i = 0; i < roiCount; i++) {
    roiManager("select", i);
    getSelectionCoordinates(xCoords, yCoords);
    
    x = xCoords[0];
    y = yCoords[0];

    // Create circular ROI around point
    makeOval(x - roiRadius, y - roiRadius, roiRadius * 2, roiRadius * 2);
    
    run("Measure");
    median = getResult("Median", nResults - 1);

    if (median > maxMedian) {
        maxMedian = median;
        bestX = x;
        bestY = y;
    }
}

// Select best maxima and center rectangular ROI on it
roiManager("deselect");
roiManager("reset");

x0 = bestX - rectWidth / 2;
y0 = bestY - rectHeight / 2;
makeRectangle(x0, y0, rectWidth, rectHeight);

// Optional: show result
print("Best median: " + maxMedian);


//run("Enlarge...", "enlarge=40 pixel");
//run("Select Bounding Box");
roiManager("Add");
roiManager("Select", 0);
roiManager("Rename", "roi_1");
Roi.getBounds(x,y,w,h);
print(x);
run("Align slices in stack...", "method=5 windowsizex="+w+" windowsizey="+h+" x0="+x+" y0="+y+" swindow=0 subpixel=false itpmethod=0 ref.slice=1 show=true");
run("Crop");
run("In [+]");
run("In [+]");
run("In [+]");
saveAs("Tiff", dir + "/" + fname2 + "_reg");
close();
