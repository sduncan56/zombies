package
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	public class Zombie extends Entity
	{
		private var _nearestPlayer:FlxPoint;
		private var _canSeePlayer:Boolean;
		private var _life:int;
		
		public function Zombie(image:Class, X:int, Y:int, Width:int, Height:int)
		{
			super(image, X, Y, Width, Height)
			
			_idealX = X;
			_idealY = Y;
			
			_nearestPlayer = new FlxPoint(200,200);
			health = 5;
			_life = 5;

			
			_canSeePlayer = true;
			
		}
		
		override public function update():void
		{
			/*
			if (health <= 0)
			{
				kill();
				//dead = true;
				//visible = false; //temp
				//active = false;
				//solid = false;
			} */
			super.update();
		}
		


		public function updatePosVel(X:Number, Y:Number, VelX:Number, VelY:Number):void
		{
			
			_idealX = X;
			_idealY = Y;
			
			_idealVelX = VelX;
			_idealVelY = VelY;
			
			catchUp();
		}
		
		
		public function shot(bulletVel:FlxPoint):void
		{
			
			//play blood animation
			//if (!dead)
			//{
			health -= 5; //temp
			_life = 0;
			kill();
			//}

		}
		
		public function get life():int
		{
			return _life;
		}
		
		public function get canSeePlayer():Boolean
		{
			return _canSeePlayer;
		}
		
		public function get nearestPlayer():FlxPoint
		{
			return _nearestPlayer;
		}
		
		public function set nearestPlayer(np:FlxPoint):void
		{
			_nearestPlayer = np;
		}
	}
}