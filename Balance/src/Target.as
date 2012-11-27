package
{
	import org.flixel.*;
	
	public class Target extends FlxSprite
	{
		
		[Embed(source = "assets/images/plants/spore.png")] static private var title:Class;
		public function Target(X:Number=0, Y:Number=0, SimpleGraphic:Class=null)
		{
			super(X, Y, title);
		}

		public function move(point:FlxPoint):void
		{
			x = point.x;
			y = point.y;
		}
}
}