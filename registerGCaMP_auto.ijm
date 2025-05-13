run("Clear Results");
if (isOpen("ROI Manager")) {
     selectWindow("ROI Manager");
     run("Close");
  }
filename = File.openDialog("Select a File");
open(filename);
//filepath1 = File.openDialog("Select a File");
//open(filepath1);
dir = File.getParent(filename);
fname = File.nameWithoutExtension();
fname2 = replace(fname,".ome","");
noise = 1000;
run("Find Maxima...", "noise=" + noise + " exclude output=[Point Selection]");
run("Enlarge...", "enlarge=40 pixel");
run("Select Bounding Box");
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
