package
{
	import org.flixel.FlxG;
	
	public class Ally extends Entity
	{
		private var _name:String;
		private var _score:int;

		
		public function Ally(image:Class, X:int, Y:int, Width:int, Height:int, name:String)
		{
			super(image, X, Y, Width, Height)
			
			if (name == "dummy")
			{
				visible = false;
				dead = true;
			}
			

			
			_name = name;
			movementSpeed = 40;			
		}
		
		override public function update():void
		{
			super.update();
		}
		
		
		public function updatePosVel(X:int, Y:int, VelX:int, VelY:int):void
		{
			
			_idealX = X;
			_idealY = Y;

			_idealVelX = VelX;
			_idealVelY = VelY;
			
			velocity.x = _idealVelX;
			velocity.y = _idealVelY;
			
			catchUp();

			//calcVel();
			

		}
		
		public function get score():int
		{
			return _score;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set score(s:int):void
		{
			_score = s;
		}
	}
}