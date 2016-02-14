package
{
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.entities.Protocol;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.errors.*;	
	import com.electrotank.electroserver4.room.Room;
	import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.entities.SearchCriteria 

	
	import flash.utils.ByteArray;
	import org.flixel.FlxG;
	
	public class Chat
	{
		private var es:ElectroServer;
		private var serverInfo:Object;
		private var myRoom:Room;
		
		private var _chatString:String;
		private var _userList:Array;
		
		private var _username:String;

		
		private var listenersBA:ByteArray;
		private var listenXML:XML;
		
		public var showUL:Boolean;
		MessageType.ConnectionEvent;
		
		private var _gameList:Array;
		private var isGameReqSent:Boolean;
		
		private var isQuickJoinGameRequestSent:Boolean;
		private var chatRoom:Room;
		
		private var _leaveRoom:Boolean;
		public var name:String;
		
		
		
		public function Chat(server:ElectroServer, newName:String)
		{
			es = server;

			_username = newName;
			_chatString = "";
			_userList = [];
			showUL = false;
			
			_gameList = ["test!"];
			isGameReqSent = false;
			
			isQuickJoinGameRequestSent = false;
			_leaveRoom = false;

			
			es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
			es.addEventListener(MessageType.LoginResponse, "onLoginResponse", this);
			es.addEventListener(MessageType.JoinRoomEvent, "onJoinRoomEvent", this);
			es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
			es.addEventListener(MessageType.UserListUpdateEvent, "onUserListUpdateEvent", this);
			es.addEventListener( MessageType.CreateOrJoinGameResponse, "onCreateOrJoinGameResponse", this );   	




		}
		
		public function parseXML():void
		{
			for each (var lis:XML in Assets.listeners)
			{
				var protocol:String = lis.@protocol;
				var ip:String = lis.@ip;
				var port:Number = Number(lis.@ip);
				
				serverInfo[protocol] = new Object();
				serverInfo[protocol].ip = ip;
				serverInfo[protocol].port = port;
			}
			
		}
		
		public function connect():void
		{
			
			es.createConnection("127.0.0.1", 9899);
		}
		
		public function onConnectionEvent(ev:ConnectionEvent):void
		{
			if (ev.getAccepted())
			{
				output("Connection accepted");
				name = _username;
				output("Attempting to login as: " + name);
				
				var lr:LoginRequest = new LoginRequest();
				lr.setUserName(name);
				es.send(lr);
			}
			else
			{
				output("Connection failed: "+ev.getEsError().getDescription());
			}
		} 
		
		public function onLoginResponse(e:LoginResponse):void
		{
			if (e.getAccepted())
			{
				output("login accepted.");
				output("You are logged in as: " + e.getUserName());
				joinRoom();
			}
			else
			{
				output("Login failed: "+e.getEsError().getDescription());
			}
		}
		
		public function onJoinRoomEvent(e:JoinRoomEvent):void
		{
			myRoom = e.room;
			showUserList();
		}
		
		public function onUserListUpdateEvent(e:UserListUpdateEvent):void
		{
			showUserList();
		}
		
        public function onPublicMessageEvent(e:PublicMessageEvent):void 
		{
			var from:String = e.getUserName();
            var msg:String = e.getMessage();
			output(from+": "+msg);


		}

		
		private function showUserList():void
		{
			showUL = true;
			
			_userList = myRoom.getUsers();
		}
		
		public function joinRoom():void
		{
			var crr:CreateRoomRequest = new CreateRoomRequest();
			crr.setRoomName("MyRoom");
			crr.setZoneName("ZoneName");
			
			es.send(crr);
		}
		
		public function sendMessage(message:String):void
		{
			if (message != "")
			{
				var pmr:PublicMessageRequest = new PublicMessageRequest();
				pmr.setRoomId(myRoom.getRoomId());
                pmr.setZoneId(myRoom.getZone().getZoneId());
                pmr.setMessage(message);
                es.send(pmr);

			}
		}
		
		public function quickJoinGame(gameType:String):void
		{
  	        if( gameType != "" && !isQuickJoinGameRequestSent)
  	        {
				chatRoom = myRoom;

				isQuickJoinGameRequestSent = true;
				
  		        var gameRequest:QuickJoinGameRequest = new QuickJoinGameRequest();
  		        gameRequest.setGameType( gameType );
  		        gameRequest.setZoneName( gameType );
				
  		        var criteria:SearchCriteria = new SearchCriteria();
  		        criteria.setGameType( gameType );
  		
  		        gameRequest.setSearchCriteria( criteria );
  		
  		        es.send( gameRequest );

			}
			
		}
		
    	public function onCreateOrJoinGameResponse( e:CreateOrJoinGameResponse ):void
  	    {
  		    isQuickJoinGameRequestSent = false;
  		    if( e.getSuccessful() )
  		    {
  			    leaveChatRoom();
  		    } 
			else
			{
				output("joining game not successful");
			}
  	    }
		
      	private function leaveChatRoom():void
  	    {	
  		    var leaveRequest:LeaveRoomRequest = new LeaveRoomRequest();
  		    leaveRequest.setRoomId( chatRoom.getRoomId() );
  		    leaveRequest.setZoneId( chatRoom.getZoneId() );
  		
  		    es.send( leaveRequest );
			_leaveRoom = true;
			
		}
 
		
		
		public function output(msg:String):void
		{
			_chatString += msg+"\n";
		}
		
		public function get chatString():String
		{
			return _chatString;
		}
		
		public function get userList():Array
		{
			return _userList;
		}
		
		public function get gameList():Array
		{
			return _gameList;
		}
		
		public function set chatString(str:String):void
		{
			_chatString = str;
		}
		
		public function get leaveRoom():Boolean
		{
			return _leaveRoom;
		}
		
		public function get myroom():Room
		{
			return myRoom;
		}
		
		
		
	}
}
