package
{
	import com.electrotank.electroserver4.message.request.PluginRequest;
    import com.electrotank.electroserver4.message.event.PluginMessageEvent;
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.message.MessageType;
	import com.electrotank.electroserver4.esobject.EsObject;
	import com.electrotank.electroserver4.room.Room;
	import org.flixel.FlxGroup;

	
	import org.flixel.FlxG;

	public class Talker
	{
  	    public static var TAG_PLAYERNAME:String 		   					 = "playername";
  	    public static var TAG_MESSAGETYPE:String 		   					 = "messagetype";
		public static var TAG_PLAYERS:String                                 = "players";
		
		public static var TAG_CONFIRMSETUP:String                            = "confirmsetup";
		
		public static var TAG_POSITIONSX:String                              = "positionsx";
		public static var TAG_POSITIONSY:String                              = "positionsy";
		public static var TAG_VELOCITIESX:String                             = "velocitiesx";
		public static var TAG_VELOCITIESY:String                             = "velocitiesy";
		public static var TAG_SCORES:String                                  = "scores";
		public static var TAG_ALLDEAD:String                                 = "alldead";
		
		public static var TAG_POSX:String                                    = "posx";
		public static var TAG_POSY:String                                    = "posy";
		public static var TAG_VELOCITYX:String                               = "velocityx";
		public static var TAG_VELOCITYY:String                               = "velocityy";
		public static var TAG_SCORE:String                                   = "score";
		public static var TAG_DEAD:String                                    = "dead"
		
		public static var TAG_BULLETSX:String                                = "bulletsx";
		public static var TAG_BULLETSY:String                                = "bulletsy";
		public static var TAG_BULLETSXVEL:String                             = "bulletsxvel";
		public static var TAG_BULLETSYVEL:String                             = "bulletsyvel";
		
		public static var TAG_ZOMBIESX:String                                = "zombiesx";
		public static var TAG_ZOMBIESY:String                                = "zombiesy";
		public static var TAG_ZOMBVELSX:String                               = "zombvelsx";
		public static var TAG_ZOMBVELSY:String                               = "zombvelsy";
		public static var TAG_ZOMBIESHEALTH:String                           = "zombieshealth";
		public static var TAG_ZOMBIESCANSEE:String                           = "zombiescansee";
		public static var TAG_ZOMBNEARESTPLAYERX:String                      = "zombnearestplayerx";
		public static var TAG_ZOMBNEARESTPLAYERY:String                      = "zombnearestplayery";
		
		public static var TAG_SERVERTIME:String                              = "servertime";
		
		public static var TAG_COLLISIONS:String                              = "collisions";
		
  	    public static var ACTION_SETUPGAME:int   		   					 = 0;
		public static var ACTION_CONFIRMSETUP:int                            = 1;
		public static var ACTION_UPDATEGAME:int                              = 2
		public static var ACTION_UPDATEPLAYER:int                            = 3;
		public static var ACTION_UPDATEZOMBIES:int                           = 4;
		public static var ACTION_UPDATETIME:int                              = 5;
		
		
		private var _es:ElectroServer;
		private var _currentRoom:Room;
		
		

		
		public function Talker(es:ElectroServer)
		{
			_es = es;
			_es.addEventListener( MessageType.PluginMessageEvent, "receiveMessage", this );
			

		}
		
		
		public function receiveMessage(e:PluginMessageEvent):void
		{
			var message:EsObject = e.getEsObject();
			
			
			try {
				var playState:PlayState = PlayState(FlxG.state);
			}
			catch (TypeError: Error)
			{
				return;
			}

			if (message.doesPropertyExist(TAG_MESSAGETYPE)) 
			{
				var messageType:int = message.getInteger(TAG_MESSAGETYPE); 

				if (messageType == ACTION_SETUPGAME)
				{
					playState.playerNames = message.getStringArray(TAG_PLAYERS);
					playState.initPositionsX = message.getIntegerArray(TAG_POSITIONSX);
					playState.initPositionsY = message.getIntegerArray(TAG_POSITIONSY);
					playState.startGame();

				}
				else if (messageType == ACTION_UPDATEGAME)
				{
					playState.updateAllies(message.getIntegerArray(TAG_POSITIONSX), message.getIntegerArray(TAG_POSITIONSY),
					    message.getIntegerArray(TAG_VELOCITIESX), message.getIntegerArray(TAG_VELOCITIESY), 
						message.getIntegerArray(TAG_SCORES), message.getBooleanArray(TAG_ALLDEAD));
					
						
					playState.updateZombies(message.getFloatArray(TAG_ZOMBIESX), message.getFloatArray(TAG_ZOMBIESY),
					    message.getFloatArray(TAG_ZOMBVELSX), message.getFloatArray(TAG_ZOMBVELSY),
						message.getFloatArray(TAG_ZOMBIESHEALTH));
						
					playState.handleCollisions(message.getStringArray(TAG_COLLISIONS));
				}
				else if (messageType == ACTION_UPDATETIME)
				{
					playState.updateTime(Number(message.getString(TAG_SERVERTIME)));
				}
			/*	else if (messageType == ACTION_GAMEOVER) 
				{
					
					
				} */
			}
		}
		
		public function confirmSetup(playerName:String):void
		{
			var message:EsObject = new EsObject();
			
			message.setInteger(TAG_MESSAGETYPE, ACTION_CONFIRMSETUP);
			
			send(message);
			
		
		}
		
		public function sendPlayerState(player:Player):void
		{
			var message:EsObject = new EsObject();
			
			message.setInteger(TAG_MESSAGETYPE, ACTION_UPDATEPLAYER);
			message.setInteger(TAG_POSX, player.x);
			message.setInteger(TAG_POSY, player.y);
			message.setInteger(TAG_VELOCITYX, player.velocity.x);
			message.setInteger(TAG_VELOCITYY, player.velocity.y);
			message.setInteger(TAG_SCORE, player.score);
			message.setBoolean(TAG_DEAD, player.dead);
		/*	
			var bulletsX:Array = new Array();
			var bulletsY:Array = new Array();
			var bulletsXVel:Array = new Array();
			var bulletsYVel:Array = new Array();
			
			var bullets:Array = player.bullets.members;
			
			for (var i:int = 0; i < bullets.length; i++)
			{
				bulletsX[i] = bullets[i].x;
				bulletsY[i] = bullets[i].y;
				bulletsXVel[i] = bullets[i].velocity.x;
				bulletsYVel[i] = bullets[i].velocity.y;
			}
			
			message.setIntegerArray(TAG_BULLETSX, bulletsX);
			message.setIntegerArray(TAG_BULLETSY, bulletsY);
			message.setIntegerArray(TAG_BULLETSXVEL, bulletsXVel);
			message.setIntegerArray(TAG_BULLETSYVEL, bulletsYVel);
			*/
			send(message);
		}
		
		public function sendZombieStates(zombies:FlxGroup):void
		{
			var message:EsObject = new EsObject();
			
			var zombiesHealth:Array = new Array();
			var canSeePlayer:Array = new Array();
			var nearestPlayerX:Array = new Array();
			var nearestPlayerY:Array = new Array();
			
			for (var i:int = 0; i < zombies.members.length; i++)
			{
				zombiesHealth[i] = zombies.members[i].life;
				//FlxG.log(zombiesHealth[i]);
				canSeePlayer[i] = zombies.members[i].canSeePlayer;
				nearestPlayerX[i] = zombies.members[i].nearestPlayer.x;
				nearestPlayerY[i] = zombies.members[i].nearestPlayer.y;
			}
			
			message.setInteger(TAG_MESSAGETYPE, ACTION_UPDATEZOMBIES);
			message.setIntegerArray(TAG_ZOMBIESHEALTH, zombiesHealth);
			message.setBooleanArray(TAG_ZOMBIESCANSEE, canSeePlayer);
			message.setIntegerArray(TAG_ZOMBNEARESTPLAYERX, nearestPlayerX);
			message.setIntegerArray(TAG_ZOMBNEARESTPLAYERY, nearestPlayerY);
			
			send(message);
		}
		
		public function requestTime():void
		{
			var message:EsObject = new EsObject();
			message.setInteger(TAG_MESSAGETYPE, ACTION_UPDATETIME);
			//_es.startSimulatingLatency(20);
			send(message);
			
		}
		
		public function send(message:EsObject):void
		{
 			var request:PluginRequest = new PluginRequest();
  			request.setPluginName( "ZombiePlugin" );
  			request.setEsObject( message );
  			request.setRoomId( _currentRoom.getRoomId());
  			request.setZoneId( _currentRoom.getZone().getZoneId());
			_es.send(request);
		}
		
		public function set currentRoom(room:Room):void
		{
			_currentRoom = room;
		}
		
	}
}