/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package jasonisp.util;

import jasonisp.network.BSONListener;
import jasonisp.network.UDPListenerThread;
import jasonisp.network.UDPSender;
import java.net.SocketException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.bson.BasicBSONEncoder;
import org.bson.BasicBSONObject;
import org.bson.BsonDocument;

/**
 *
 * @author default
 */
public class AiNetworkConnection// extends Thread
{       
    private static final Logger LOGGER = Logger.getLogger(AiNetworkConnection.class.getName());
    
    private final int m_listenPort;
    
    private final String m_remoteAdress;
    private final int m_remotePort;
    
    private UDPListenerThread m_udpListener;
    private BSONListener m_bsonListener;
    
    private UDPSender m_updSender;    
    //private BasicBSONEncoder m_bsonEncoder;
    
    //private final ConcurrentLinkedQueue<BasicBSONObject> m_sendQueue;
    
    public AiNetworkConnection(int _listenPort, String _remoteAddress, int _remotePort)
    {
        //setName("AiNetworkConnection");
        
        m_listenPort = _listenPort;
        
        m_remoteAdress = _remoteAddress;
        m_remotePort = _remotePort;

        //m_bsonEncoder = new BasicBSONEncoder();

        //m_sendQueue = new ConcurrentLinkedQueue<>();
    }
    
    public void start()
    {
        try {
            m_udpListener = new UDPListenerThread(m_listenPort);
            m_updSender = new UDPSender(m_remoteAdress, m_remotePort);
        } catch (SocketException ex) {
            LOGGER.log(Level.SEVERE, null, ex);
        }
                
        m_bsonListener = new BSONListener(m_udpListener);
        
        m_udpListener.start();
    }
    
    public void stop()
    {
        m_udpListener.interrupt();
        
        try
        {
            m_udpListener.join();
        }
        catch (InterruptedException ex)
        {
            LOGGER.log(Level.SEVERE, null, ex);
        }
    }
    
    public void Send(BasicBSONObject _obj)
    {
        BasicBSONEncoder enc = new BasicBSONEncoder();
        m_updSender.Send(enc.encode(_obj));
        //m_updSender.Send(m_bsonEncoder.encode(_obj));
    }
    
    public BsonDocument ReciveNext()
    {
        return m_bsonListener.GetNextBsonObject();
    }
    
    /*@Override
    public void run()
    {        
        LOGGER.info("Satrted AiNetworkConnection thread ...");
        
        start();
        
        try
        {
            while (!this.isInterrupted())
            {
                // recive
                                
                while (true)
                {
                    BsonDocument obj = m_bsonListener.GetNextBsonObject();
                    if (obj != null)
                    {
                        LOGGER.log(Level.INFO, "Recieved BsonDocument: {0}", obj.toString());
                    }
                    else
                        break;
                }
               
                // send
                m_sendQueue.stream().forEach((obj) -> {
                    m_updSender.Send(m_bsonEncoder.encode(obj));
                });
            }
        }
        catch (Exception ex)
        {
            LOGGER.severe(ex.getMessage());
        }
                
        System.out.println("Stopping AiNetworkConnection thread ..."); 
        
        stop();
        
        System.out.println("Stopping AiNetworkConnection thread ... done");
    }*/
}
