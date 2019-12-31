package it.unibo.ff185.trafficgencl.conversational;

import javax.websocket.ClientEndpoint;
import javax.websocket.CloseReason;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@ClientEndpoint
public class WebSocketClientEndpoint {
	
	private static final Logger logger = LogManager.getLogger();
	
	private String logMsg(String msg, Session session) {
		return "(" + session.getId() + ") " + msg;
	}
	
	@OnOpen
	public void OnOpen(Session session, EndpointConfig config) {
		logger.debug(logMsg("Open websocket", session));
	}
	
	@OnClose
	public void OnClose(Session session, CloseReason reason) {
		logger.debug(logMsg("Close: " + reason.getReasonPhrase() + " (" + reason.getCloseCode() + ")", session));
	}
	
	@OnError
	public void OnError(Session session, Throwable err) {
		logger.error(logMsg("Error: " + err.getMessage(), session));
	}
	
	@OnMessage
	public void OnMessage(Session session, String msg) {
		logger.info(logMsg("Message received: " + msg, session));
	}
	
}
