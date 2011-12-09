// plot 3D progressive tracks in 3D viewer. 
// ... to be used in combination with linking plugin. 
// 
// for showing full 25 time points, requires 4Gb memory

// for verification of 3D tracking results. 
// Kota Miura (miura@embl.de)

importClass(Packages.javax.vecmath.Point3f);
importClass(Packages.java.util.Vector);
importPackage(Packages.util.opencsv);
importPackage(java.io);
importClass(Packages.javax.vecmath.Color3f);
importPackage(Packages.ij3d);
importPackage(Packages.customnode);

// ---- file examples -----

//imagepath = '/Users/miura/Desktop/s1short.tif';

//imagepath = '/Volumes/cmci/mette/s1_f1_10_gb1.tif';
//timestart = 0;timeend = 10;

imagepath = '/Volumes/cmci/mette/s1_gb1.tif';
timestart = 0;timeend = 25;

//imagepath = '/Volumes/cmci/mette/s1_f1_15_gb1.tif';
//timestart = 0;timeend = 15;

//imagepath = '/Volumes/cmci/mette/s1_f1_20_gb1.tif';
//timestart = 0;timeend = 20;

//imagepath = '/Volumes/cmci/mette/s1_f11_20.tif';
//timestart = 10;timeend = 20;

//imagepath = '/Users/miura/Desktop/s1shortBlur.tif';
//timestart = 0;timeend = 5;

// --- file examples end ---

filepath = "/Users/miura/Dropbox/Mette/Tracks.csv";

// this frame will not be in

imp = IJ.openImage(imagepath);
tList = loadFile(filepath);
IJ.log("tracks:" + tList.size());
/*
for (var i = 0; i < tList.size(); i++)
	IJ.log(tList.get(i).id);
*/
univ = new Image3DUniverse();
univ.show();

col = Color3f(0, 1.0, 0.5);
col2 = Color3f(1.0, 0, 0);

channelswitch = java.lang.reflect.Array.newInstance(java.lang.Boolean.TYPE, 3);
channelswitch[0] = true;
channelswitch[1] = true;
channelswitch[2] = true;

// volume rendering
//c = univ.addVoltex(imp); 

// isosurface
c = univ.addMesh(imp, col2, "surface", 80, channelswitch, 2);
c.setTransparency(0.3);
tl = univ.getTimeline();


/* // this block 
clmmLine = CustomMultiMesh();
clmmPoint = CustomMultiMesh();

var it = tList.iterator();
for (var i = 0; i< tList.size(); i++) {
	var content = tList.get(i).dotList;//it.next().dotList();
	var clm = CustomLineMesh(content, CustomLineMesh.CONTINUOUS, col, 0);
	var cpm = CustomPointMesh(content);
	cpm.setColor(new Color3f(0.5, 0.5, 0.5));
	cpm.setPointSize(3);
	clmmLine.add(clm);
	clmmPoint.add(cpm);	
}
*/

clmmProLine = CustomMultiMesh();

//trial for a single progressive track

for (var i = timestart; i < timeend; i++){
	var clmmProLine = CustomMultiMesh();
	for (var j = 0; j < tList.size(); j++) {
		var curtraj = tList.get(j);
		if (CheckTimePointExists(i, curtraj.timepoints)){
			IJ.log(curtraj.id);
			var dt = curtraj.dotList;
			var pathextract = Vector();
			pathextract.addAll(curtraj.dotList);
			//pathextract.removeRange(i+1, pathextract.size()-1);
			var timeextract = Vector();
			timeextract.addAll(curtraj.timepoints);
			var ind = timeextract.indexOf(i);
			pathextract = pathextract.subList(0, ind+1);	//this should be changed. 
			var k = 0;
			//while ( k =< i){
			//	pathextract.add(curtraj.dotList.get(k));
			//	k++
			//}
			var clm = CustomLineMesh(pathextract, CustomLineMesh.CONTINUOUS, col, 0);
			clmmProLine.add(clm);
			clm.setLineWidth(2);
		}
	}
	cc = ContentCreator.createContent(clmmProLine, "time" + Integer.toString(i), i-timestart);
	univ.addContent(cc);
}



//c3 = univ.addCustomMesh(clmmLine, "tracks");
//c4 = univ.addCustomMesh(clmmPoint, "points");
//c3.setShowAllTimepoints(true);
//c4.setShowAllTimepoints(true);

//for single time point
/*
timepoint = 2;
c2 = ContentCreator.createContent(clmmLine, "test2", timepoint);
univ.addContent(c2);
*/
// laoding track data to a List (vector)
// file is direct out put of ImageJ results table.
function loadFile(datapath){

	var reader = new CSVReader(new FileReader(datapath), ",");
	var ls = reader.readAll();
	var it = ls.iterator();
	var counter = 0;
	var currentTrajID = 1.0;
	var atraj = Vector();
	var timepoints = Vector();
	var trajlist = Vector();
	while (it.hasNext()){
		var cA = it.next();
		if (counter != 0){
			if ((currentTrajID - Double.valueOf(cA[1]) != 0) && (atraj.size() > 0)){
				IJ.log(Double.toString(currentTrajID) + cA[1]);
				var atrajObj = new trajectoryObj(currentTrajID, atraj, timepoints);
				trajlist.add(atrajObj);
				currentTrajID = Double.valueOf(cA[1]);
				//cvec.clear();
				atraj = Vector();
				timepoints = Vector();
			}
			// pixel positions
 			//cvec.add(Point3f(Double.valueOf(cA[3]),Double.valueOf(cA[4]),Double.valueOf(cA[5])));
 			// scaled positions
 			atraj.add(Point3f(Double.valueOf(cA[6]),Double.valueOf(cA[7]),Double.valueOf(cA[8]))); 
 			timepoints.add(Double.valueOf(cA[2]));  
		}
		counter++;
	}
	return trajlist;
}

// trajectory as an object. 
function trajectoryObj(id, dotList, timepoints) {
	this.id = id;
	this.dotList = dotList;
	this.timepoints = timepoints; //a vector tith time points of the trajectory. 
}


/*
algorithm for dynamic plotting. 
for each time point, create gourp of mesh.
add the results to the time point (iterate this)
*/

//check if a time point is included in the trajectory. 
//(int, vector)
function CheckTimePointExists(thistimepoint, timepoints){
	var includesthistime = false;
	if ((timepoints.get(0) <= thistimepoint) && (timepoints.get(timepoints.size()-1) >= thistimepoint)){
		includesthistime = true;
	}
	return includesthistime;
}

function ReturnTrajectoryFragment(){
	
}
