import csv
import os
import sys
import time
import matplotlib.pyplot as plt

def getIndex(arr, str):
	i = 0
	for a in arr:
		if a.find(str) >= 0:
			return i
		i+=1
	return -1

def plotter(dirname):
	datapath = os.path.join(dirname, 'results.csv')
	resultpath = os.path.join(dirname, 'results')
	migrpath = os.path.join(dirname, 'migr_time')
	
	infile = open(migrpath, 'r')
	migrline = infile.readline().strip()
	mig_ts = []
	for mtime in migrline.split():
		mig_ts.append((int(mtime[:10])))
			
	with open(datapath) as csvfile:
		print(mig_ts[0]-15)
		print(mig_ts[1]+15)
		
		timestamp_all = []
		load_cli = []
		load_dst = []
		load_src = []
		trafficin_cli = []
		trafficout_cli = []
		trafficin_dst = []
		trafficout_dst = []
		latency_before = []
		latency_after = []
		trafficin_src = []
		trafficout_src = []
		csvreader = csv.reader(csvfile, delimiter=',', quotechar='|')
		first_row = next(csvreader)
		
		load_cli_i = getIndex(first_row, 'load_cli')
		load_dst_i = getIndex(first_row, 'load_dst')
		load_src_i = getIndex(first_row, 'load_src')
		tin_cli_i = getIndex(first_row, 'traffic_cli.txt_in')
		tin_dst_i = getIndex(first_row, 'traffic_dst.txt_in')
		tin_src_i = getIndex(first_row, 'traffic_src.txt_in')
		tout_cli_i = getIndex(first_row, 'traffic_cli.txt_out')
		tout_dst_i = getIndex(first_row, 'traffic_dst.txt_out')
		tout_src_i = getIndex(first_row, 'traffic_src.txt_out')
		lafter_i = getIndex(first_row, 'after_trafficgencl')
		lbefore_i = getIndex(first_row, 'before_trafficgencl')
				
		for row in csvreader:
			if ( (mig_ts[0]-15) <= int(row[0]) <= (mig_ts[1]+15) ):
				timestamp_all.append(row[0])
				load_cli.append(round((100-float(row[load_cli_i]))/100,2))
				load_dst.append(round((100-float(row[load_dst_i]))/100,2))
				load_src.append(round((100-float(row[load_src_i]))/100,2))
				trafficin_cli.append(round(float(row[tin_cli_i]),2))
				trafficout_cli.append(round(float(row[tout_cli_i]),2))
				trafficin_dst.append(round(float(row[tin_dst_i]),2))
				trafficout_dst.append(round(float(row[tout_dst_i]),2))
				latency_after.append(round(float(row[lafter_i]),2))
				latency_before.append(round(float(row[lbefore_i]),2))
				trafficin_src.append(round(float(row[tin_src_i]),2))
				trafficout_src.append(round(float(row[tout_src_i]),2))
	csvfile.close()

	try:
		os.mkdir(resultpath)
	except OSError:
		print ("Creation of the directory %s failed" % resultpath)
	else:
		print ("Successfully created the directory %s " % resultpath)
	
	loadres = os.path.join(resultpath, 'load.png')
	trafficinres = os.path.join(resultpath, 'trafficin.png')
	trafficoutres = os.path.join(resultpath, 'trafficout.png')
	latencyres = os.path.join(resultpath, 'latency.png')
	print("creating ",loadres)
	print("creating ",trafficinres)
	print("creating ",trafficoutres)
	print("creating ",latencyres)
	
	plt.figure(1)
	plt.plot(load_cli)
	plt.plot(load_dst)
	plt.plot(load_src)
	plt.legend(["Client", "Destination", "Source"])
	plt.xlabel("Time Tick")
	plt.ylabel("EC Node Load")
	plt.title("")
	plt.savefig(loadres)
	plt.clf()

	plt.figure(2)
	plt.plot(trafficin_cli)
	plt.plot(trafficin_dst)
	plt.plot(trafficin_src)
	plt.legend(["Client", "Destination", "Source"])
	plt.xlabel("Time Tick")
	plt.ylabel("Packet Traffic (KB/s)")
	plt.title("IN")
	plt.savefig(trafficinres)
	plt.clf()

	plt.figure(3)
	plt.plot(trafficout_cli)
	plt.plot(trafficout_dst)
	plt.plot(trafficout_src)
	plt.legend(["Client", "Destination", "Source"])
	plt.xlabel("Time Tick")
	plt.ylabel("Packet Traffic (KB/s)")
	plt.title("OUT")
	plt.savefig(trafficoutres)
	plt.clf()

	plt.figure(4)
	plt.plot(latency_before)
	plt.plot(latency_after)
	plt.legend(["Before Migration", "After Migration"])
	plt.xlabel("Time Tick")
	plt.ylabel("Total Response Time (ms)")
	plt.title("Impact of Migration on Application QoS")
	plt.savefig(latencyres)
	plt.clf()
	return 0
