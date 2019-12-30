package it.unibo.ff185.trafficgencl.interactive;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URISyntaxException;
import java.util.StringTokenizer;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class InteractiveClient {
	
	private static final Logger logger = LogManager.getLogger();

	private static final String RES_SIZE = "res-size";
	private static final String MIN_PR_TIME = "min-pr-time";
	private static final String SES_SIZE = "ses-size";
	private static final String DISK_SIZE = "disk-size";
	
	public static void run(String[] args) {
		String url = args[1];
		logger.debug("Starting HTTP client with URL=" + url);
		
		try(CloseableHttpClient client = HttpClientBuilder.create().build()) {
			try(BufferedReader br = new BufferedReader(new InputStreamReader(System.in))) {
				String line = null;
				while((line=br.readLine()) != null) {
					// MIN_PR_TIME RES_SIZE [SES_SIZE] [DISK_SIZE]
					StringTokenizer st = new StringTokenizer(line);
					URIBuilder builder = new URIBuilder(url);
					if(st.hasMoreTokens())
						builder.addParameter(MIN_PR_TIME, st.nextToken());
					if(st.hasMoreTokens())
						builder.addParameter(RES_SIZE, st.nextToken());
					if(st.hasMoreTokens())
						builder.addParameter(SES_SIZE, st.nextToken());
					if(st.hasMoreTokens())
						builder.addParameter(DISK_SIZE, st.nextToken());
					
					HttpGet request = new HttpGet(builder.build());
					logger.info("Sending request: " + builder.getQueryParams());
					try(CloseableHttpResponse response = client.execute(request)) {
						logger.info("Response received: " + response.getEntity().getContentLength() + " bytes");
						logger.debug("Response status line: " + response.getStatusLine());
					}
				} // while-end
				
			} catch (URISyntaxException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
