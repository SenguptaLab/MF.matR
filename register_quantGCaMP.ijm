filepath1 = File.openDialog("Select a File");
open(filepath1);
dir = File.getParent(filepath1);
fname = File.nameWithoutExtension();
fname2 = replace(fname,"_MMStack_Pos0.ome","")
waitForUser("REGISTRATION: select large square around neuron (just click 'OK' on the next 2 popups)");
setTool("rectangle");
run("Align slices in stack...");
run("Enlarge...", "enlarge=30");
run("Crop");
run("In [+]");
run("In [+]");
run("In [+]");
saveAs("Tiff", dir + "/" + fname2 + "_reg");
//close();
waitForUser("GCaMP: select ROI around neuron");
run("Set Measurements...", "area mean modal min median stack display invert redirect=None decimal=3");
saveSettings;
setTool("freehand");
setOption("Stack position", true);
       for (n=1; n<=nSlices; n++) {
          setSlice(n);
          run("Measure");
      }
restoreSettings;
saveAs("Results", dir + "/" + fname2 + "_neuron_results.csv");
run("Clear Results");
waitForUser("select background ROI");
saveSettings;
setOption("Stack position", true);
       for (n=1; n<=nSlices; n++) {
          setSlice(n);
          run("Measure");
      }
restoreSettings;
saveAs("Results", dir + "/" + fname2 + "_background_results.csv");
run("Clear Results");
close();