package
{
	import org.flixel.*;
	
	public class IntroPic extends FlxSprite
	{
		
		[Embed(source = "assets/images/background/start_screen.png")] static private var title:Class;
		public function IntroPic(X:Number=0, Y:Number=0, SimpleGraphic:Class=null)
		{
			super(X, Y, title);
		}
	}
}