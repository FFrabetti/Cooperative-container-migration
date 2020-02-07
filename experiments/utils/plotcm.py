import csv
import os
import sys
import time
import matplotlib.pyplot as plt

def plotter(dirname):
	datapath=os.path.join(dirname, 'results.csv')
	resultpath = os.path.join(dirname, 'results')

	infile = open(migrpath, 'r')
	migrline = infile.readline().strip()
	mig_ts = []
	for mtime in migrline.split():
		mig_ts.append((int(mtime[:10])))

	with open(datapath) as csvfile:
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
		for row in csvreader:
			if ( (mig_ts[0]-15) <= int(row[0]) <= (mig_ts[1]+15) ):
				timestamp_all.append(row[0])
				load_cli.append(round((100-float(row[1]))/100,2))
				load_dst.append(round((100-float(row[2]))/100,2))
				load_n1.append(round((100-float(row[3]))/100,2))
				load_n2.append(round((100-float(row[4]))/100,2))
				load_src.append(round((100-float(row[5]))/100,2))
				trafficin_cli.append(round(float(row[6]),2))
				trafficout_cli.append(round(float(row[7]),2))
				trafficin_dst.append(round(float(row[8]),2))
				trafficout_dst.append(round(float(row[9]),2))
				latency_after.append(round(float(row[10]),2))
				latency_before.append(round(float(row[11]),2))
				trafficin_n1.append(round(float(row[12]),2))
				trafficout_n1.append(round(float(row[13]),2))
				trafficin_n2.append(round(float(row[14]),2))
				trafficout_n2.append(round(float(row[15]),2))
				trafficin_src.append(round(float(row[16]),2))
				trafficout_src.append(round(float(row[17]),2))
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
	plt.plot(load_n1)
	plt.plot(load_n2)
	plt.legend(["Client", "Destination", "Source", "n1", "n2"])
	plt.xlabel("Time Tick")
	plt.ylabel("EC Node Load")
	plt.title("")
	plt.savefig(loadres)
	plt.clf()

	plt.figure(2)
	plt.plot(trafficin_cli)
	plt.plot(trafficin_dst)
	plt.plot(trafficin_src)
	plt.plot(trafficin_n1)
	plt.plot(trafficin_n2)
	plt.legend(["Client", "Destination", "Source", "n1", "n2"])
	plt.xlabel("Time Tick")
	plt.ylabel("Packet Traffic (KB/s)")
	plt.title("IN")
	plt.savefig(trafficinres)
	plt.clf()

	plt.figure(3)
	plt.plot(trafficout_cli)
	plt.plot(trafficout_dst)
	plt.plot(trafficout_src)
	plt.plot(trafficout_n1)
	plt.plot(trafficout_n2)
	plt.legend(["Client", "Destination", "Source", "n1", "n2"])
	plt.xlabel("Time Tick")
	plt.ylabel("Packet Traffic (Bytes/s)")
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
