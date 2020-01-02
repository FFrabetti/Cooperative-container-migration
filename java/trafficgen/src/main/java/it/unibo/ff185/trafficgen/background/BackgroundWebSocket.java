package it.unibo.ff185.trafficgen.background;

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

import it.unibo.ff185.trafficgen.utils.ConversationalEndpoint;

@ServerEndpoint("/background/{max-period}")
public class BackgroundWebSocket extends ConversationalEndpoint {

	private static final Logger logger = LogManager.getLogger();

	@Override
	protected Logger getLogger() {
		return BackgroundWebSocket.logger;
	}

	@SuppressWarnings("unchecked")
	@Override
	protected Thread newSenderThread(Session session) {
		return new RandPeriodPartialSendThread(
				(Integer)session.getUserProperties().get(MAX_PERIOD),
				session.getBasicRemote(),
				(BlockingQueue<String>)session.getUserProperties().get(QUEUE)
		);
	}
	
	@OnOpen
	public void OnOpen(Session session, EndpointConfig config, @PathParam("max-period") int maxPeriod) {
		super.OnOpen(session, config, maxPeriod);
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
	}

}
