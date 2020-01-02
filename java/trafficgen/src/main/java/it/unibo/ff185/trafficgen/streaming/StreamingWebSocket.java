package it.unibo.ff185.trafficgen.streaming;

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

import it.unibo.ff185.trafficgen.utils.WebSocketServerEndpoint;

@ServerEndpoint("/streaming/{bytes-per-sec}")
public class StreamingWebSocket extends WebSocketServerEndpoint {

	private static final String BYTES_PER_SECOND = "Bps";
	
	private static final Logger logger = LogManager.getLogger();

	@Override
	protected Logger getLogger() {
		return StreamingWebSocket.logger;
	}

	@Override
	protected Thread newSenderThread(Session session) {
		return new RandStreamSendThread((int)session.getUserProperties().get(BYTES_PER_SECOND), session.getBasicRemote());
	}
	
	@OnOpen
	public void OnOpen(Session session, EndpointConfig config, @PathParam("bytes-per-sec") int Bps) {
		session.getUserProperties().put(BYTES_PER_SECOND, Bps);
		
		super.OnOpen(session, config, Bps > 0);
	}
	
	@OnClose
	@Override
	public void OnClose(Session session, CloseReason reason) {
		super.OnClose(session, reason);
	}
	
	@OnError
	@Override
	public void OnError(Session session, Throwable err) {
		super.OnError(session, err);
	}

	@OnMessage
	@Override
	public void OnMessage(Session session, String msg) {
		super.OnMessage(session, msg);
		terminateThread(session);
	}
	
}
