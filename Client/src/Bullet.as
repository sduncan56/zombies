package
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	import org.flixel.FlxG;
	public class Bullet extends FlxSprite
	{
		private var bulletVel:int = 400;
		
		public function Bullet(X:int, Y:int, Width:int, Height:int, Colour:int)
		{
			super(X, Y);
			//createGraphic(Width, Height, Colour);
			loadGraphic(Assets.bullet, false, false, 1, 1);
			calcVelocity();

			FlxG.state.add(this);
			
		}
		
		override public function update():void
		{
			//checkBoundaries();
			super.update();
		}
		
		public function checkBoundaries():void
		{
			if (x > 640 || x < 0 || y > 480 || y < 0)
			{
				kill();
			}
		}
		
		public function calcVelocity():void
		{
	        var bXVel:int = 0;
	        var bYVel:int = 0;
	        var bX:int = x;
	        var bY:int = y;
			
        	//differences in vertical and horizontal positions
	        var xX:int = this.x - FlxG.mouse.x;
	        var yY:int = this.y - FlxG.mouse.y;
			
	        //absolute values thereof
	        var dX:int = FlxU.abs(xX);
	        var dY:int = FlxU.abs(yY);
			
	        //proportional calculations of (absolute) horizontal and vertical velocities		
	        var velX:int = FlxU.floor(dX / (dX + dY) * bulletVel);
	        var velY:int = FlxU.floor(dY / (dX + dY) * bulletVel);
			
	        //if cursor is higher than player, that is: player.y is higher than mouse.y
	        //(0,0) coordinates are in the top-left corner, so higher y = lower position on screen
	        if(yY > 0)
	        {
		       bY -= height - 4; 
		       bYVel = -velY; 
	        }
	        else
	        {
		        bY += height - 4;
		        bYVel = velY;
		        velocity.y -= 36;
	        }
				
	        if(xX > 0) //if cursor is to the left of the player
	        {
		        bX -= width - 4;
		        bXVel = -velX;
	        }
	        else
	        {
		        bX += width - 4;
		        bXVel = velX;
	        }
			
			velocity.x = bXVel;
			velocity.y = bYVel;
		}
		
	}
}