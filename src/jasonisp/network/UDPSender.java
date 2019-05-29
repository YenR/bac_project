package jasonisp.network;

import java.io.IOException;
import java.net.*;

/**
 * UDP is really simple, but it's still nice to have a wrapper like this to keep track
 * of ports and handle exceptions
 * @author som
 *
 */
public class UDPSender 
{
	DatagramSocket socket;
	String address;
	int remotePort;
	
	public UDPSender(String address, int remotePort) throws SocketException
	{
		this.socket = new DatagramSocket();
		this.address = address;
		this.remotePort = remotePort;
	}
	
	public void SetRemotePort(int port) {
		this.remotePort = port;
	}
	
	public boolean Send(byte[] data)
	{
		boolean ok = false;
		
		try {
			InetAddress ipAddress = InetAddress.getByName(this.address);
			DatagramPacket packet = new DatagramPacket(data, data.length, ipAddress, this.remotePort);
			this.socket.send(packet);
			ok = true;
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return ok;
	}
	
}
