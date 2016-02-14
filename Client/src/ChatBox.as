package
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	public class ChatBox extends FlxText
	{
		private var bgBox:FlxSprite;
		
		public function ChatBox(X:Number, Y:Number, Width:uint, Text:String=null)
		{
			super(X + 10, Y + 10, Width, Text);
			
			bgBox = new FlxSprite(X, Y, Assets.bgBox);
			FlxG.state.add(bgBox);
		}
		
		public function addText(txt:String):void
		{
			text = _tf.text.concat(txt + "\n");
			
			if (_tf.numLines > 30)
			{
				var str:String = _tf.text;
				var tempStrArray:Array = str.split("\r");

				text = _tf.text.slice(tempStrArray[0].length+2);

			}
		}	
	}
}