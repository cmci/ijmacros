"""
Single frame net displacement plotting version of 3dextractor.py.
Converts 4D hyperstack to 3D stack with ortho-views in xy, xz, yz, each with Max projections.
Then 2D vectors are plotted all in the first frame ortho view, according to the specified data file. 
(output of 4D visualizaiton plotter, Plot_4D.jar and net displacements)

Requires emblTool.jar package. 

20120220 First Version
20120221 bug fixes
Kota Miura (miura@embl.de)
"""
from emblcmci import Extractfrom4D
from emblcmci import XYZMaxProject
from java.util import ArrayList

from ij import IJ
from ij import ImageStack, ImagePlus
from java.util import ArrayList
from util.opencsv import CSVReader
from java.io import FileReader
from java.awt import Color

import os

def readCSV(filepath):
   reader = CSVReader(FileReader(filepath), ",")
   ls = reader.readAll()
   data = ArrayList()
   for item in ls:
   	  data.add(item)
   return data



# extracting stack time frames and convert to ortho

filepath = '/Users/miura/Dropbox/Mette/20_23h/20_23hrfull_corrected_1_6_6_netdispZ35.csv'
#filepath = '/Users/miura/Dropbox/Mette/20_23h/20_23hrfull_corrected_1_6_6_netdispZ0.csv'
#filepath = 'Z:/mette/20_23h_firstSample/netdisp/20_23hrfull_corrected_1_6_6_netdispZ0.csv'
imp = IJ.getImage()
e4d = Extractfrom4D()
e4d.setGstarttimepoint(1)
IJ.log("current time point" + str(1))
aframe = e4d.coreheadless(imp, 3)
ortho = XYZMaxProject(aframe)
orthoimp = ortho.getXYZProject()
out = orthoimp

IJ.run(out, "Grays", "");
IJ.run(out, "RGB Color", "");
out.setCalibration(imp.getCalibration().copy())

# load data from file
filename = os.path.basename(filepath)
newfilename = os.path.join(os.path.splitext(filename)[0], '_plot.tif')

data = readCSV(filepath)
calib = imp.getCalibration()
xscale = calib.pixelWidth
yscale = calib.pixelHeight
zscale = calib.pixelDepth
cred = Color(255, 0, 0)
cblue = Color(0, 0, 255)
xoffset = imp.getWidth()
yoffset = imp.getHeight()
ip = out.getProcessor()
for d in data:
   frame = int(d[1])
   x1 = int(round(float(d[2]) / xscale))
   y1 = int(round(float(d[3]) / xscale))
   z1 = int(round(float(d[4]) / xscale))   
   x2 = int(round(float(d[5]) / xscale))
   y2 = int(round(float(d[6]) / xscale))
   z2 = int(round(float(d[7]) / xscale))
   direction = float(d[8])
   if direction <= 0:
      ip.setColor(Color(255, 100, 100))
   else:
      ip.setColor(Color(100, 100, 255))
   ip.setLineWidth(1)
   ip.drawLine(x1, y1, x2, y2)
   ip.drawLine(x1, yoffset+ z1, x2, yoffset+z2)
   ip.drawLine(xoffset+z1, y1, xoffset+z2, y2)
#out.updateAndDraw()
# plot 
#out.show()
outimp = ImagePlus(os.path.basename(filename)+'_Out.tif', ip)
outimp.show()
