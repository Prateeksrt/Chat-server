package server;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map;

public class JServer {
	
	private Map<Socket, DataOutputStream> outStreams;
	
	public JServer(int port){
		
		Logger.info("Server started! Listening to port : "+port);
		outStreams=new HashMap<Socket, DataOutputStream>();
		
		listen(port);
	}
	
	private void listen(int port){
		ServerSocket serverSocket=null;
		try {
			serverSocket=new ServerSocket(port);
			while(true){
				
				Socket socket=serverSocket.accept();
				
				Logger.info("Excepted a connection from "+socket.getInetAddress().toString());
				
				try {
					outStreams.put(socket, new DataOutputStream(socket.getOutputStream()));
				} catch (IOException e) {
					Logger.warn("Out put Stream could not be stored for "+socket.getInetAddress().toString());
					e.printStackTrace();
				}
				
				new JServerThread(this, socket);				
			}
		} catch (IOException e) {
			Logger.fatal("Server could not be started !... Try again.");
		}finally {
			Logger.info("Shutting the server down...");
			if(serverSocket!=null){
				try {
					serverSocket.close();
				} catch (IOException e) {
					Logger.fatal("Some Internal error occured while closing the server...");
				}
			}
		}
	}
	
	public void sendAll(String msg){
		for(DataOutputStream out:outStreams.values()){
			try {
				out.writeUTF(msg);
			} catch (IOException e) {
				Logger.warn("Some Internal Error occurred occur at while "
						+ "writing to clients");
			}
		}
	}
	
	public void remove(Socket socket){
		synchronized (outStreams) {
			outStreams.remove(socket);
			
			try {
				socket.close();
			} catch (IOException e) {
				Logger.warn("Some Internal Error Occured while closing the socket : "
						+ socket.getInetAddress().toString());
			}
		}
	}
	
	public static void main(String[] args) {
		JServer server=new JServer(4000);
	}
}