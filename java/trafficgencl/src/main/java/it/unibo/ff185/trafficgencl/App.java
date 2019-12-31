package it.unibo.ff185.trafficgencl;

public class App {
	
	public static void main(String[] args) {
		if(args.length != 2) {
			System.out.println("Required args: TYPE URL");
			System.out.println("TYPE := interactive | conversational | background | streaming");
			System.exit(1);
		}
		
		switch(args[0]) {
		case "interactive":
			HTTPServletClient.run(args);
			break;
		case "conversational":
			// fall down
		case "background":
			// fall down
		case "streaming":
			WebSocketClient.run(args);
			break;
		default:
			System.out.println("Unknown type");
		}
	}
	
}
