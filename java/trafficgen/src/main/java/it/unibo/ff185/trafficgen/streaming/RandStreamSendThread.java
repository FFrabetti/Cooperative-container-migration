package it.unibo.ff185.trafficgen.streaming;

import java.io.IOException;
import java.io.OutputStream;

import javax.websocket.RemoteEndpoint.Basic;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import it.unibo.ff185.trafficgen.utils.RandWriter;

public class RandStreamSendThread extends Thread {

	private static final int PERIOD = 1000; // 1s
	
	private static final Logger logger = LogManager.getLogger();

	private int Bps;
	private Basic basicRemote;

	public RandStreamSendThread(int Bps, Basic basicRemote) {
		this.Bps = Bps;
		this.basicRemote = basicRemote;
	}

	private String logMsg(String msg) {
		return "(thread:" + this.getName() + ") " + msg;
	}

	@Override
	public void run() {
		logger.debug(logMsg("Started"));
		
		try(OutputStream os = basicRemote.getSendStream()) {
			RandWriter rWriter = new RandWriter(os);
			
			while (!isInterrupted()) {
				logger.debug(logMsg("About to sleep for " + PERIOD + " ms"));
				sleep(PERIOD);
				
				int b = (int) (Bps * PERIOD/1000.0);
				logger.debug(logMsg("Writing " + b + " bytes"));
				rWriter.print(b);
			}
		} catch (InterruptedException e) {
			logger.warn(logMsg("Sleep interrupted: " + e.getMessage()));
		} catch(IOException ioe) {
			logger.error(logMsg("IOException from basicRemote: " + ioe.getMessage()));
		}
	}

}
