//080911
// for screening dots. 
/*
1, 

*/
macro "Frame Wise particle Positions Converter"{
 	print("\\Clear");
	fullpathname = File.openDialog("Select a track File");
	openedDirectory = File.getParent(fullpathname );
	openedFile = File.getName(fullpathname );
	tempstr = File.openAsString(fullpathname);
	//tempstr = File.openAsString("");
	linesA=split(tempstr,"\n");
	frameCount=0;
	//f1 = File.open("converted.txt");
	framestr = "";	//for storing values
	for (i=0; i < linesA.length; i++) {
		templinestr=linesA[i];
		comparestr="% Frame " + frameCount + ":";
		if (templinestr==comparestr) {
			//print("check");
			//traj_startline=i;
			do {
				i++;
			} while (startsWith(linesA[i], "%	Particles after non-particle discrimination") == 0);

			comparestr3="% Frame " + frameCount+1 + ":";
			i++; //onle shift
			do {
				param1A=split(linesA[i], "\t");
				paramA=split(param1A[1], " ");
				tempstr2="";
				for (j = 0; j<paramA.length; j++) {
					tempstr2=tempstr2+paramA[j]+"\t";
				}
				tempstrSingleLine =""+ frameCount + "\t" + tempstr2;
				print(CommaEliminator(tempstrSingleLine ));
				framestr =framestr+CommaEliminator(tempstrSingleLine )+"\n";
				i++;
				
			} while ((linesA[i]!=comparestr3) && (startsWith(linesA[i], "% Trajectory linking") ==0));
			print("");
			frameCount ++;
			i--;
		}
		//if (tempstr=="%% Trajectories:") print(i);
	}	
	//File.close(f1);
	//selectWindow("Log");
	//saveAs("text");

	print(fullpathname);

	//from here 080911
	lineFramesA=split(framestr,"\n");	// this does not have space between different frames. 

	currentfA = newArray(lineFramesA.length);	//0
	currentxA = newArray(lineFramesA.length);	//1
	currentyA = newArray(lineFramesA.length);	//2
	currentzA = newArray(lineFramesA.length);	//3
	currentm0A= newArray(lineFramesA.length);	//4
	currentm1A= newArray(lineFramesA.length);	//5
	currentm2A= newArray(lineFramesA.length);	//6
	currentm3A= newArray(lineFramesA.length);	//7
	currentm4A= newArray(lineFramesA.length);	//8
	currentsA= newArray(lineFramesA.length);	//9

	for (i=0; i<currentfA.length; i++) {
		currentfA[i] = -1;
		currentxA[i] = -1;
		currentyA[i] = -1;
		currentzA[i] = -1;

	}

	for (k=0; k<lineFramesA.length; k++) {
		linecontentA=split(lineFramesA[k],"\t");
		if (linecontentA.length>1) {
			currentfA[k] = parseFloat(linecontentA[0]);
			//currentxA[k] = parseFloat(linecontentA[2]);	//did this bug fixed (inversed xy)
			//currentyA[k] = parseFloat(linecontentA[1]);
			currentxA[k] = parseFloat(linecontentA[1]);
			currentyA[k] = parseFloat(linecontentA[2]);
			currentzA[k] = parseFloat(linecontentA[3]);
			currentm0A[k] =parseFloat(linecontentA[4]);
			currentsA[k] = parseFloat(linecontentA[9]);

		} else {
			currentfA[k] = -1;
			currentxA[k] = -1;
			currentyA[k] = -1;
			currentzA[k] = -1;
			currentm0A[k] = -1;
			currentsA[k] = -1;
		} 
	}
	print("Frameinfo Particle number:"+currentxA.length);
	// Down to here, finished storing FrameWise positions



//	for (i=0; i< currentxA.length; i++) 
//		print(currentxA[i]+", "+currentyA[i]+", "+currentzA[i]+"	"+currentNonePcritA[i]);
		
	//optNPV=OptimumNonePtclVfinder(80, currentNonePcritA);

	//estimate the number of frames, count the number of particles 
	maxframenum =0;
	for(i=0; i<currentfA.length; i++ ) if (maxframenum<currentfA[i]) maxframenum=currentfA[i];
	framewiseOptNPVA = newArray(maxframenum+1);
	for(i=0; i<framewiseOptNPVA.length; i++ ) framewiseOptNPVA[i] =i;
	framewiseparticleNumA = newArray(maxframenum+1);
	for(i=0; i<currentfA.length; i++ ) framewiseparticleNumA[currentfA[i]]+=1 ;
	
	// check if each frame contains more particles than expected value.

	PtclNumPerFrame =40;
	for(i=0; i<framewiseparticleNumA.length; i++) {
		print("frame"+i+" -->"+framewiseparticleNumA[i]+" particles");
		if(framewiseparticleNumA[i]<PtclNumPerFrame) exit("frame"+i+" is less than "+PtclNumPerFrame+"particles");
	}
	//
	selectedfA =newArray(PtclNumPerFrame * framewiseOptNPVA.length);
	selectedxA =newArray(PtclNumPerFrame * framewiseOptNPVA.length);
	selectedyA =newArray(PtclNumPerFrame * framewiseOptNPVA.length);
	selectedzA =newArray(PtclNumPerFrame * framewiseOptNPVA.length);
	selectedm0A =newArray(PtclNumPerFrame * framewiseOptNPVA.length);
	selectedNPVA =newArray(PtclNumPerFrame * framewiseOptNPVA.length);

/*	//SELECTION BY NON PARTICLE DISCRIMINATION  copy particles from each frame, select 40 of them with larger NPV, and then store them in a new array. 
	for(j=0; j<framewiseOptNPVA.length; j++) {
		print("current frame:"+j);
		tempNonePA = newArray(framewiseparticleNumA[j]);
		counter1 =0;
		//for(k=0; k<currentNonePcritA.length; k++) {
		for(k=0; k<currentsA.length; k++) {
			if(currentfA[k]==j) {
				//tempNonePA[counter1] = parseFloat(currentNonePcritA[k]);
				tempNonePA[counter1] = parseFloat(currentsA[k]);
				counter1++;
			}
		}
		//optNPV=parseFloat(OptimumNonePtclVfinderBySort(80, currentNonePcritA));
		//print("optimumNPV ="+optNPV);
		framewiseOptNPVA[j]=parseFloat(OptimumNonePtclVfinderBySort(PtclNumPerFrame , tempNonePA));
		print("None Particle value threshold frame"+i+" value="+framewiseOptNPVA[j]);
		countSelected=0;
		//for(i=0; i< currentNonePcritA.length; i++) {
		for(i=0; i< currentsA.length; i++) {
			if (currentfA[i] ==j) {
				//if (parseFloat(currentNonePcritA[i])>parseFloat(framewiseOptNPVA[j])) {
				if (parseFloat(currentsA[i])>parseFloat(framewiseOptNPVA[j])) {
					print(countSelected+":--"+currentfA[i]+":"+currentxA[i]+", "+currentyA[i]+", "+currentzA[i]+" --> "+currentsA[i]);
					selectedfA[j * PtclNumPerFrame+countSelected] = currentfA[i];
					selectedxA[j * PtclNumPerFrame+countSelected] = currentxA[i];
					selectedyA[j * PtclNumPerFrame+countSelected] = currentyA[i];
					selectedzA[j * PtclNumPerFrame+countSelected] = currentzA[i];
					selectedNPVA[j * PtclNumPerFrame+countSelected] = currentsA[i];

					countSelected+=1;
				}
			}

		}
	}
*/
	//SELECTION BY m0 (sum of intensity in the particle) 080919

	for(j=0; j<framewiseOptNPVA.length; j++) {
		print("current frame:"+j);
		tempNonePA = newArray(framewiseparticleNumA[j]);
		counter1 =0;
		for(k=0; k<currentm0A.length; k++) {
			if(currentfA[k]==j) {
				tempNonePA[counter1] = parseFloat(currentm0A[k]);
				counter1++;
			}
		}
		framewiseOptNPVA[j]=parseFloat(OptimumNonePtclVfinderBySort(PtclNumPerFrame , tempNonePA));
		print("m0 threshold frame"+j+" value="+framewiseOptNPVA[j]);
		countSelected=0;
		//for(i=0; i< currentNonePcritA.length; i++) {
		for(i=0; i< currentm0A.length; i++) {
			if (currentfA[i] ==j) {
				//if (parseFloat(currentNonePcritA[i])>parseFloat(framewiseOptNPVA[j])) {
				if (parseFloat(currentm0A[i])>parseFloat(framewiseOptNPVA[j])) {
					print(countSelected+":--"+currentfA[i]+":"+currentxA[i]+", "+currentyA[i]+", "+currentzA[i]+" --> m0: "+currentm0A[i]);
					selectedfA[j * PtclNumPerFrame+countSelected] = currentfA[i];
					selectedxA[j * PtclNumPerFrame+countSelected] = currentxA[i];
					selectedyA[j * PtclNumPerFrame+countSelected] = currentyA[i];
					selectedzA[j * PtclNumPerFrame+countSelected] = currentzA[i];
					selectedm0A[j * PtclNumPerFrame+countSelected] = currentm0A[i];
					selectedNPVA[j * PtclNumPerFrame+countSelected] = currentsA[i];

					countSelected+=1;
				}
			}

		}
	}

	for(i=0; i<selectedfA.length; i++) {
		//offset =j * PtclNumPerFrame;
		//print(selectedfA[offset+i]+"\t"+selectedxA[offset+i]+"\t"+selectedyA[offset+i]+"\t"+selectedzA[offset+i]+"\t"+selectedNPVA[offset+i]);
		print(i+":  "+selectedfA[i]+"\t"+selectedxA[i]+"\t"+selectedyA[i]+"\t"+selectedzA[i]+"\t"+selectedNPVA[i]);
	}

	// FURTHER WORK: plot particles in a new 3D stack.	--> this function should exist somewhere in previous macro. 

/*	tttA=split(linesA[7], " ");
	print(tttA[3]);
	tttA=split(linesA[8], " ");
	print(tttA[2]);
	tttA=split(linesA[9], " ");
	print(tttA[2]);
*/


	tttA=split(linesA[7], " ");
	ww = tttA[3]; //getNumber("Width?", 100);
	tttA=split(linesA[8], " ");
	hh =  parseInt(tttA[2]); //getNumber("Height?", 100);
	tttA=split(linesA[9], " ");
	zz =  parseInt(tttA[2]); //getNumber("zsices?", 10);
	tframes =  getNumber("time points?", 100);
	print("w="+ww+" h="+hh+"z="+zz+" t="+tframes);
	Plot4Dstack(ww, hh, zz, tframes, selectedfA, selectedxA, selectedyA, selectedzA, "RePlot4D");
	op ="group="+zz+" projection=[Max Intensity]";
	run("Grouped ZProjector", op);

	Plot4Dstack(ww, hh, zz, tframes, currentfA, currentxA, currentyA, currentzA, "ALLPlot4D");
	op ="group="+zz+" projection=[Max Intensity]";
	run("Grouped ZProjector", op);
	
	// Initial parameters for the particle detection+ screening. not only intensity (check for neighboring dots, to remove the redundancy). 

}

function Plot4Dstack(ww, hh, zz, tframes, selectedfA, selectedyA, selectedxA, selectedzA, stacktitleS){
	dotsize = 1;
	newImage(stacktitleS, "8-bit Black", ww, hh, zz*tframes);
	op = "width="+ww+" height="+hh+" channels=1 slices="+zz+" frames="+tframes+" unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000 frame=[0 sec] origin=0,0";
	run("Properties...", op);
	setColor(255);
	radius = round(dotsize/2);
	for(i=0; i<selectedfA.length; i++) {
		zpos = round(selectedzA[i]);
		if (zpos>zz) zpos=zz;
		setSlice(selectedfA[i]*zz+zpos+1);
//		drawOval(round(selectedxA[i])-radius, round(selectedyA[i])-radius, dotsize, dotsize);
		drawOval(round(selectedxA[i]), round(selectedyA[i]), dotsize, dotsize);
	}
}


function CommaEliminator(strval) {
	while (indexOf(strval, ",")>0) {
			delindex = indexOf(strval, ",");
			returnstr = substring(strval, 0, delindex) + substring(strval, delindex+1, lengthOf(strval));
			strval = returnstr ;
	}	 	
	return strval;
}


function OptimumNonePtclVfinder(expectedparticleNum, tempNonePA) {
	NPV = 0;
	increment = 0.001;
	if (currentNonePcritA.length<expectedparticleNum) {
		NPV = -1;
	} else {
		tempNPV=0;
		do {
			counted=0;
			for(i=0; i< currentNonePcritA.length; i++) {
				if ((currentNonePcritA[i]>=0) && (currentNonePcritA[i]<tempNPV)) {
					counted+=1;
				}
				//print(currentNonePcritA[i]+"::"+tempNPV);
				//}
			} 
			tempNPV+=increment ;
		} while (counted<expectedparticleNum);
		print(counted);
		NPV = tempNPV-increment;
	}
	return NPV;
}

function OptimumNonePtclVfinderBySort(expectedparticleNum, currentNonePcritA) {
	duplicateA = newArray(currentNonePcritA.length);
	dummyA = newArray(currentNonePcritA.length);
	for(i=0; i< duplicateA.length; i++) duplicateA[i] = currentNonePcritA[i];
	for(i=0; i< duplicateA.length; i++) dummyA [i] = i;
	BubbleSortWithKeyFloat(duplicateA, dummyA);
	for(i=0; i<duplicateA.length; i++) print(duplicateA[i]);
	//return duplicateA[expectedparticleNum];		//include those with small number
	return duplicateA[duplicateA.length-expectedparticleNum-1];
}

function BubbleSortWithKey(keyA, slaveA) {
	k=keyA.length-1;
	while (k>=0) {
		j=-1;
		for (i=1; i<=k; i++) { 
			if (keyA[i-1] > keyA[i]) {
				j = i-1;
				swap = keyA[j];
				keyA[j] = keyA[i];
				keyA[i] = swap;	

				swap = slaveA[j];
				slaveA[j] = slaveA[i];
				slaveA[i] = swap;
			}
		}
		k = j;
	}
}

function BubbleSortWithKeyFloat(keyA, slaveA) {
	k=keyA.length-1;
	while (k>=0) {
		j=-1;
		for (i=1; i<=k; i++) { 
			if (parseFloat(keyA[i-1]) > parseFloat(keyA[i])) {
				j = i-1;
				swap = parseFloat(keyA[j]);
				keyA[j] = parseFloat(keyA[i]);
				keyA[i] =parseFloat(swap);	

				swap = parseFloat(slaveA[j]);
				slaveA[j] = parseFloat(slaveA[i]);
				slaveA[i] = parseFloat(swap);
			}
		}
		k = j;
	}
}
