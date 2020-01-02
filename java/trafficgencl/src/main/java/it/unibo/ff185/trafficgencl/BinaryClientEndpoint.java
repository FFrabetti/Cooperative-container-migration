package it.unibo.ff185.trafficgencl;

import javax.websocket.ClientEndpoint;
import javax.websocket.OnMessage;
import javax.websocket.Session;

@ClientEndpoint
public class BinaryClientEndpoint extends WebSocketClientEndpoint {

	@OnMessage
	public void OnMessage(Session session, byte[] byteArray, boolean isLast) {
		logger.info(logMsg("Partial message received" +
				(isLast ? " (last): " : ": ") + byteArray.length + " bytes", session));
	}
	
}
