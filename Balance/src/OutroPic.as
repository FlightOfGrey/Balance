package
{
	import org.flixel.*;
	
	public class OutroPic extends FlxSprite
	{
		
		[Embed(source = "assets/images/background/white_screen.png")] static private var title:Class;
		public function OutroPic(X:Number=0, Y:Number=0, SimpleGraphic:Class=null)
		{
			super(X, Y, title);
		}
	}
}