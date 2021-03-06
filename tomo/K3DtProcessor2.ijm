//080327
//Kota Miura

macro "local max segmentation"{

}

macro "insert blank frames after every frame"{
	blankframe=1;
	orignalframes = nSlices;
	setSlice(blankframe);
	run("Select All");
	run("Copy");	
	for (i=orignalframes ; i>0; i--) {
		setSlice(i);
		run("Add Slice");
		run("Paste");
	}
}


macro "find maxima Processing" {
	stackID=getImageID();
	ww=getWidth();
	wh=getHeight();
	frames=nSlices;
	newImage("segmented", "8-bit Black", ww, wh, frames);
	processedID=getImageID();
	for (i=0; i<frames; i++) {
		selectImage(stackID);
		setSlice(i+1);
		run("Find Maxima...", "noise=3 output=[Segmented Particles] exclude");
		//run("Erode");
		run("Select All");
		run("Copy");
		close();
		selectImage(processedID);
		setSlice(i+1);
		run("Paste");
	}
	run("Divide...", "stack value=255");
	imageCalculator("Multiply create stack", stackID,processedID);									
}


function returnFilestring() {
	fullpathname = File.openDialog("Select a track File");
	openedDirectory = File.getParent(fullpathname );
	openedFile = File.getName(fullpathname );
	tempstr = File.openAsString(fullpathname);
	return tempstr;
}

//returns number of detected tracks in the track file (exported by particle tracker "track" converter)
function returnTrackNumber(tempstr) {
	lineA=split(tempstr,"\n");
	tracknum =0;
	curerrenttrack =0;
	for(i=0; i< lineA.length; i++) {
		linecontentA=split(lineA[i],"\t");
		if(parseInt(linecontentA[0]) != curerrenttrack ) {
			tracknum+=1;
			curerrenttrack = parseInt(linecontentA[0]);
			//print(curerrenttrack );
		}
	}
	return tracknum;
}

//returns the number of points in a specified trackID
function returnTrackPoints(tempstr, trackID) {
	lineA=split(tempstr,"\n");
	pointnum =0;
	trackfound=0;
	for(i=0; i< lineA.length; i++) {
		linecontentA=split(lineA[i],"\t");
		if(parseInt(linecontentA[0]) == trackID) {
			pointnum+=1;
		}
	}
	return (pointnum-1);
}

//assuming that the framesstarts from 0
function returnThelastframeNum(tempstr) {
	tracknumber = returnTrackNumber(tempstr);
	trackIDA = newArray(tracknumber);
	lineA=split(tempstr,"\n");
	pointnum =0;
	trackfound=0;
	curerrenttrack =0;
	trackcount=0
	for(i=0; i< lineA.length; i++) {
		linecontentA=split(lineA[i],"\t");
		if(parseInt(linecontentA[0]) != curerrenttrack ) {
			trackIDA[trackcount]  = parseInt(linecontentA[0]);
			curerrenttrack   = parseInt(linecontentA[0]);
			trackcount++;
//			print(curerrenttrack );
		}
	}
	maxtracklength = 0;
	for(i=0; i<trackIDA.length; i++) {
		currenttracklength = returnTrackPoints(tempstr, trackIDA[i]);
		if (maxtracklength < currenttracklength ) maxtracklength = currenttracklength;
	}
	return maxtracklength ;
}

function returnDistance3D(x1, y1, z1, x2, y2, z2){
	dist3D = pow( (pow((x1-x2), 2) + pow((y1-y2), 2) + pow((z1-z2), 2) ), 0.5);
	return dist3D;
}

//080401
function returnDistance3Dzscale(x1, y1, z1, x2, y2, z2, zscale){
	dist3D = pow( (pow((x1-x2), 2) + pow((y1-y2), 2) + pow(zscale*(z1-z2), 2) ), 0.5);
	return dist3D;
}

function returnDistance2D(x1, y1,  x2, y2){
	dist2D = pow( (pow((x1-x2), 2) + pow((y1-y2), 2)  ), 0.5);
	return dist2D;
}

function K_retrunArrayMin(aA) {
	aA_min=50000000; //LIB
	for (k=0;k<aA.length;k++) if (aA_min>aA[k]) aA_min=aA[k];
	return aA_min;
 }

function K_retrunArrayMinPosition(aA) {
	aA_min=500000; //LIB
	minpos =0;
	for (k=0;k<aA.length;k++) if (aA_min>aA[k]) {
		aA_min=aA[k];
		minpos = k;
	}
	return minpos ;
 }




/*
macro "test track counter"{
	print(returnTrackNumber( returnFilestring()));
}
macro "test track point counter"{
	print(returnTrackPoints( returnFilestring(), getNumber("trackID?", 1)));
}
*/
macro "test track "{
	print(returnThelastframeNum( returnFilestring()));
}


macro "test search for the nearest neighbor link" {
	srctrack = getNumber("search for which track?", 1);
	tempstr = returnFilestring();
	totaltracknum= returnTrackNumber(tempstr);
	lineA=split(tempstr,"\n");
	pointcount =0;
	for(i=0; i< lineA.length; i++) {
		linecontentA=split(lineA[i],"\t");
		if ((linecontentA.length==1) &&(parseInt(linecontentA[0]) == srctrack)) {
			tempA = split(lineA[i-1],"\t");
			sf = parseInt(tempA[1]);
			sx = parseFloat(tempA[3]);
			sy = parseFloat(tempA[2]);
			sz = parseFloat(tempA[4]);
 		}		
	}
	print("Last position at "+sf+"=("+sx+","+sy+","+sz+")");

	distance3DA=newArray(totaltracknum);
	distance2DA=newArray(totaltracknum);
	for(i=0; i<distance3DA.length; i++) distance3DA[i]=10000;
	for(i=0; i<distance2DA.length; i++) distance2DA[i]=10000;

	currenttrack = 1;
	for(i=0; i< lineA.length; i++) {
		linecontentA=split(lineA[i],"\t");
		if ((linecontentA.length>1) && (parseInt(linecontentA[0]) == currenttrack)) {
			tempA = split(lineA[i],"\t");
			df = parseInt(tempA[1]);
			dx = parseFloat(tempA[3]);
			dy = parseFloat(tempA[2]);
			dz = parseFloat(tempA[4]);
			if (((df - sf) >=0) && ((df - sf) <3)) {
				distance3DA[currenttrack-1] = returnDistance3D(sx, sy, sz, dx, dy, dz);
				distance2DA[currenttrack-1] = returnDistance2D(sx, sy, dx, dy);
				print("track"+currenttrack+" f"+df+":: dist: " + returnDistance3D(sx, sy, sz, dx, dy, dz));
			}
			currenttrack+=1;
		}		

	}
	mindisttrack = K_retrunArrayMinPosition(distance3DA)+1;
	print("next track could be" + mindisttrack );


/*	currentxA = newArray(pointcount);
	currentyA = newArray(pointcount);
	currentzA = newArray(pointcount);
	currentfA = newArray(pointcount);
*/
}

macro "list tracklength" {
	tempstr = returnFilestring();
	 linktracks(tempstr);
}
//080401
function linktracks(tempstr) {
	totaltracknum = returnTrackNumber(tempstr);
	trackIDA = newArray(totaltracknum);
	trackpointsA  = newArray(totaltracknum); 
	trackstartsA  = newArray(totaltracknum);
	sxA  = newArray(totaltracknum);
	syA  = newArray(totaltracknum);
	szA  = newArray(totaltracknum);
	exA  = newArray(totaltracknum);
	eyA  = newArray(totaltracknum);
	ezA   = newArray(totaltracknum);
	sfA = newArray(totaltracknum);
	efA = newArray(totaltracknum);
	checkfinishedA = newArray(totaltracknum);
	nextIDA = newArray(totaltracknum);
	nextIDdistance = newArray(totaltracknum);
	nextIDframeA=newArray(totaltracknum);
	nextIDendframe=newArray(totaltracknum);
	connectionNumberA=newArray(totaltracknum);

	distance3DA=newArray(totaltracknum);
	distance2DA=newArray(totaltracknum);
	for(i=0; i<distance3DA.length; i++) distance3DA[i]=10000;
	for(i=0; i<distance2DA.length; i++) distance2DA[i]=10000;

	fullTrackLength = returnThelastframeNum(tempstr);
	perlineA=split(tempstr,"\n");
	currentID = 0;
	counter=0;
	for(i=0; i<perlineA.length; i++) {
		contentA=split(perlineA[i],"\t");
		if (parseInt(contentA[0]) != currentID) {
			currentID = parseInt(contentA[0]);
			trackIDA[counter] = currentID;
			trackpointsA[counter] = returnTrackPoints(tempstr, currentID);
			if (trackpointsA[counter] == fullTrackLength) {
				checkfinishedA[counter] =1;
			} else {
				sfA[counter] = parseFloat(contentA[1]);
				sxA[counter] = parseFloat(contentA[2]);
				syA[counter] = parseFloat(contentA[3]);
				szA[counter] = parseFloat(contentA[4]);
				
				contentEndA=split(perlineA[i+trackpointsA[counter]-1],"\t");
				efA[counter] = parseFloat(contentEndA[1]);
				exA[counter] = parseFloat(contentEndA[2]);
				eyA[counter] = parseFloat(contentEndA[3]);
				ezA[counter] = parseFloat(contentEndA[4]);
			}
			counter++;
		}
	}
	// finding minimum distance followup tracks. 	
	for(i=0; i<trackIDA.length; i++) {
		print(trackIDA[i]+": "+trackpointsA[i]+" full:"+checkfinishedA[i] + " endframe="+efA[i]);
/*		if ((checkfinishedA[i]==0) && (efA[i]<(fullTrackLength-1)) ) {
			print("         "+sxA[i]+", "+syA[i]+", "+szA[i]+" starts:"+sfA[i]+" ends:"+efA[i]);
			for(j=0; j<sfA.length; j++) {
				framegap = sfA[j] - efA[i];
				if ((i!=j) && (checkfinishedA[j]==0) && ( framegap>=0 ) && (framegap<3)) {
					//distance3DA[j] = returnDistance3D(exA[i], eyA[i], ezA[i], sxA[j], syA[j], szA[j]);
					distance3DA[j] = returnDistance3Dzscale(exA[i], eyA[i], ezA[i], sxA[j], syA[j], szA[j], 20);
					distance2DA[j] = returnDistance2D(exA[i], eyA[i], sxA[j], syA[j]);
					print("track"+trackIDA[j]+" framegap:"+framegap +":: dist: " + returnDistance3D(exA[i], eyA[i], ezA[i], sxA[j], syA[j], szA[j]));
				}
			}
			minarraypos =K_retrunArrayMinPosition(distance3DA);
			mindisttrack = trackIDA[minarraypos];			
			print("next track could be" + mindisttrack );
			nextIDA[i] = mindisttrack;
			nextIDframeA[i] = sfA[minarraypos];
			nextIDdistance[i] = distance3DA[minarraypos];
			nextIDendframe[i] = efA[minarraypos];
			connectionNumberA[i] +=1;
			connectionNumberA[minarraypos] +=1;
			//checkfinishedA[minarraypos] = 2;
			for(k=0; k<distance3DA.length; k++) distance3DA[k]=10000;
			for(k=0; k<distance2DA.length; k++) distance2DA[k]=10000;						
		}
*/
		FinMinimumDistTrackID(checkfinishedA, efA, exA, eyA, ezA, sfA, sxA, syA, szA, nextIDA, nextIDframeA, nextIDdistance, nextIDendframe, connectionNumberA, fullTrackLength, totaltracknum, i);

	}

	candidateIDA = newArray(39);
	candidateDistA = newArray(39);
	for(i=0; i<candidateIDA.length; i++) {
		candidateIDA[i] =1000;
		candidateDistA[i] =10000;
	}

	// above part should be functionalized so that could be used in the while-loop.
/*	while (CheckMultipleConnection(connectionNumberA)==1) {
		for(i=0; i<connectionNumberA.length; i++) {
			if (connectionNumberA[i]>1) {
				counter=0;
				minimumdistance=1000;
				currenttrackID =trackIDA[i]; 
				for(j=0; j<nextIDA.length; j++) {
					if (nextIDA[j]==currenttrackID) {
						candidateIDA[counter] =trackIDA[j]; //retrunArrayPosition4trackID(trackIDA, j);
						candidateDistA[counter] = nextIDdistance[j];
						counter++;
					}
				}
				minarrayposition = K_retrunArrayMinPosition(candidateDistA); 
				minID = candidateIDA[minarrayposition];
				minDist = candidateDistA[minarrayposition];
				for (j=0; j<counter; j++) {
					if(candidateIDA[j]!=minID) {
						arrayposition = retrunArrayPosition4trackID(trackIDA, candidateIDA[j]);
						nextIDA[arrayposition] =-1;
						connectionNumberA[arrayposition] =-1; 
						connectionNumberA[i] -=1;
					}
				}
			}

		}
	}

	//retrunArrayPosition4trackID(idA, trackID);
*/
	
/*	for(i=0; i<trackIDA.length; i++) {
		if(trackpointsA [i]<fullTrackLength) {
			if (efA[i]!=fullTrackLength-1) {
				print("track"+trackIDA[i]+"start:"+sfA[i]+" last:"+efA[i] + " at frame"+nextIDframeA[i]+" to track "+  nextIDA[i]+"-- dist:"+nextIDdistance[i] +" ends at"+nextIDendframe[i]);
			} else {
				if (checkfinishedA[i] ==2) { 
					print("track"+trackIDA[i]+"start:"+sfA[i]+" last:"+efA[i]+ "connected to somewhere, and finished in the last frame");
				} else {
					print("track"+trackIDA[i]+"start:"+sfA[i]+" last:"+efA[i]+ "fragment but finished in the last frame");
				}
			} 
		} else {
			print("track"+trackIDA[i]+" last frame:"+efA[i]  + " completed");
		}	
	}

*/
	for(i=0; i<trackIDA.length; i++) {
		if(trackpointsA [i]<fullTrackLength) {
			if (efA[i]!=fullTrackLength-1) {
				print("track"+trackIDA[i]+"start:"+sfA[i]+" last:"+efA[i] + " at frame"+nextIDframeA[i]+" to track "+  nextIDA[i]+"-- dist:"+nextIDdistance[i] +" ends at"+nextIDendframe[i]+" connection number:"+connectionNumberA[i] );
			} else {
				print("track"+trackIDA[i]+"start:"+sfA[i]+" last:"+efA[i]+ "fragment but finished in the last frame connection number:"+connectionNumberA[i]);
			} 
		} else {
			print("track"+trackIDA[i]+" last frame:"+efA[i]  + " completed connection number:"+connectionNumberA[i]);
		}	
	}

}

function CheckMultipleConnection(conA){
	thereismultiple =0;
	for(i=0; i<conA.length, i++) {
		if (conA[i]>1) thereismultiple =1;
	}
	return thereismultiple;
}

function retrunArrayPosition4trackID(idA, trackID) {
	position=-1;
	for(i=0; i<idA.length; i++) if(idA[i]==trackID) position=i;
	return position; 
}

function FinMinimumDistTrackID(checkfinishedA, efA, exA, eyA, ezA, sfA, sxA, syA, szA, nextIDA, nextIDframeA, nextIDdistance, nextIDendframe, connectionNumberA, fullTrackLength, totaltracknum, i) {
	distance3DA=newArray(totaltracknum);
	distance2DA=newArray(totaltracknum);
	for(k=0; k<distance3DA.length; k++) distance3DA[k]=10000;
	for(k=0; k<distance2DA.length; k++) distance2DA[k]=10000;						

	if ((checkfinishedA[i]==0) && (efA[i]<(fullTrackLength-1)) ) {
		print("         "+sxA[i]+", "+syA[i]+", "+szA[i]+" starts:"+sfA[i]+" ends:"+efA[i]);
		for(j=0; j<sfA.length; j++) {
			framegap = sfA[j] - efA[i];
			if ((i!=j) && (checkfinishedA[j]==0) && ( framegap>=0 ) && (framegap<3)) {
				//distance3DA[j] = returnDistance3D(exA[i], eyA[i], ezA[i], sxA[j], syA[j], szA[j]);
				distance3DA[j] = returnDistance3Dzscale(exA[i], eyA[i], ezA[i], sxA[j], syA[j], szA[j], 20);
				distance2DA[j] = returnDistance2D(exA[i], eyA[i], sxA[j], syA[j]);
				print("track"+trackIDA[j]+" framegap:"+framegap +":: dist: " + returnDistance3D(exA[i], eyA[i], ezA[i], sxA[j], syA[j], szA[j]));
			}
		}
		minarraypos =K_retrunArrayMinPosition(distance3DA);
		mindisttrack = trackIDA[minarraypos];			
		print("next track could be" + mindisttrack );
		nextIDA[i] = mindisttrack;
		nextIDframeA[i] = sfA[minarraypos];
		nextIDdistance[i] = distance3DA[minarraypos];
		nextIDendframe[i] = efA[minarraypos];
		connectionNumberA[i] +=1;
		connectionNumberA[minarraypos] +=1;
			//checkfinishedA[minarraypos] = 2;
	}
}

// above: need to (1) first make a list, then study overlapping ones. If there are overlapping ones, then choose the pair that is closest with time points and distance. 
//	for this, check the number of constructed pairs. Then if the pair is multiple, check the distance and find the closest.
// (2) for those without pairs, adter (1) is finished, redo the pairing. 


//*****************************************************
macro "-"{}
//080328
// select converted track file (better filtered with tracklength) and 
macro "print XYZ track shift average and save"{
	tempstr = returnFilestring();
//	tempstr = File.openAsString(G_TrackfileFullPath);
	maxtracklength = returnThelastframeNum(tempstr);
	aveFA = newArray(maxtracklength);
	aveXA = newArray(maxtracklength);
	aveYA = newArray(maxtracklength);
	aveZA = newArray(maxtracklength);
	aveTracksA = newArray(maxtracklength);
	xshiftA = newArray(maxtracklength);
	yshiftA = newArray(maxtracklength);
	zshiftA = newArray(maxtracklength);

	lineA=split(tempstr,"\n");
	for(i=0; i<aveFA.length; i++) {
		sumX=0;
		sumY=0;
		sumZ=0;
		trackcount=0;
		for (j=0; j< lineA.length; j++) {
			linecontentA=split(lineA[j],"\t");
			if (linecontentA.length>1) {
				if (parseInt(linecontentA[1]) ==i){
					sumX+=parseFloat(linecontentA[3]);
					sumY+=parseFloat(linecontentA[2]);
					sumZ+=parseFloat(linecontentA[4]);
					trackcount++;
				} 
			}
		}
		aveXA[i] =sumX / trackcount ;
		aveYA[i] =sumY / trackcount ;
		aveZA[i] =sumZ / trackcount ;
		aveTracksA[i] = trackcount;
		xshiftA[i] = (aveXA[i] - aveXA[0]);
		yshiftA[i] = (aveYA[i] - aveYA[0]);
		zshiftA[i] = (aveZA[i] - aveZA[0]);
	}
 	print("\\Clear");
	for (i=0; i<aveXA.length; i++) {
		//print(i+": ("+aveXA[i]+","+aveYA[i]+","+aveZA[i]+") pnts:"+ aveTracksA[i]);
		//print(" shifts "+xshiftA[i]+", "+yshiftA[i]+", "+zshiftA[i]);
		print(i+"\t"+xshiftA[i]+"\t"+yshiftA[i]+"\t"+zshiftA[i]);
	}
	selectWindow("Log");
	saveAs("text");
 	print("\\Clear");
	for (i=0; i<aveXA.length; i++) {
		print(i+": ("+aveXA[i]+","+aveYA[i]+","+aveZA[i]+") pnts:"+ aveTracksA[i]);
		print(" shifts "+xshiftA[i]+", "+yshiftA[i]+", "+zshiftA[i]);
	}
}





//080328
// need shift-text file generated by macro "print XYZ track shift average and save"
macro "XYZ corrector Refer Track Average" {
	stackID = getImageID();
	znum=getNumber("Z slices?", 15);
	if (((nSlices/znum) - floor(nSlices/znum)) !=0) exit("wrong stack??");
	op = "group="+znum+" projection=[Max Intensity]";
	run("Grouped ZProjector", op);
	zprojID = getImageID();

	XYZcorrectbyTrackAve(stackID, "XY", znum, zprojID);
}

// need shift-text file generated by macro "print XYZ track shift average and save"
function XYZcorrectbyTrackAve(stackID, dimension, znum, zprojID){

	selectImage(stackID);
	//frames=nSlices;
//	if (dimension =="xz") zscale = getNumber("z scale?", 10);
	zscale = getNumber("z scale?", 10);

	selectImage(zprojID);
	imw = getWidth();
	imh = getHeight();
 	tnum = nSlices;

	newImage("xprojection", "8-bit Black", imw, znum, tnum);
	xprojID =  getImageID();
	setBatchMode(true);
	xprojectionCore(stackID, xprojID , znum);
	selectImage(xprojID);
	op = "width="+imw+" height="+zscale*znum;
	run("Size...", op);
	setBatchMode("exit and display");


	tempstr = returnFilestring();
	lineA=split(tempstr,"\n");
	currentfA = newArray(lineA.length);
	shiftxA = newArray(lineA.length);
	shiftyA = newArray(lineA.length);
	shiftzA = newArray(lineA.length);
	for (i=0; i<currentfA.length; i++) currentfA[i] = -1;

	framecount = 0;
	trackexists = 0;
	wh = getHeight();

	for (i=0; i<lineA.length; i++) {
		linecontentA=split(lineA[i],"\t");
		if (linecontentA.length>1) {
			currentfA[i] = parseInt(linecontentA[0]);
			shiftxA[i] = parseFloat(linecontentA[1]);
			shiftyA[i] = parseFloat(linecontentA[2]);
			shiftzA[i] = parseFloat(linecontentA[3]);
			print(currentfA[i] + ":dx " + shiftxA[i] + ", dy " + shiftyA[i] + ", dz " + shiftzA[i]);
		} 
	}
	selectImage(stackID);

	setBatchMode(true);
	newImage("xycorrectedZproj", "8-bit Black", imw, imh, tnum);
	zproCorjID = getImageID;	
	for(i=0; i<tnum;i++) {
		selectImage(zprojID);		
		setSlice(i+1);
		run("Select All");
		run("Copy");
		selectImage(zproCorjID);	
		setSlice(i+1);
		makeRectangle(-1*shiftxA[i], -1*shiftyA[i], imw, imh);
		run("Paste");
	}	
	newImage("xycorrected", "8-bit Black", imw, imh, tnum*znum);
	xycorID=getImageID();
	for(i=0; i<tnum;i++) {
		for(j=0; j<znum;j++) {
			selectImage(stackID);
			setSlice(i*znum+j+1);
			run("Select All");
			run("Copy");			
			selectImage(xycorID);
			setSlice(i*znum+j+1);
			makeRectangle(-1*shiftxA[i], -1*shiftyA[i], imw, imh);
			run("Paste");	
		}
	}
	setBatchMode("exit and display");

	//----------- Zshifting
	zmax = K_retrunArrayMax(shiftzA);
	zmin = K_retrunArrayMin(shiftzA);
	range = zmax -zmin;
	range = (floor(range/zscale )+1) * zscale ;			//to make it scaleable with Gzscaler	
	print("zmin"+zmin+" zmax"+zmax+"range"+range);
	newImage("z-shifted", "8-bit Black", imw, znum*zscale +range, tnum);
	zcorrectedXprojID = getImageID();

	zshiftthreshold =0.5;
	shiftzroundA= newArray(shiftzA.length);
	for (i=0; i< shiftzroundA.length; i++) {
/*		tempresidue = shiftzA[i] - floor(shiftzA[i]);
		if (abs(tempresidue) > zshiftthreshold ) {	
			yshiftaroundA[i] = round(yshiftA[i]);
		} else {
			if (yshiftA[i] >=0)
				yshiftaroundA[i] = floor(yshiftA[i]);
			else
				yshiftaroundA[i] = floor(yshiftA[i])+1;
		}			
*/
		shiftzroundA[i] = round(shiftzA[i]);
	}
	zmaxstack = K_retrunArrayMax(shiftzroundA);
	zminstack = K_retrunArrayMin(shiftzroundA);
	newzslices = znum + zmaxstack - zminstack;
	print("zminstack"+zminstack +" zmaxstack"+zmaxstack +"newslices"+newzslices );

	setBatchMode(true);
	for (i=0; i<tnum; i++) {
		selectImage(xprojID);		
		setSlice(i+1);
		run("Select All");
		run("Copy");
		selectImage(zcorrectedXprojID);	
		setSlice(i+1);
		makeRectangle(0, -1*zmin-shiftzroundA[i], imw, znum*zscale );
		run("Paste");
		print("t:" + i + "  zshift:"+shiftzA[i] + " approximated to "+ shiftzroundA[i]);
	}
	setBatchMode("exit and display");

	zexpandSwitch = 0;
	if (zexpandSwitch == 1) {
		print("New Slice Number: "+newzslices);
		newImage("z-shiftedStack", "8-bit Black", imw, imh,newzslices*tnum);
	} else {
		print("New Slice Number: "+znum);
		newImage("z-shiftedStack", "8-bit Black", imw, imh,znum*tnum);
	}
	zcorrectedStackID = getImageID();

	//condition the background
	dummyframe = 1; //frame used as default background
	setBatchMode(true);
	selectImage(stackID);
	setSlice(dummyframe);
	run("Select All");
	run("Copy");
	selectImage(zcorrectedStackID);
	for (i=0; i<nSlices; i++) {
		setSlice(i+1);
		run("Paste");			
	}
	setBatchMode("exit and display");
	
	//run("Add Noise", "stack");
	//run("Despeckle", "stack");
	setBatchMode(true);
	for (i=0; i<tnum; i++) {
		for (j=0; j<znum; j++) {
			selectImage(xycorID);
			//selectImage(stackID); //080328 without XY shifting
			setSlice(i*znum+j+1);
			run("Select All");
			run("Copy");
			selectImage(zcorrectedStackID);		
			//setSlice(i*newzslices+j+1+shiftzroundA[i]);
			if (zexpandSwitch == 1) {
				setSlice(i*newzslices+j+1-shiftzroundA[i]);
				run("Paste");			
			} else {
				if (((j - shiftzroundA[i]) >= 0) && ((j - shiftzroundA[i]) < znum)) {
					setSlice(i*znum+j+1-shiftzroundA[i]);
					run("Paste");			
				}
			}
		}
		if (abs(shiftzroundA[i])>0) {
			print("timepoint:"+i+" shifted"+shiftzroundA[i]);
		}
	}
	setBatchMode("exit and display");

		selectImage(zcorrectedStackID);
	op= "width="+imw+" height="+imh+" channels=1 slices="+znum+" frames="+tnum+" unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000 frame=[0 sec] origin=0,0";
	run("Properties...", op);



}

function K_retrunArrayMax(aA) {
	aA_max=-500000; //LIB
	for (k=0;k<aA.length;k++) if (aA_max<aA[k]) aA_max=aA[k];
	return aA_max;
 }

function K_retrunArrayMin(aA) {
	aA_min=500000; //LIB
	for (k=0;k<aA.length;k++) if (aA_min>aA[k]) aA_min=aA[k];
	return aA_min;
 }

//slice 1 comes at the bottom of the xz plane. 
function xprojectionCore(originalID, xprojID , znum) {
	selectImage(originalID);
	imw = getWidth();
	imh = getHeight();
	tnum = nSlices/znum;
	newImage("temp_timepoint", "8-bit White", imw, imh, znum);
	tempimgID = getImageID();

	for(j=0; j<tnum; j++) {
		for(i=0; i<znum; i++) {
			selectImage(originalID);
			setSlice(j * znum + i + 1);
			run("Select All");
			run("Copy");
			selectImage(tempimgID);
			setSlice(i + 1);
			run("Paste");				
		}
		selectImage(tempimgID);
		run("3D Project...", 
			"projection=[Brightest Point] axis=X-Axis slice=1 initial=90 total=1 rotation=1 lower=1 upper=255 opacity=0 surface=100 interior=50");

		setSlice(1);
		sliceypos = imh/2 + 1 - floor(znum/2);
		makeRectangle(0, sliceypos, imh, znum);
		run("Copy");
		close();
		selectImage(xprojID );	
		setSlice(j+1);
		run("Paste");
	}	
	selectImage(tempimgID);	
	close();
}


macro "-" {}

//running average in z-direction
macro "Z-axis running average" {
	stackID = getImageID();
	totalslice=nSlices;
	znum=getNumber("Z slices?", 15);
	if (((nSlices/znum) - floor(nSlices/znum)) !=0) exit("wrong stack??");

	//zprojection
	op = "group="+znum+" projection=[Max Intensity]";
	run("Grouped ZProjector", op);
	zprojID = getImageID();

	//xprojection
	selectImage(stackID);
	//frames=nSlices;
//	if (dimension =="xz") zscale = getNumber("z scale?", 10);
	zscale = getNumber("z scale?", 10);

	selectImage(zprojID);
	imw = getWidth();
	imh = getHeight();
 	tnum = nSlices;

	newImage("xprojection", "8-bit Black", imw, znum, tnum);
	xprojID =  getImageID();
	setBatchMode(true);
	xprojectionCore(stackID, xprojID , znum);
	selectImage(xprojID);
	op = "width="+imw+" height="+zscale*znum;
	run("Size...", op);
	setBatchMode("exit and display");

	newImage("z-averagedStack", "8-bit Black", imw, imh,totalslice);
	avestackID=getImageID();
	averageslices=2;
	for (j=0; j<tnum; j++) {
		for(i=0; i<averageslices-1;i++) {
			selectImage(stackID);
			run("Select All");
			run("Copy");
			selectImage(avestackID);			
			setSlice(j*znum+i+1);
			run("Paste");			
		}
		for(i=averageslices-1; i<znum;i++) {
			selectImage(stackID);
			op ="start="+(j*znum+i+1-averageslices+1)+" stop="+(j*znum+i+1)+" projection=[Average Intensity]"; 
			run("Z Project...", op);
			run("Select All");
			run("Copy");
			close();
			selectImage(avestackID);
			setSlice(j*znum+i+1);
			run("Paste");			
		}
	}

	//xprojection
	selectImage(avestackID);
	newImage("xprojection", "8-bit Black", imw, znum, tnum);
	avgxprojID =  getImageID();
	setBatchMode(true);
	xprojectionCore(avestackID, avgxprojID , znum);
	selectImage(avgxprojID );
	op = "width="+imw+" height="+zscale*znum;
	run("Size...", op);
	setBatchMode("exit and display");

			
}








