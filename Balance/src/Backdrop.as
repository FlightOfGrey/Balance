package
{
	/**
	 * ...
	 * @author Jason Seip
	 */
	import org.flixel.*;
	
	public class Backdrop extends FlxSprite
	{	
		
		[Embed(source="assets/images/background/paper_background_01.png")] public var ImgBackdrop:Class;
		
		public function Backdrop(x:Number=0, y:Number =0)
		{
			super(x, y);
			loadGraphic(ImgBackdrop, false);					//False parameteer means this is not a sprite sheet
			solid = false;  //Just to make sure no collisions with the backdrop ever take place
		}
	}
}