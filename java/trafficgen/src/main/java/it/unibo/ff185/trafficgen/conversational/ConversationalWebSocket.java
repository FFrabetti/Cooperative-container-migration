package it.unibo.ff185.trafficgen.conversational;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import javax.websocket.CloseReason;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@ServerEndpoint("/conversational/{max-period}")
public class ConversationalWebSocket {
	
	private static final String THREAD = "thread";
	private static final String QUEUE = "queue";
	private static final int QUEUE_CAPACITY = 16;

	private static final Logger logger = LogManager.getLogger();
	
	private String logMsg(String msg, Session session) {
		return "(" + session.getId() + ") " + msg;
	}
	
	@OnOpen
	public void OnOpen(Session session, EndpointConfig config, @PathParam("max-period") int maxPeriod) {
		logger.debug(logMsg("Open websocket with maxPeriod=" + maxPeriod, session));
		
		if(maxPeriod > 0) {
			BlockingQueue<String> queue = new ArrayBlockingQueue<>(QUEUE_CAPACITY);
			Thread thread = new RandPeriodEchoThread(maxPeriod, session.getBasicRemote(), queue);
			thread.start();
			
			session.getUserProperties().put(QUEUE, queue);
			session.getUserProperties().put(THREAD, thread);
		}
		else
			logger.warn(logMsg("maxPeriod is not positive", session));
	}
	
	@OnClose
	public void OnClose(Session session, CloseReason reason) {
		logger.debug(logMsg("Close: " + reason.getReasonPhrase() + " (" + reason.getCloseCode() + ")", session));
		terminateThread(session);
	}
	
	@OnError
	public void OnError(Session session, Throwable err) {
		logger.error(logMsg("Error: " + err.getMessage(), session));
		terminateThread(session);
	}
	
	@OnMessage
	public void OnMessage(Session session, String msg) {
		logger.info(logMsg("Message received: " + msg, session));
		
		@SuppressWarnings("unchecked")
		BlockingQueue<String> queue = (BlockingQueue<String>)session.getUserProperties().get(QUEUE);
		if(queue != null) {
			boolean queued = queue.offer(msg); // false if queue is full
			logger.debug(logMsg("Queuing message result=" + queued, session));
		}
	}

	private void terminateThread(Session session) {
		Thread thread = (Thread)session.getUserProperties().get(THREAD);
		if(thread != null && thread.isAlive()) {
			logger.debug(logMsg("Interrupting thread=" + thread.getName(), session));
			thread.interrupt();
		}
	}

}
