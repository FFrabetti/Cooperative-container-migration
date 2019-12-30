package it.unibo.ff185.trafficgencl;

import it.unibo.ff185.trafficgencl.interactive.InteractiveClient;

public class App {
	
	public static void main(String[] args) {
		if(args.length != 2) {
			System.out.println("Required args: TYPE URL");
			System.out.println("TYPE := interactive | conversational | background | streaming");
			System.exit(1);
		}
		
		switch(args[0]) {
		case "interactive":
			InteractiveClient.run(args);
			break;
		case "conversational":
			
			break;
		case "background":
			
			break;
		case "streaming":
			
			break;
			
		default:
			System.out.println("Unknown type");
		}
	}
	
}
