package
{
	import org.flixel.*;
	
	public class StartPic extends FlxSprite
	{
		
		[Embed(source = "assets/images/background/end_screen.png")] static private var title:Class;
		public function StartPic(X:Number=0, Y:Number=0, SimpleGraphic:Class=null)
		{
			super(X, Y, title);
		}
	}
}