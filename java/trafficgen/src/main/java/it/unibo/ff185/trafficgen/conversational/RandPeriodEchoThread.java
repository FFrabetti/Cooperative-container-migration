package it.unibo.ff185.trafficgen.conversational;

import java.io.IOException;
import java.util.Random;
import java.util.concurrent.BlockingQueue;

import javax.websocket.RemoteEndpoint.Basic;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class RandPeriodEchoThread extends Thread {

	private static final Logger logger = LogManager.getLogger();

	private int maxPeriod;
	private Basic basicRemote;
	private BlockingQueue<String> queue;

	private String lastMessage;
	private int counter;

	private Random rand;

	public RandPeriodEchoThread(int maxPeriod, Basic basicRemote, BlockingQueue<String> queue) {
		this.maxPeriod = maxPeriod;
		this.basicRemote = basicRemote;
		this.queue = queue;

		setNewMessage("");
		
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
					setNewMessage(msg);

				counter++;
				String message = counter + " " + lastMessage;
				logger.info(logMsg("Sending message: " + message));
				basicRemote.sendText(message); // sync
				logger.info(logMsg("Message sent"));
			}
		} catch (InterruptedException e) {
			logger.warn(logMsg("Sleep interrupted: " + e.getMessage()));
		} catch(IOException ioe) {
			logger.error(logMsg("IOException from basicRemote.sendText: " + ioe.getMessage()));
		}
	}

	private void setNewMessage(String msg) {
		lastMessage = msg;
		counter = 0;
	}

}
