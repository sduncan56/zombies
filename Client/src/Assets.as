package
{
	public class Assets
	{
		[Embed(source = "data/listeners.xml", mimeType = "application/octet-stream")]
		public static var listeners:Class;
		
		[Embed(source = "images/bgBox.png")]
		public static var bgBox:Class;
		
		[Embed(source = "images/sendBtn.png")]
		public static var sendBtn:Class;
		
		[Embed(source = "images/quickjoinbtn.png")]
		public static var quickJoinBtn:Class;
		
		[Embed(source = "images/bullet.png")]
		public static var bullet:Class;
		
		[Embed(source = "images/player.png")]
		public static var player:Class;
		
		[Embed(source = "images/zombie.png")]
		public static var zombie:Class;
		
		[Embed(source = "data/zombie.txt", mimeType = "application/octet-stream")]
		public static var zombiemap:Class;
		
		[Embed(source = "images/tilemap.png")]
		public static var tilemap:Class;
		
		[Embed(source = "sound/amiga accordion.mp3")]
		public static var bgmusic:Class;
	}
}