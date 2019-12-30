package it.unibo.ff185.trafficgen.utils;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Random;

public class RandWriter {

	private OutputStream outStream;
	private Random rand;
	
	public RandWriter(OutputStream outStream, Random rand) {
		this.outStream = outStream;
		this.rand = rand;
	}
	
	public RandWriter(OutputStream outStream) {
		this(outStream, new Random());
	}
	
	public void print(int len) throws IOException {
		for(int i=0; i<len; i++)
			outStream.write(rand.nextInt());
	}
	
}
