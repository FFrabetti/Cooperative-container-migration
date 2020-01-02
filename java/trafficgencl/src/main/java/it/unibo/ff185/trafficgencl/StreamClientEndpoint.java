package it.unibo.ff185.trafficgencl;

import java.io.InputStream;

import javax.websocket.ClientEndpoint;
import javax.websocket.OnMessage;
import javax.websocket.Session;

@ClientEndpoint
public class StreamClientEndpoint extends WebSocketClientEndpoint {

	@OnMessage
	public void OnMessage(Session session, InputStream binaryStream) {
		logger.info(logMsg("Binary stream received", session));
		
		Thread thread = new ConsumeInputStreamThread(binaryStream, logger);
		thread.start();
	}
	
}
