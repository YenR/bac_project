package jasonisp.network;

import jasonisp.util.AiNetworkConnection;
import java.io.IOException;
import java.net.*;
import java.util.NoSuchElementException;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Listens for data on a given UDP port and adds the raw messages to a queue
 * Make sure you have something constantly consuming from the queue, otherwise
 * it will start to fill up!
 *
 * @author som
 *
 */
public class UDPListenerThread extends Thread
{    
    private static final Logger LOGGER = Logger.getLogger(UDPListenerThread.class.getName());

    final int MAX_DATA_SIZE = 4096; // Not sure what this should actually be, just a magic number right now

    int listenPort;
    DatagramSocket socket;

    Queue<byte[]> receivedDataQueue = new ConcurrentLinkedQueue<>();

    public UDPListenerThread(int listenPort) throws SocketException {
        this.setName("UDPListenerThread @ "+listenPort);
        this.listenPort = listenPort;
        this.socket = new DatagramSocket(listenPort);
        this.socket.setSoTimeout(100);
    }

    @Override
    public void run() {
        LOGGER.log(Level.INFO, "Starting UDPListenerThread thread ...");
        while (!isInterrupted())
        {            
            try {
                byte[] receiveData = new byte[MAX_DATA_SIZE];
                DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
                this.socket.receive(receivePacket);
                //System.out.println("GOT SOMETHING: " + receiveData);
                this.receivedDataQueue.add(receivePacket.getData());
            } catch (SocketTimeoutException ex) {
                continue;                
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        
        //LOGGER.log(Level.INFO, "Stopping UDPListenerThread thread ...");
        socket.close();
        LOGGER.log(Level.INFO, "Stopping UDPListenerThread thread ... done");
    }

    /**
     * Returns null if there is no more data in the queue *
     */
    public byte[] GetDataFromQueue() {
        try {
            byte[] data = this.receivedDataQueue.remove();

            return data;
        } catch (NoSuchElementException e) {
            return null;
        }
    }
}
