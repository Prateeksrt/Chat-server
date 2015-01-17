package server;

import java.io.DataInputStream;
import java.io.EOFException;
import java.io.IOException;
import java.net.Socket;

public class JServerThread extends Thread {
	
	private JServer server;
	
	private Socket socket;
	
	private String add;

	public JServerThread(JServer server, Socket socket) {
		this.server=server;
		this.socket=socket;
		this.add=socket.getInetAddress().toString();
		
		start();
	}
	
	@Override
	public void run() {
		try {
			DataInputStream in=new DataInputStream(socket.getInputStream());
			
			while(true){
				String msg=in.readUTF();
				
				Logger.info("Reading from "+add);
				
				server.sendAll(msg);
			}
		}catch(EOFException e){
			Logger.warn("Disconnecting from "+add);
		}		
		catch (IOException e) {
			Logger.warn("Connection lost "+add);
		}finally{
			server.remove(socket);
		}
	}

}
