package it.unibo.ff185.trafficgen.conversational;

import java.util.Map;
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

	protected static final String MAX_PERIOD = "max-period";
	protected static final String THREAD = "thread";
	protected static final String QUEUE = "queue";
	
	private static final int QUEUE_CAPACITY = 16;

	private static final Logger logger = LogManager.getLogger();
	
	protected Logger getLogger() {
		return ConversationalWebSocket.logger;
	}
	
	@SuppressWarnings("unchecked")
	protected Thread newPeriodicSenderThread(Session session) {
		return new RandPeriodEchoThread(
				(Integer)session.getUserProperties().get(MAX_PERIOD),
				session.getBasicRemote(),
				(BlockingQueue<String>)session.getUserProperties().get(QUEUE)
		);
	}
	
	@OnOpen
	public void OnOpen(Session session, EndpointConfig config, @PathParam("max-period") int maxPeriod) {
		getLogger().debug(logMsg("Open websocket with maxPeriod=" + maxPeriod, session));
		
		if(maxPeriod > 0) {
			Map<String,Object> properties = session.getUserProperties();
			properties.put(MAX_PERIOD, maxPeriod);
			
			properties.put(QUEUE, new ArrayBlockingQueue<String>(QUEUE_CAPACITY));
			
			Thread thread = newPeriodicSenderThread(session);
			thread.start();
			properties.put(THREAD, thread);
		}
		else
			getLogger().warn(logMsg("maxPeriod is not positive", session));
	}
	
	@OnClose
	public void OnClose(Session session, CloseReason reason) {
		getLogger().debug(logMsg("Close: " + reason.getReasonPhrase() + " (" + reason.getCloseCode() + ")", session));
		terminateThread(session);
	}
	
	@OnError
	public void OnError(Session session, Throwable err) {
		getLogger().error(logMsg("Error: " + err.getMessage(), session));
		terminateThread(session);
	}
	
	@OnMessage
	public void OnMessage(Session session, String msg) {
		getLogger().info(logMsg("Message received: " + msg, session));
		
		@SuppressWarnings("unchecked")
		BlockingQueue<String> queue = (BlockingQueue<String>)session.getUserProperties().get(QUEUE);
		if(queue != null) {
			boolean queued = queue.offer(msg); // false if queue is full
			getLogger().debug(logMsg("Queuing message result=" + queued, session));
		}
	}

	private String logMsg(String msg, Session session) {
		return "(" + session.getId() + ") " + msg;
	}
	
	private void terminateThread(Session session) {
		Thread thread = (Thread)session.getUserProperties().get(THREAD);
		if(thread != null && thread.isAlive()) {
			getLogger().debug(logMsg("Interrupting thread=" + thread.getName(), session));
			thread.interrupt();
		}
	}

}
