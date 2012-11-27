package 
{
	import flashx.textLayout.formats.Float;
	
	import org.flixel.*;
	
	public class MouseStuff extends FlxSprite
	{
		private static var instance:MouseStuff;
		private static var allowInstantiation:Boolean = false;
		
		private var oldmouseY:Number = 0;
		private var oldmouseX:Number = 0;
		private var mouseVelX:Number = 0;
		private var mouseVelY:Number = 0;
		private var limitVel:Number = 30;
		
		[Embed(source="assets/images/mouse.png")] static private  var Img1:Class;
		
		public static function getMouseStuff():MouseStuff
		{
			if(instance == null)
			{
				allowInstantiation = true;
				instance = new MouseStuff();
				allowInstantiation = false;
			}
			return instance;
		}
		
		public function MouseStuff(X:Number=0, Y:Number=0, SimpleGraphic:Class=null)
		{
			if(allowInstantiation){
				super(X, Y, SimpleGraphic);
				loadGraphic(Img1);
			}else{
				throw new Error ("Error: instantion failed: use MouseStuff.getMouseStuff");
			}
		}
		
		private function rotateSprite():void
		{
			if(FlxG.mouse.pressed()){
				this.angle += 10;
			} else {
				this.angle +=3;
			}
		}
		
		override public function update():void
		{
			rotateSprite();
			oldmouseX = x;
			oldmouseY = y;
			x = FlxG.mouse.x;
			y = FlxG.mouse.y;
			mouseVelX = x - oldmouseX;
			mouseVelY = y - oldmouseY;
			super.update();
		}
		
		public function getVelX():Number
		{
			return mouseVelX;
		}
		
		public function getVelY():Number
		{
			return mouseVelY;
		}
	}
}