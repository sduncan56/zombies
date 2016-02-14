package
{
	import flash.display.Sprite;
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSound;
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	import org.flixel.FlxText;
	import org.flixel.FlxSprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import Date
	
	
	import com.electrotank.electroserver4.ElectroServer;
	import com.electrotank.electroserver4.room.Room;
	

	
	public class PlayState extends FlxState
	{
		private var area:Area;
		private var _player:Player;
		
		private var talker:Talker;
		
		private var playerName:String;	
		private var _playerNames:Array;
		private var _initPositionsX:Array;
		private var _initPositionsY:Array;
		
		private var _allies:FlxGroup;
		private var _zombies:FlxGroup;
		
		private var _gameSetup:Boolean;
		private var _gameOver:Boolean;
		
		private var _playerIndex:int;
		
		private var sendUpdateTimer:Timer;
		
		private var lastTime:Number;
		private var latencyOffset:Number;
		private var date:Date;
		private var time:int;
		private var timeDiff:int;
		private var latencies:Array;
		
		public var changeState:Boolean;
		
		private var myScoreTxt:FlxText;
		private var opponentScoreTxt:FlxText;
		

		
		public function PlayState()
		{	
		}
		
		override public function create():void
		{
			FlxG.mouse.show();
			sendUpdateTimer = new Timer(50);
			sendUpdateTimer.addEventListener(TimerEvent.TIMER, updateServer);	
			date = new Date();
			FlxG.maxElapsed = 100;
			lastTime = date.getTime();
			timeDiff = 0;
			latencies = new Array();
			
			_gameSetup = false;
			_gameOver = false;
			
			_allies = new FlxGroup();
			add(_allies);
			
			_zombies = new FlxGroup();
			add(_zombies);

			area = new Area("zombie");
			
			myScoreTxt = new FlxText(200, 10, 150, "Score : 0");
			add(myScoreTxt);
			myScoreTxt.scrollFactor.x = 0;
			myScoreTxt.scrollFactor.y = 0;
			opponentScoreTxt = new FlxText(200, 25, 150, "");
			add(opponentScoreTxt);
			opponentScoreTxt.scrollFactor.x = 0;
			opponentScoreTxt.scrollFactor.y = 0;
			
			FlxG.music = new FlxSound();
			FlxG.music.loadEmbedded(Assets.bgmusic, true);
			FlxG.music.survive = false;
			FlxG.music.play();			
			
			
		}

		override public function update():void
		{	

			area.update();
			if (_gameSetup && !_gameOver)
			{
				FlxG.follow(_player);
				updateScore();
			    collisionDetection();
				if (_player.dead)
				{
					gameOver();
				}
			}

			super.update();
		}
		
		public function updateTime(serverTime:Number):void
		{
			var now:Date = new Date();
			latencies.push(now.getTime() - latencyOffset);
			
			var latency:Number = 0;
			for each (var num:Number in latencies)
			{
				latency += num
			}
			latency /= latencies.length;
			//FlxG.log(latency);
			var offset:Number = serverTime - date.time + latency;
			time = serverTime + offset;
			
			timeDiff = time - lastTime;
			lastTime += timeDiff;
				
			_player.timeDiff = timeDiff;
			for each (var ally:Ally in _allies.members)
			{
				ally.timeDiff = timeDiff;
			}
			
			for each (var zombie:Zombie in _zombies.members)
			{
				zombie.timeDiff = timeDiff;
			}
				
			
		}
		
		public function startGame():void
		{
			if (!_gameSetup)
			{
			    for (var i:int = 0; i < _playerNames.length; i++)
			    {
					if (playerName == _playerNames[i])
					{
						_player = new Player(Assets.player, _initPositionsX[i], _initPositionsY[i], 16, 16, _playerNames[i]);
						_playerIndex = i;
						_allies.add(new Ally(Assets.player, _initPositionsX[i], _initPositionsY[i], 16, 16, "dummy"));

					}
					else
					{
				        _allies.add(new Ally(Assets.player, _initPositionsX[i], _initPositionsY[i], 16, 16, _playerNames[i]));
					}

			    }
				talker.confirmSetup(playerName);
				_gameSetup = true;
				sendUpdateTimer.start();
			}

		}
		
		public function updateServer(e:TimerEvent):void
		{
			//same hackiness as below.
			var ally:Ally = _allies.getFirstAlive() as Ally;
			for (var i:int = 0; i < _zombies.members.length; i++)
			{
				if (i < _zombies.members.length / 2)
				{
					_zombies.members[i].nearestPlayer = new FlxPoint(_player.x, _player.y);
				}
				else
				{
					_zombies.members[i].nearestPlayer = new FlxPoint(ally.x, ally.y);
				}
				
				
				
				/*
				var zombie:Zombie = _zombies.members[i] as Zombie;
				if (_player.x - zombie.x < ally.x - zombie.x &&
				    _player.y - zombie.y < ally.y  - zombie.y)
				{
					_zombies.members[i].nearestPlayer = new FlxPoint(_player.x, _player.y);
				}
				else
				{
					_zombies.members[i].nearestPlayer = new FlxPoint(ally.x, ally.y);
				}
				*/
			}
			
			
			talker.sendPlayerState(_player);
			if (_zombies.members.length > 0)
			{
			    talker.sendZombieStates(_zombies);
			}
			    var now:Date = new Date();
			    latencyOffset = now.getTime();
			    talker.requestTime();
		}
		
		public function updateScore():void
		{
			myScoreTxt.text = "Score: " + _player.score;
			//hacky, but as there isn't going to be any more players anymore it really doesn't matter.
			var ally:Ally = _allies.getFirstAlive() as Ally;
			opponentScoreTxt.text = ally.name + ": " + ally.score;

			
		}
		
		
		public function updateAllies(posX:Array, posY:Array, velX:Array, velY:Array, score:Array, dead:Array):void
		{
			
			for (var i:int = 0; i < _allies.members.length; i++)
			{
				if (i != _playerIndex)
				{
				    _allies.members[i].updatePosVel(posX[i], posY[i], velX[i], velY[i]);
					_allies.members[i].score = score[i];
				}
			}
			
			for (i = 0; i < dead.length; i++)
			{
				if (dead[i] == true && _allies.members[i].name != "dummy" && _gameOver == false)
				{
					gameOver();
				}
			}
			
			
		}
	
		
		public function updateZombies(posX:Array, posY:Array, velX:Array, velY:Array, zHealth:Array):void
		{
			if (posX.length > _zombies.members.length)
			{
				var zombiesNeeded:int = posX.length - _zombies.members.length;
				for (var j:int = zombiesNeeded; j > 0; j--)
				{
					_zombies.add(new Zombie(Assets.zombie, posX[_zombies.members.length+1], posY[_zombies.members.length+1], 16, 16));
				}
			}
			//FlxG.log(zHealth);
			for (var i:int = 0; i < _zombies.members.length; i++)
			{
				_zombies.members[i].updatePosVel(posX[i], posY[i], velX[i], velY[i]);
				_zombies.members[i].health = zHealth[i];
				if (zHealth[i] == 0)
				{
					_zombies.members[i].kill();
				}
			}
		}
		
		public function handleCollisions(colArray:Array):void
		{
			for (var i:int; i < colArray.length; i++)
			{
				var splitCols:Array = colArray[i].split(/-/);
				
				if (playerName == splitCols[1] && _zombies.members[Number(splitCols[0])-1].dead == false)
				{
					_player.zombAttack();
				}
				
			}
		}
		
		public function collisionDetection():void
		{
			//between bullets and zombies
			FlxU.overlap(_zombies, _player.bullets, zombieShot);
		}
		
		public function zombieShot(z:FlxObject, b:FlxObject):void
		{
			var zombie:Zombie = z as Zombie;
			var bullet:Bullet = b as Bullet;
			
			if (!zombie.dead)
			{
				_player.score = _player.score + 1;
			    zombie.shot(bullet.velocity);
			    bullet.kill();				
			}
		}
		
		
		public function gameOver():void
		{
			var win:Boolean = true;
			for (var i:int = 0; i < _allies.members.length; i++)
			{
				if (_allies.members[i].score > _player.score)
				{
					var loserTxt:FlxText = new FlxText(200, 100, 40, "You lose!");
					loserTxt.scrollFactor.x = 0;
					loserTxt.scrollFactor.y = 0;
					add(loserTxt);
					win = false;
				}
			}
			if (win == true)
			{
				var winnerTxt:FlxText = new FlxText(200, 100, 40, "You win!");
				winnerTxt.scrollFactor.x = 0;
				winnerTxt.scrollFactor.y = 0;
				add(winnerTxt);
			}
			
			var lobbyReturn:FlxButton = new FlxButton(200, 300, retToLobby);
			lobbyReturn.loadText(new FlxText(0, 0, 100, "Return to lobby"));
			lobbyReturn.scrollFactor.x = 0;
			lobbyReturn.scrollFactor.y = 0;
			add(lobbyReturn);	
			
			sendUpdateTimer.stop();
			_gameOver = true;
		}
		
		public function retToLobby():void
		{
			changeState = true;
		}
		
		public function set es(server:ElectroServer):void
		{			
			talker = new Talker(server);
		}
		
		public function set pName(name:String):void
		{
			playerName = name;
		}
		
		public function set playerNames(pNames:Array):void
		{
			_playerNames = pNames;
		}
		
		public function set initPositionsX(posX:Array):void
		{
			_initPositionsX = posX;
		}

		public function set initPositionsY(posY:Array):void
		{
			_initPositionsY = posY;
		}
		
		public function set room(room:Room):void
		{
			talker.currentRoom = room;
		}
		
		public function get pName():String
		{
			return playerName;
		}
		
		
		
	}
}