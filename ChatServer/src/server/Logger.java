package server;

public class Logger {
	public static void warn(String msg){
		log("warn : "+msg);
	}
	
	public static void info(String msg){
		log("info : "+msg);
	}
	
	public static void fatal(String msg){
		log("fatal : "+msg);
	}
	
	public static void log(String msg){
		System.out.println();
		System.out.println("LOG : "+msg);
	}
}
