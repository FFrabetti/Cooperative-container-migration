import os
import time
import plotsf

print("Plotting all the results!")
d='.'
for x in os.listdir(d):
	if os.path.isdir(os.path.join(d, x)):
		print(x)
		plotsf.plotter(x)
 