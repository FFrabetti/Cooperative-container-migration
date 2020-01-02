package it.unibo.ff185.trafficgencl;

import java.io.IOException;
import java.io.InputStream;

import org.apache.logging.log4j.Logger;

public class ConsumeInputStreamThread extends Thread {

	private InputStream stream;
	private Logger logger;

	public ConsumeInputStreamThread(InputStream stream, Logger logger) {
		this.stream = stream;
		this.logger = logger;
	}

	@Override
	public void run() {
		logger.debug("Started thread=" + this.getName());
		
		try {
			while (stream.read() >= 0);
		} catch (IOException e) {
			e.printStackTrace();
		}

		logger.debug(this.getName() + " end");
	}

}
