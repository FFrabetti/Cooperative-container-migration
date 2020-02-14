import os
import time
import plotcm, plottm
import sys

print("Plotting all the results!")
d = '.'
if len(sys.argv) == 2:
	d = sys.argv[1]

for x in os.listdir(d):
	fullpath = os.path.join(d, x)
	if os.path.isdir(fullpath):
		print(fullpath)
		if x.startswith('tm'):
			plottm.plotter(fullpath)
		else:
			plotcm.plotter(fullpath)
