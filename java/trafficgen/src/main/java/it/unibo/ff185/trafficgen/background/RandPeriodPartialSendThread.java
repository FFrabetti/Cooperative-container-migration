package it.unibo.ff185.trafficgen.background;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Random;
import java.util.StringTokenizer;
import java.util.concurrent.BlockingQueue;

import javax.websocket.RemoteEndpoint.Basic;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class RandPeriodPartialSendThread extends Thread {

	private static final Logger logger = LogManager.getLogger();

	private int maxPeriod;
	private Basic basicRemote;
	private BlockingQueue<String> queue;

	private int chunkSize;
	private int nChunks;

	private Random rand;

	public RandPeriodPartialSendThread(int maxPeriod, Basic basicRemote, BlockingQueue<String> queue) {
		this.maxPeriod = maxPeriod;
		this.basicRemote = basicRemote;
		this.queue = queue;

		// set default values
		chunkSize = 1024;
		nChunks = 8;
		
		rand = new Random();
	}

	private String logMsg(String msg) {
		return "(thread:" + this.getName() + ") " + msg;
	}

	@Override
	public void run() {
		logger.debug(logMsg("Started"));
		
		try {
			while (!isInterrupted()) {
				int t = rand.nextInt(maxPeriod);
				logger.debug(logMsg("About to sleep for " + t + " ms"));
				sleep(t);

				String msg = queue.poll(); // Retrieves and removes the head of this queue (or null)
//				String msg = queue.peek(); // Retrieves, but does not remove, the head of this queue (or null)
				if (msg != null)
					updateParams(msg);

				sendPartial();
			}
		} catch (InterruptedException e) {
			logger.warn(logMsg("Sleep interrupted: " + e.getMessage()));
		} catch(IOException ioe) {
			logger.error(logMsg("IOException from basicRemote: " + ioe.getMessage()));
		}
	}

	private void updateParams(String msg) {
		StringTokenizer st = new StringTokenizer(msg);
		if(st.hasMoreTokens())
			nChunks = Integer.parseInt(st.nextToken());
		if(st.hasMoreTokens())
			chunkSize = Integer.parseInt(st.nextToken());
		
		logger.debug(logMsg("New parameters: nChunks=" + nChunks + ", chunkSize=" + chunkSize));
	}

	private void sendPartial() throws IOException {
		for(int i=1; i<=nChunks; i++) {
			byte[] byteArray = new byte[chunkSize];
//			ByteBuffer buffer = ByteBuffer.allocate(chunkSize);

			logger.info(logMsg("Sending binary chunk " + i + " of " + nChunks));
			basicRemote.sendBinary(ByteBuffer.wrap(byteArray), i==nChunks); // sync
			logger.info(logMsg("Chunk sent"));
		}
	}

}
