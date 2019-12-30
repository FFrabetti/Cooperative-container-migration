package it.unibo.ff185.trafficgen.interactive;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import it.unibo.ff185.trafficgen.utils.RandWriter;

@WebServlet("/sinteractive")
public class StatefulServlet extends InteractiveServlet {

	private static final String SES_SIZE = "ses-size";
	private static final String DISK_SIZE = "disk-size";
	private static final String DATA_ATTR = "data";
	private static final String WORK_DIR = "WorkDir";

	private static final long serialVersionUID = 1L;

	@Override
	int processRequest(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		logger.debug(logMsg("Request additional parameters:"
				+ " SES_SIZE=" + req.getParameter(SES_SIZE) + ","
				+ " DISK_SIZE=" + req.getParameter(DISK_SIZE)
		, req));
		
		// read/write session data
		Double[] data = (Double[])req.getSession().getAttribute(DATA_ATTR);
		if(data != null) {
			logger.debug(logMsg("Session data found: " + (data.length * Double.BYTES), req));
		}
		
		String sessionSize = req.getParameter(SES_SIZE);
		if(sessionSize != null) {
			int sesSize = Integer.parseInt(sessionSize);
			req.getSession().setAttribute(DATA_ATTR, new Double[sesSize]);
			
			logger.debug(logMsg("Session data saved: " + (sesSize * Double.BYTES), req));
		}
			
		// read/write from disk
		String diskSize = req.getParameter(DISK_SIZE);
		String workDir = getServletContext().getInitParameter(WORK_DIR);
		logger.debug(logMsg("Using WorkDir=" + workDir, req));
		
		if(diskSize != null && workDir != null) {
			File dir = new File(workDir);
			if(!dir.isDirectory() && dir.mkdir())
				logger.debug("Created directory " + workDir);
			
			String fileName = workDir + File.separator + (System.currentTimeMillis() % 64);
			try(FileOutputStream fos = new FileOutputStream(new File(fileName))) {
				RandWriter rWriter = new RandWriter(fos);
				rWriter.print(Integer.parseInt(diskSize));
				logger.debug(logMsg("Written " + diskSize + " bytes to " + fileName, req));
			} catch(IOException e) {
				logger.error(logMsg("IOException when writing to disk: " + e.getMessage(), req));
			}
		}
		
		// sleep and write response payload
		return super.processRequest(req, resp);
	}

}
