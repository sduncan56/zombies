package
{
	import com.electrotank.electroserver4.esobject.DataType;
	import com.electrotank.electroserver4.room.Room;
	import com.electrotank.electroserver4.user.User;
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.entities.Protocol;
	import com.electrotank.electroserver4.message.event.PluginMessageEvent;
	import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
	import fl.controls.List;
	import fl.controls.TextInput;
	import mx.controls.TextArea;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;

	import org.flixel.FlxState;
	import org.flixel.FlxG;
	import flash.text.TextField;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;

	
	public class LobbyState extends FlxState
	{
		private var waitName:Boolean;
		private var inputText:TextInput;
		public var nameText:TextInput;
		private var bgImg:FlxSprite;
		private var chatBox:ChatBox;
		
		private var sendBtn:FlxButton;
		private var nameBtn:FlxButton;

		private var uList:List;
		private var quickJoinBtn:FlxButton;
		
		private var _changeState:Boolean;
		private var _es:ElectroServer;
		
		private var instructionsText:FlxText;
		
		public var chatES:Chat;
		
  	    public static var TAG_MESSAGETYPE:String 		   					 = "messagetype";
		public static var TAG_TARGETTYPES:String                             = "targettypes";
  	    public static var ACTION_SETUPGAME:int   		   					 = 1;	


		public function LobbyState()
		{
			
		}
		
		override public function create():void
		{
			_es = new ElectroServer();
			_es.setDebug(true);
			_es.setProtocol(Protocol.BINARY);
			
			_es.addEventListener( MessageType.PluginMessageEvent, "receiveMessage", this );
			
			_changeState = false;
			
			FlxG.mouse.show();
			
			//bgImg = new FlxSprite(0, 0, Assets.backgroundlobby);
			//add(bgImg);

			nameText = new TextInput()
			nameText.x = 110;
			nameText.y = 250;
			nameText.width = 250;
			nameText.height = 20
			addChild(nameText);
			
			nameBtn = new FlxButton(361, 248, onName); 
			nameBtn.loadGraphic(new FlxSprite(0, 0, Assets.sendBtn));
			add(nameBtn);
			
			waitName = true;	
		}
		
		override public function update():void
		{	
			if (!waitName)
			{
				if (chatES.chatString != "")
				{
					chatBox.addText(chatES.chatString);
					chatES.chatString = "";
				}
				
				if (chatES.showUL)
				{
					var users:Array = chatES.userList;
					uList.removeAll();
					
					for (var i:int = 0; i < users.length;  i++)
					{
						var u:User = users[i];
						uList.addItem( { label:u.getUserName(), data:u } );
					}
				}
				
				
				if (chatES.leaveRoom == true)
				{
					_changeState = true;
				}
			}
			
			super.update();
		}
		

		
		public function receiveMessage(e:PluginMessageEvent):void
		{
			//THIS IS A HACK
			//I suspect this problem occurs because Flash stops running when it's not on focus, so
			//it misses the message when the game is being run on the same machine
			//I believe it would work without this if played over a network
			// - but not really sure because brain kinda fried right now
			
			var message:EsObject = e.getEsObject();
			if (message.doesPropertyExist(TAG_MESSAGETYPE))
			{
				var messageType:int = message.getInteger(TAG_MESSAGETYPE);
				if (messageType == ACTION_SETUPGAME)
				{

				}
			}
		}
		
		public function onSend():void
		{
			chatES.sendMessage(inputText.text);
		}
		
		public function onName():void
		{
			var tempName:String = nameText.text;
			
			//inputText = new FlxInputText(30, 400, 400, 20, "hello?", 0xffffff);
			inputText = new TextInput()
			inputText.x = 30;
			inputText.y = 400;
			inputText.width = 400;
			inputText.height = 20;
			addChild(inputText);	
			
			//having some kind of text here is a good idea, or height will not be set
			chatBox = new ChatBox(30, 30, 300, "Welcome to the chat! \n");
			add(chatBox);
			
			//Userlist initialise
			uList = new List();
			uList.x = 300;
			uList.y = 30;
			uList.width = 100;
			uList.height = 300;
			addChild(uList);
			
			var hTxt:String = "Instructions:"
			var hText:FlxText = new FlxText(430, 50, 100, hTxt);
			hText.setFormat(null, 12, 0xff0000);
			add(hText);
			var instTxt:String = "Click 'join' to join a game.\n\nWASD to move. Left mouse to shoot. \nTry not to die."
            instructionsText = new FlxText(430, 80, 100, instTxt);
			add(instructionsText);
		
			//Intialise the send button
			sendBtn = new FlxButton(430, 400, onSend);
			sendBtn.loadGraphic(new FlxSprite(0, 0, Assets.sendBtn));
			add(sendBtn);
			
			quickJoinBtn = new FlxButton(500, 400, onQuickJoin);
			quickJoinBtn.loadGraphic(new FlxSprite(0, 0, Assets.quickJoinBtn));
			add(quickJoinBtn);
			
			chatES = new Chat(_es, tempName);
			chatES.parseXML();
			chatES.connect();
			
			nameText.visible = false;
			
			
			waitName = false;
		}
			
			
		
		public function onQuickJoin():void
		{
			chatES.quickJoinGame("ZombiePlugin");
		}
		
		public function get changeState():Boolean
		{
			return _changeState;
		}
		
		public function get es():ElectroServer
		{
			return _es;
		}
		
		public function get pName():String
		{
			return chatES.name;
		}
		
		public function get room():Room
		{
			return chatES.myroom;
		}
	}
}