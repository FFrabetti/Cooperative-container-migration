package it.unibo.ff185.trafficgen.utils;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

import javax.websocket.EndpointConfig;
import javax.websocket.Session;

public abstract class ConversationalEndpoint extends WebSocketServerEndpoint {

	protected static final String MAX_PERIOD = "max-period";
	protected static final String QUEUE = "queue";
	
	private static final int QUEUE_CAPACITY = 16;
	
	public void OnOpen(Session session, EndpointConfig config, int maxPeriod) {		
		if(maxPeriod > 0) {
			session.getUserProperties().put(MAX_PERIOD, maxPeriod);			
			session.getUserProperties().put(QUEUE, new ArrayBlockingQueue<String>(QUEUE_CAPACITY));
		}
		else
			getLogger().warn(logMsg("maxPeriod is not positive", session));
		
		super.OnOpen(session, config, maxPeriod > 0);
	}
	
	@Override
	public void OnMessage(Session session, String msg) {
		super.OnMessage(session, msg);
		
		@SuppressWarnings("unchecked")
		BlockingQueue<String> queue = (BlockingQueue<String>)session.getUserProperties().get(QUEUE);
		if(queue != null) {
			boolean queued = queue.offer(msg); // false if queue is full
			getLogger().debug(logMsg("Queuing message result=" + queued, session));
		}
	}

}
