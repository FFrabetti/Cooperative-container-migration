package it.unibo.ff185.trafficgen.background;

import java.util.concurrent.BlockingQueue;

import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import it.unibo.ff185.trafficgen.conversational.ConversationalWebSocket;

@ServerEndpoint("/background/{max-period}")
public class BackgroundWebSocket extends ConversationalWebSocket {

	private static final Logger logger = LogManager.getLogger();

	@Override
	protected Logger getLogger() {
		return BackgroundWebSocket.logger;
	}

	@SuppressWarnings("unchecked")
	@Override
	protected Thread newPeriodicSenderThread(Session session) {
		return new RandPeriodPartialSendThread(
				(Integer)session.getUserProperties().get(MAX_PERIOD),
				session.getBasicRemote(),
				(BlockingQueue<String>)session.getUserProperties().get(QUEUE)
		);
	}
	
}
