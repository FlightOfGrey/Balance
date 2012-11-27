package
{
	import org.flixel.*;
	
	//Ipad generation 1&2 screen dimensions: 1024w × 768h
	//Ipad generation 3 screen dimensions: 2048w x 1536h
	[SWF(width="1024", height="760", backgroundColor="#ffffff")] //Set the size and color of the Flash file
	
	
	public class Balance extends FlxGame
	{
		public function Balance()
		{
			super(1024,768,PlayState); //Create a new FlxGame object and load "PlayState"
			FlxG.framerate = 30;
		}
	}
}
