package
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.flixel.data.FlxKeyboard
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxU;
	
	public class Player extends Entity
	{
		private var _name:String;
		private var _activePlayer:Boolean;
		private var _bullets:FlxGroup;
		private var _canShoot:Boolean;
		private var _reloadTimer:Timer;
		private var _score:int;
		
		public function Player(image:Class, X:int, Y:int, Width:int, Height:int, name:String)
		{
			super(image, X, Y, Width, Height)
			
			_name = name;
			movementSpeed = 10;
			_activePlayer = false;
			
			_canShoot = true;
			
			_bullets = new FlxGroup();
			FlxG.state.add(_bullets);
			
			_reloadTimer = new Timer(500, 0);
			_reloadTimer.addEventListener(TimerEvent.TIMER, reload);
		}
		
	    override public function update():void
	    {

			keyPress();
			mouseMove();
			mousePress();
			
		    super.update();
	    }
		
		public function keyPress():void
		{
			if (FlxG.keys.justPressed("A"))
			{
				velocity.x = -movementSpeed;
			}
			else if (FlxG.keys.justPressed("D"))
			{
				velocity.x = movementSpeed;
			}
			else if ((FlxG.keys.justReleased("A") && !FlxG.keys.pressed("D")) || (FlxG.keys.justReleased("D") && !FlxG.keys.pressed("A")))
			{
				velocity.x = 0;
			}
			
			if (FlxG.keys.justPressed("W"))
			{
				velocity.y = -movementSpeed;
			}
			else if (FlxG.keys.justPressed("S"))
			{
				velocity.y = movementSpeed;
			}
			else if ((FlxG.keys.justReleased("W") && !FlxG.keys.pressed("S")) || (FlxG.keys.justReleased("S") && !FlxG.keys.pressed("W")))
			{
				velocity.y = 0;
			}
		}
		
		public function mouseMove():void
		{

		}
		
		public function mousePress():void
		{
			
			if (FlxG.mouse.pressed() && _canShoot)
			{
				shoot();
			}

		}
		
		public function shoot():void
		{
			_bullets.add(new Bullet(x, y, 1, 1, 0x777777));
			_canShoot = false;
			_reloadTimer.start();

			
		}
		
		public function reload(e:TimerEvent):void
		{
			_canShoot = true;
			_reloadTimer.stop();
		}
		
		public function zombAttack():void
		{
			kill();
		}
		
		public function get bullets():FlxGroup
		{
			return _bullets;
		}
		
		public function get score():int
		{
			return _score;
		}
		
		public function set activePlayer(ap:Boolean):void
		{
			_activePlayer = ap;
		}
		
		public function set score(s:int):void
		{
			_score = s;
		}
		
	
		

	}
}