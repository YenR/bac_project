package jasonisp.network;

import org.bson.*;

public class BSONListener 
{
	UDPListenerThread udpListener;
	
	
	public BSONListener(UDPListenerThread listener) 
	{
		this.udpListener = listener;
	}
	
	/**
	 * All the BSON types are a bit confusing, but we want to use BsonDocument
	 * as it has type-safe get and set functions
	 * @return
	 */
	public BsonDocument GetNextBsonObject()
	{
		byte[] data = this.udpListener.GetDataFromQueue();
		
		BsonDocument doc = null;
		
		if (data != null) 
		{
			try {
				doc = new RawBsonDocument(data);
				
			} catch (BsonSerializationException e) {
				System.err.println(e.toString());
			}
		}
		return doc;
	}

}
