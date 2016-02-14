package
{
	import org.flixel.FlxPoint;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxG;
	public class Area
	{
		private var tilemap:FlxTilemap;
		private var _numTilesX:int;
		private var _numTilesY:int;
		
		public function Area(mapData:String)
		{
			tilemap = new FlxTilemap();
			
			_numTilesX = 150;
			_numTilesY = 150;
			
			
			
			tilemap.loadMap(generateMap() , Assets.tilemap, 16, 16);
			


			FlxG.state.add(tilemap);
			
		}
		
		public function generateMap():String
		{
			var map:String = new String();
			for (var x:int = 0; x < _numTilesX; x++)
			{
				for (var y:int = 0; y < _numTilesY; y++)
				{
					map += "1,";

				}
				map += "\n";
			}
			
			return map;
		}
		
		public function update():void
		{
			tilemap.render();
		}
		
		public function calcFOV(position:FlxPoint):void
		{
			inspectNorthNortwest();
		}
		
		public function inspectNorthNortwest():void
		{
			
		}
	}
}