package it.unibo.ff185.trafficgencl.conversational;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URI;

import javax.websocket.ContainerProvider;
import javax.websocket.Session;
import javax.websocket.WebSocketContainer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class ConversationalClient {

	private static final Logger logger = LogManager.getLogger();
	
	public static void run(String[] args) {
		String url = args[1];
		logger.debug("Starting client with URL=" + url);

		WebSocketContainer container = ContainerProvider.getWebSocketContainer();
		try {
			Session session = container.connectToServer(WebSocketClientEndpoint.class, new URI(url));
			
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
