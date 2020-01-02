package it.unibo.ff185.trafficgen.utils;

import javax.websocket.CloseReason;
import javax.websocket.EndpointConfig;
import javax.websocket.Session;

import org.apache.logging.log4j.Logger;

public abstract class WebSocketServerEndpoint {
	
	protected static final String THREAD = "thread";

	protected abstract Logger getLogger();
	
	protected abstract Thread newSenderThread(Session session);
	
	public void OnOpen(Session session, EndpointConfig config, boolean startThread) {
		getLogger().debug(logMsg("Open websocket", session));
		
		if(startThread) {
			Thread thread = newSenderThread(session);
			thread.start();
			session.getUserProperties().put(THREAD, thread);
		}
	}
	
	public void OnClose(Session session, CloseReason reason) {
		getLogger().debug(logMsg("Close: " + reason.getReasonPhrase() + " (" + reason.getCloseCode() + ")", session));
		terminateThread(session);
	}
	
	public void OnError(Session session, Throwable err) {
		getLogger().error(logMsg("Error: " + err.getMessage(), session));
		terminateThread(session);
	}
	
	public void OnMessage(Session session, String msg) {
		getLogger().info(logMsg("Message received: " + msg, session));
	}

	protected String logMsg(String msg, Session session) {
		return "(" + session.getId() + ") " + msg;
	}

	protected void terminateThread(Session session) {
		Thread thread = (Thread)session.getUserProperties().get(THREAD);
		if(thread != null && thread.isAlive()) {
			getLogger().debug(logMsg("Interrupting thread=" + thread.getName(), session));
			thread.interrupt();
		}
	}
	
}
