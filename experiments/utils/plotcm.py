import csv
import os
import sys
import time
import matplotlib.pyplot as plt

linestyle = ['--', '-.', ':', '-', ' ']

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
		load_n1 = []
		load_n2 = []
		load_src = []
		trafficin_cli = []
		trafficout_cli = []
		trafficin_dst = []
		trafficout_dst = []
		latency_after = []
		latency_before = []
		trafficin_n1 = []
		trafficout_n1 = []
		trafficin_n2 = []
		trafficout_n2 = []
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
		
		load_n1_i = getIndex(first_row, 'load_n1')
		tin_n1_i = getIndex(first_row, 'traffic_n1.txt_in')
		tout_n1_i = getIndex(first_row, 'traffic_n1.txt_out')
		load_n2_i = getIndex(first_row, 'load_n2')
		tin_n2_i = getIndex(first_row, 'traffic_n2.txt_in')
		tout_n2_i = getIndex(first_row, 'traffic_n2.txt_out')
		
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

				load_n1.append(round((100-float(row[load_n1_i]))/100,2))
				load_n2.append(round((100-float(row[load_n2_i]))/100,2))
				trafficin_n1.append(round(float(row[tin_n1_i]),2))
				trafficout_n1.append(round(float(row[tout_n1_i]),2))
				trafficin_n2.append(round(float(row[tin_n2_i]),2))
				trafficout_n2.append(round(float(row[tout_n2_i]),2))
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
	plt.plot(load_cli, linestyle=linestyle[0], linewidth=3)
	plt.plot(load_dst, linestyle=linestyle[1], linewidth=3)
	plt.plot(load_src, linestyle=linestyle[2], linewidth=3)
	plt.plot(load_n1, linestyle=linestyle[3], linewidth=3)
	plt.plot(load_n2, linestyle=linestyle[4], linewidth=3)
	plt.legend(["Client", "Destination", "Source", "n1", "n2"])
	plt.xlabel("Time Tick", fontsize=12, fontweight='bold')
	plt.ylabel("EC Node Load", fontsize=12, fontweight='bold')
	ax = plt.gca()
	ax.tick_params(width=5)
	plt.grid(True)
	plt.title("Load Variations")
	plt.savefig(loadres)
	plt.clf()

	plt.figure(2)
	plt.plot(trafficin_cli, linestyle=linestyle[0], linewidth=3)
	plt.plot(trafficin_dst, linestyle=linestyle[1], linewidth=3)
	plt.plot(trafficin_src, linestyle=linestyle[2], linewidth=3)
	plt.plot(trafficin_n1, linestyle=linestyle[3], linewidth=3)
	plt.plot(trafficin_n2, linestyle=linestyle[4], linewidth=3)
	plt.legend(["Client", "Destination", "Source", "n1", "n2"])
	plt.xlabel("Time Tick", fontsize=12, fontweight='bold')
	plt.ylabel("Packet Traffic (KB/s)", fontsize=12, fontweight='bold')
	plt.grid(True)
	ax = plt.gca()
	ax.tick_params(width=5)
	plt.title("Traffic IN")
	plt.savefig(trafficinres)
	plt.clf()

	plt.figure(3)
	plt.plot(trafficout_cli, linestyle=linestyle[0], linewidth=3)
	plt.plot(trafficout_dst, linestyle=linestyle[1], linewidth=3)
	plt.plot(trafficout_src, linestyle=linestyle[2], linewidth=3)
	plt.plot(trafficout_n1, linestyle=linestyle[3], linewidth=3)
	plt.plot(trafficout_n2, linestyle=linestyle[4], linewidth=3)
	plt.legend(["Client", "Destination", "Source", "n1", "n2"])
	plt.xlabel("Time Tick", fontsize=12, fontweight='bold')
	plt.ylabel("Packet Traffic (KB/s)", fontsize=12, fontweight='bold')
	plt.grid(True)
	ax = plt.gca()
	ax.tick_params(width=5)
	plt.title("Traffic OUT")
	plt.savefig(trafficoutres)
	plt.clf()

	plt.figure(4)
	plt.plot(latency_before, linestyle=linestyle[0], linewidth=3)
	plt.plot(latency_after, linestyle=linestyle[1], linewidth=3)
	plt.legend(["Before Migration", "After Migration"])
	plt.xlabel("Time Tick", fontsize=12, fontweight='bold')
	plt.ylabel("Total Response Time (ms)", fontsize=12, fontweight='bold')
	plt.grid(True)
	ax = plt.gca()
	ax.tick_params(width=5)
	plt.axhline(100, color='r--')
	plt.title("Impact of Migration on Application QoS")
	plt.savefig(latencyres)
	plt.clf()
	return 0
