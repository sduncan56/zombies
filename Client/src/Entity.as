package
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	public class Entity extends FlxSprite
	{
		protected var movementSpeed:int = 0;
		private var _timeDiff:int;
		
		protected var _idealX:int;
		protected var _idealY:int;
		protected var _idealVelX:int;
		protected var _idealVelY:int;
		
		protected var _interpXVal:Number;
		protected var _interpYVal:Number;
		protected var _catchUp:int;
		
		public function Entity(image:Class, X:int, Y:int, Width:int, Height:int)
		{
			super(X, Y);
			loadGraphic(image, true, true, Width, Height); 	
			_idealX = X;
			_idealY = Y;
			_idealVelX = 0;
			_idealVelY = 0;
			_interpXVal = 0;
			_interpYVal = 0;
			_catchUp = 0;
			
			FlxG.state.add(this)
		}
		
		override public function update():void
		{
			move();
			super.update();
		}
		
		
		public function catchUp():void
		{
			var xDiff:Number = x - _idealX;
			var yDiff:Number = y - _idealY;
			
			_interpXVal = xDiff / 5;
			_interpYVal = yDiff / 5;
			_catchUp = 5;
		}
		
		public function move():void
		{
			if (_catchUp > 0)
			{
				x -= _interpXVal;
				y -= _interpYVal;
				_catchUp--;
			}

			
			x += _timeDiff * (velocity.x / 1000);
			y += _timeDiff * (velocity.y / 1000);	
			

			//FlxG.log(timeDiff);
			//FlxG.log(x);
		}
		
		override protected function updateMotion():void
		{

		}
		
		public function set timeDiff(tDiff:int):void
		{
			_timeDiff = tDiff;
		}

	}
}