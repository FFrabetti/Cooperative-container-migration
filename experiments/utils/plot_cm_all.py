import os
import time
import plotcm

print("Plotting all the results!")
d='.'
for x in os.listdir(d):
	if os.path.isdir(os.path.join(d, x)):
		print(x)
		plotcm.plotter(x)
 