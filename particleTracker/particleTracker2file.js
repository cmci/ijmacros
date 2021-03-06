// javascript to be called from macro. Does the particle tracking by particle tracker plugin. 
//
// works only with the plugin downloadable from 
//    http://cmci.embl.de/downloads/particletracker2d
//
// Usage: modify line 7 to 11 to set your parameter.
// this JS could be called from ImageJ macro by:
//   jsstr = File.openAsString("<filepath>");
//   eval("script", jsstr);
//
// Kota Miura (miura@embl.de), CMCI, EMBL Germany
// 20110825
// 20111130 saving Full report
// 
rad = 3;
coff = 3;
ptl = 0.10000;
lik = 2
disp = 10;

importClass(Packages.java.lang.Thread);
importClass(Packages.ij.Macro);
imp = IJ.getImage();

// set macro options in the current thread 
options = "radius="+ rad +" cutoff="+ coff +" percentile=" + ptl+ 
          " link=" + lik + " displacement=" + disp;
thread = Thread.currentThread();
original_name = thread.getName();
thread.setName("Run$_my_batch_process");
Macro.setOptions(Thread.currentThread(), options);

// run the tracker
pt = IJ.runPlugIn(imp, "ParticleTracker_", "");
//pt.transferTrajectoriesToResultTable();

//write the full data to disk
vFI = imp.getOriginalFileInfo();
if (vFI == null) {
  IJ.error("cannot write to disk");
} else {
  newDir = new java.io.File(vFI.directory, "ptresults");
  if (!newDir.mkdir() && !newDir.exists() ) {
    IJ.error("cannot make new directory");
  } else {
    pt.write2File(newDir.getAbsolutePath(), vFI.fileName + "PTres.txt", pt.getFullReport().toString());
    IJ.log(newDir.getAbsolutePath());
    IJ.log(vFI.fileName + "PTres.txt");
    //IJ.log(pt.getFullReport().toString());
  }
}

// try killing the particle tracker results window
frames = WindowManager.getNonImageWindows();
IJ.log(frames.length);
for (var i = 0; i < frames.length; i++){
	IJ.log(frames[i].getTitle());
	if (frames[i].getTitle() == "ParticleTracker Results") frames[i].dispose();
}
IJ.freeMemory();
