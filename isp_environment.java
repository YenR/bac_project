// Environment code for project isp_ai_v01.mas2j



import com.sun.javafx.scene.layout.region.BackgroundSizeConverter;
import jason.asSyntax.*;
import jason.environment.*;

import java.lang.Exception;
import java.lang.Thread;
import java.util.logging.*;

import jason.asSemantics.ActionExec;
import jason.asSyntax.Literal;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.bson.BasicBSONObject;
import org.bson.BsonDocument;
import jasonisp.util.AiNetworkConnection;


public class isp_environment extends Environment {

    public static final int LISTEN_PORT = 9898;
    public static final String REMOTE_ADDRESS = "localhost";
    public static final int REMOTE_PORT = 9899;
	
    protected static final String NUMFORMAT = "%.4f";
	
    protected Logger logger = Logger.getLogger("isp_ai_v01.mas2j."+isp_environment.class.getName());

	protected AiNetworkConnection m_connection;
   // protected ConcurrentHashMap<String, ConcurrentLinkedQueue<Literal>> m_actorPerceptionsMap;
    

    /** Called before the MAS execution with the args informed in .mas2j */

	private class networkThread extends Thread
	{
		public isp_environment father;
		
		public networkThread(isp_environment _father)
		{
			super();
			this.father = _father;
		}
				
		@Override
		public void run()
		{
			logger.info("Started network Thread");	
			while (true)
			{
				try
				{
					Thread.sleep(10);
				}
				catch(Exception e)
				{
					father.logger.info(e.toString());	
				}
				
				BsonDocument doc = father.m_connection.ReciveNext();
				
				if (doc != null)
				{
					//father.logger.info("Received: "+ doc.toString());
					father.process(doc);
				}
				else
				{
					//double chance = Math.random();
					//if(chance < 0.05)
	
					//break;
				}
			}        
		}
	}
	
    @Override
    public void init(String[] args) {
        super.init(args);
		
		try {
			//addPercept(ASSyntax.parseLiteral("percept(demo)"));

			//addPercept("isp_agent1", ASSyntax.parseLiteral("my_actor(actor0)"));
			//addPercept("isp_agent2", ASSyntax.parseLiteral("my_actor(actor1)"));
			//addPercept("isp_agent3", ASSyntax.parseLiteral("my_actor(actor2)"));

            // TODO: CODE only so program starts, should get overwritten as soon as udp data is received
            addPercept(ASSyntax.parseLiteral("agentposition(agent0, 0,0,0)"));
            //addPercept(ASSyntax.parseLiteral("agentposition(agent1, 0,0,0)"));
            addPercept(ASSyntax.parseLiteral("actorposition(actor0, 0,0,0)"));
            //addPercept(ASSyntax.parseLiteral("actorposition(actor1, 0,0,0)"));
            //addPercept(ASSyntax.parseLiteral("actororientation(actor0, 1,0,0)"));
            //addPercept(ASSyntax.parseLiteral("actororientation(actor1, 1,0,0)"));
            addPercept(ASSyntax.parseLiteral("actordistancetoscreen(actor0, 100)"));
            //addPercept(ASSyntax.parseLiteral("actordistancetoscreen(actor1, 100)"));

            addPercept(ASSyntax.parseLiteral("actorscaling(actor0, 0)"));
            addPercept(ASSyntax.parseLiteral("agentstate(agent0, idle)"));

        } catch(Exception e){
			logger.info(e.toString());
		}
		
        m_connection = new AiNetworkConnection(LISTEN_PORT, REMOTE_ADDRESS, REMOTE_PORT);
        m_connection.start();
		
		logger.info("initiated environment");
		
		networkThread myThread = new networkThread(this);
		myThread.start();
    }

	void process(BsonDocument _doc)
    {
        String type = _doc.getString("type", null).getValue();

        BsonDocument data = null;

        if(! (type.equals("end") || type.equals("start")))
            data = _doc.getDocument("data", null);
                       
        if (type != null)
        {          
            //logger.info("process(BsonDocument _doc)");
            Literal l = null;
            String agentName = null;
            
            switch (type)
            {
                case "startintrodonning":
                {
                    addPercept(Literal.parseLiteral("startintrodonning"));
                    break;
                }
                case "end":
                {
                    addPercept("supervisor1", Literal.parseLiteral("end"));
                    break;
                }
                case "start":
                {
                    addPercept("supervisor1", Literal.parseLiteral("start"));
                    break;
                }
                case "camerainfo":
                {
                    double cx = data.getDouble("camera_x").getValue();
                    double cz = data.getDouble("camera_z").getValue();

                    addPercept(Literal.parseLiteral("camerapos(" + cx + "," + cz + ")"));

                    double cfx = data.getDouble("camera_forward_x").getValue();
                    double cfy = data.getDouble("camera_forward_y").getValue();
                    double cfz = data.getDouble("camera_forward_z").getValue();
                    double sw = data.getDouble("screenwidth").getValue();

                    // TODO: assumption that camera is orientated parallel to z-axis (towards +z)
                    if(!(cfx == 0f && cfy == 0f && cfz == 1f))
                        System.out.println("Warning: camera orientation not parallel to z axis");
                    else
                        System.out.println("Camera orientation OK!");

                    double leftBorder = cx - sw/2;
                    double rightBorder = cx + sw/2;

                    addPercept(Literal.parseLiteral("cameraborder(" + leftBorder + "," + rightBorder + ")"));

                    break;
                }
                case "objectposition":
                {
                    String n = data.getString("name").getValue();

                    double x = data.getDouble("pos_x").getValue();
                    double y = data.getDouble("pos_y").getValue();

                    double dx = data.getDouble("dir_x").getValue();
                    double dy = data.getDouble("dir_y").getValue();

                    addPercept(Literal.parseLiteral("objectposition(" + n + "," + x + "," + y + "," + dx + "," + dy + ")"));
                    break;
                }
                case "scenario":
                {
                    String scenarioName = data.getString("name").getValue();
                    removePerceptsByUnif("supervisor1", Literal.parseLiteral("scenario(_)"));
                    addPercept("supervisor1", Literal.parseLiteral("scenario(" + scenarioName + ")"));
                    break;
                }
                case "actorstate":
                {
                    String literalString = null;
                    String actorName = data.getString("actorname").getValue();
                    String stateName = data.getString("statename").getValue();
                    boolean active = data.getBoolean("active").getValue();
                             
                    //agentName = "agent"+actorName.charAt(actorName.length()-1);
                                                                
					literalString = type+"("+actorName+", "+ stateName + ")";
										
					if(active)
					{
						//logger.info("sending perception: " + literalString);
						if(literalString != null)
							l = Literal.parseLiteral(literalString);
                    
						if (l != null)
						{
                            addPercept(l);
						}
					}
					else
					{
						//logger.info("removing perception: " + literalString);
                    
						if(literalString != null)
							l = Literal.parseLiteral(literalString);
                    
						if (l != null)
						{
							removePercept(l);
						}
					}
					
					
                    //if(active)
                    //    literalString = type+"("+actorName+", "+ stateName + ")";
                    
                    //if(literalString != null)
                     //   l = Literal.parseLiteral(literalString);
                    break;
                }

                case "actorscaling":
                {
                    String literalString = null;
                    String actorName = data.getString("actorname").getValue();
                    double scalingValue = data.getDouble("scalingvalue").getValue();

                    literalString = type+"("+actorName+", "+ scalingValue + ")";
                    if(literalString != null)
                    {
                        removePerceptsByUnif(Literal.parseLiteral(type+"("+actorName+",_)"));
                        addPercept(Literal.parseLiteral(literalString));
                    }
                    break;
                }

                case "actordistancetoscreen":
                {
                    String literalString = null;
                    String actorName = data.getString("actorname").getValue();
                    double distance = data.getDouble("distance").getValue();

                    literalString = type+"("+actorName+", "+ (int)(distance*100) + ")";
                    if(literalString != null)
                    {
                        removePerceptsByUnif(Literal.parseLiteral(type+"("+actorName+",_)"));
                        addPercept(Literal.parseLiteral(literalString));
                    }
                    break;
                }

                case "actorposition":
                {
                    String literalString = null;
                    String actorName = data.getString("actorname").getValue();
                    String x = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("x").getValue());
                    String y = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("y").getValue());
                    String z = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("z").getValue());

                    String forward_x = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("forward_x").getValue());
                    String forward_y = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("forward_y").getValue());
                    String forward_z = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("forward_z").getValue());

                    //agentName = "agent"+actorName.charAt(actorName.length()-1);
                    
                    literalString = type+"("+actorName+", " +x+ ", " +y+ ", " +z+ ")";
                    String literalString2 = "actororientation"+"("+actorName+", " +forward_x+ ", " +forward_y+ ", " +forward_z+ ")";
                    //LOGGER.info("literalString: " + literalString);

                    Literal l2 = null;

                    if(literalString != null && literalString2 != null)
                    {
                        l = Literal.parseLiteral(literalString);
                        l2 = Literal.parseLiteral(literalString2);
                    }

					if (l != null && l2 != null)// && agentName != null)
					{
					    //logger.info("adding perceptions: " + l + ", " + l2);

                        removePerceptsByUnif(Literal.parseLiteral(type+"("+actorName+",_,_,_)"));
						addPercept(l);

                        removePerceptsByUnif(Literal.parseLiteral("actororientation("+actorName+",_,_,_)"));
                        addPercept(l2);
					}
					break;
                }
                
                case "agentstate":
                {
                    String literalString = null;
                    agentName = data.getString("agentname").getValue();
                    String stateName = data.getString("statename").getValue();
                    boolean active = data.getBoolean("active").getValue();

                    literalString = type+"("+agentName+", "+ stateName + ")";

                    if(active)
                    {
                        //logger.info("sending perception: " + literalString);
                        if(literalString != null)
                            l = Literal.parseLiteral(literalString);

                        if (l != null)
                        {
                            removePerceptsByUnif(Literal.parseLiteral("agentstate("+agentName+",_)"));
                            addPercept(l);
                        }
                    }
                    else
                    {
                        ///logger.info("removing perception: " + literalString);

                        if(literalString != null)
                            l = Literal.parseLiteral(literalString);

                        if (l != null)
                        {
                            removePercept(l);
                        }
                    }
					break;
                }

                case "bodymotion":
                {
                    String literalString = null;
                    agentName = data.getString("agentname").getValue();
                    Double velocity = data.getDouble("velocity").getValue();

                    literalString = type+"("+agentName+", "+ velocity + ")";

                    if(literalString != null)
                        l = Literal.parseLiteral(literalString);

                    if (l != null)
                    {
                        removePerceptsByUnif(Literal.parseLiteral(type + "("+agentName+",_)"));
                        addPercept(l);
                    }
                    break;
                }

                case "agentposition":
                {
                    String literalString = null;
                    agentName = data.getString("agentname").getValue();
                    String x = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("x").getValue());
                    String y = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("y").getValue());
                    String z = String.format(Locale.ROOT,NUMFORMAT,data.getDouble("z").getValue());
                    
                    //LOGGER.info("bsonToLiteral - state: "+ stateName +" to literal ...");
                    literalString = type+"("+agentName+", " +x+ ", " +y+ ", " +z+ ")";
                    
                    if(literalString != null)
                        l = Literal.parseLiteral(literalString);
					
					if (l != null && agentName != null)
					{
                        //logger.info("adding perception: " + l);

                        removePerceptsByUnif(Literal.parseLiteral(type+"("+agentName+",_,_,_)"));
						addPercept(l);
					}
                    break;
                }
                
                default:
            }
        }
    }

    @Override
    public boolean executeAction(String agName, Structure action) {

        if(!action.getFunctor().equals("scenario"))
            logger.info("executing: "+ agName + "." + action+ " !");

        if (action.getFunctor().equals("waveTo"))
        {
            //logger.info("Adding perception: wave(" + agName + ", " + action.getTerm(0)+ ")");

            String agnr = "agent" + (Character.getNumericValue(agName.charAt(agName.length() - 1)) - 1);

            addPercept(Literal.parseLiteral("wave(" + agnr + ", " + action.getTerm(0) + ")"));
            informAgsEnvironmentChanged();

            BasicBSONObject obj;
            obj = new BasicBSONObject();
            obj.append("type", "agentaction");
            BasicBSONObject data = new BasicBSONObject();
            data.append("agentname", agName);
            data.append("actionterm", "playanimation(wave," + action.getTerm(1) +")");
            obj.append("data", data);

            //logger.info("sending bson: " + obj.toString());

            m_connection.Send(obj);

            try {
                Thread.sleep(1000);
            }
            catch(Exception e){}

            //logger.info("Removing perception: wave(" + agName + ", " + action.getTerm(0) + ")");

            removePercept(Literal.parseLiteral("wave(" + agnr + ", " + action.getTerm(0) + ")"));
        }
        else if(action.getFunctor().equals("scenario")) {
            BasicBSONObject obj;

            obj = new BasicBSONObject();
            obj.append("type", "scenario");

            BasicBSONObject data = new BasicBSONObject();
            data.append("agentname", agName);
            data.append("scenario", action.getTerm(0).toString());

            obj.append("data", data);

            //logger.info("sending bson: " + obj.toString());
            m_connection.Send(obj);
        }
        else if (action.getFunctor().equals("ready"))
        {
            BasicBSONObject obj;

            obj = new BasicBSONObject();
            obj.append("type", "ready");

            BasicBSONObject data = new BasicBSONObject();
            obj.append("data", data);

            m_connection.Send(obj);
        }
        else
        {
            BasicBSONObject obj;

            // convert action to bson
            obj = new BasicBSONObject();
            obj.append("type", "agentaction");

            BasicBSONObject data = new BasicBSONObject();
            data.append("agentname", agName);
            data.append("actionterm", action.toString());

            obj.append("data", data);

            //logger.info("sending bson: " + obj.toString());
            m_connection.Send(obj);

        }
        informAgsEnvironmentChanged();

        return true; // the action was executed with success 

    }



    /** Called before the end of MAS execution */

    @Override

    public void stop() {

        super.stop();

    }

}


