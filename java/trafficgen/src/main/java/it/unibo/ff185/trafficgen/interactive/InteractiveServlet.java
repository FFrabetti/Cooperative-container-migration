package it.unibo.ff185.trafficgen.interactive;

import java.io.IOException;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import it.unibo.ff185.trafficgen.utils.RandWriter;

@WebServlet("/interactive")
public class InteractiveServlet extends HttpServlet {

	private static final String RES_SIZE = "res-size";
	private static final String MIN_PR_TIME = "min-pr-time";

	private static final long serialVersionUID = 1L;

	/*
	 * debug:	check execution
	 * info:	timestamp relevant steps
	 * warn:	record "light" anomalies
	 */
	protected static final Logger logger = LogManager.getLogger();
	
	protected String logMsg(String msg, HttpServletRequest req) {
		return "(" + req.getSession().getId() + ") " + msg;
	}

	@Override
	public void init(ServletConfig config) throws ServletException {
		super.init(config);
		
		logger.debug("Servlet init: " + config.getServletName());
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// log: request received
		logger.info(logMsg("Request received", req));
		logger.debug(logMsg("Request parameters:"
				+ " MIN_PR_TIME=" + req.getParameter(MIN_PR_TIME) + ","
				+ " RES_SIZE=" + req.getParameter(RES_SIZE)
		, req));
		
		// processing / generate response
		int len = processRequest(req, resp);
		
		// log: response sent
		logger.info(logMsg("Sending response: " + len + " bytes", req));
	}

	int processRequest(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		String minPrTime = req.getParameter(MIN_PR_TIME);
		if(minPrTime != null) {
			int prTime = Integer.parseInt(minPrTime);
			try {
				logger.debug(logMsg("Sleeping for " + prTime + " millis...", req));
				Thread.sleep(prTime);
			} catch (InterruptedException e) {
				logger.warn(logMsg("Sleep interrupted: " + e.getMessage(), req));
				e.printStackTrace();
			}
		}
		
		String resSize = req.getParameter(RES_SIZE);
		int len = resSize != null ? Integer.parseInt(resSize) : 0;
		if(len > 0) {
			RandWriter rWriter = new RandWriter(resp.getOutputStream());
			rWriter.print(len);
		}
		
		return len;
	}
	
}
