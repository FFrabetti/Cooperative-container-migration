package it.unibo.ff185.trafficgencl;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URI;

import javax.websocket.ContainerProvider;
import javax.websocket.Session;
import javax.websocket.WebSocketContainer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class WebSocketClient {

	private static final Logger logger = LogManager.getLogger();
	
	public static void run(String[] args) {
		String url = args[1];
		logger.debug("Starting client with URL=" + url);

		Class<?> annotatedClass = WebSocketClientEndpoint.class;
		if("streaming".equals(args[0]))
			annotatedClass = StreamClientEndpoint.class;
		else if("background".equals(args[0]))
			annotatedClass = BinaryClientEndpoint.class;
		
		WebSocketContainer container = ContainerProvider.getWebSocketContainer();
		try {
			Session session = container.connectToServer(annotatedClass, new URI(url));
			
			try(BufferedReader br = new BufferedReader(new InputStreamReader(System.in))) {
				String line = null;
				while((line=br.readLine()) != null) {
					logger.info("Sending message: " + line);
					session.getBasicRemote().sendText(line); // sync
					logger.info("Message sent");
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		}
	}

}
