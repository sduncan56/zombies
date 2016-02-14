package 
{
	import org.flixel.*;
	import flash.events.Event;
	
	[SWF(width="640", height="480", backgroundColor="#000000")]

	
	public class Game extends FlxGame
	{
		
		private var curState:String;
		
		public function Game():void
		{
			super(640, 480, LobbyState, 1);

			curState = "LobbyState";
			
			this.pause = new FlxGroup();
		}
		
		override protected function update(event:Event):void
		{
			if (FlxG.state != null)
			{
			    if (curState == "LobbyState")
			    {
				    var state:LobbyState = LobbyState(FlxG.state);
		
				    if (state.changeState == true)
				    {  
					    switchState(new PlayState());
						var playState:PlayState = PlayState(FlxG.state);
						curState = "PlayState";
						playState.es = state.es;
						playState.pName = state.pName;
						playState.room = state.room;
				    }
			    }
				if (curState == "PlayState")
				{
					var state2:PlayState = PlayState(FlxG.state);
					
					if (state2.changeState == true)
					{
						switchState(new LobbyState());
						var lobbyState:LobbyState = LobbyState(FlxG.state);
						lobbyState.nameText.text = state2.pName;
						lobbyState.onName();
						curState = "LobbyState";
					}
				}
		    }
		    super.update(event);
		}

	}
}
	