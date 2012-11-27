package
{
	import com.hopmanlars.fluid.fluidShader;
	import org.flixel.*;
	
	public class FluidStuff extends FlxSprite
	{
		private var shader:Class = new fluidShader(64,64)
		public function FluidStuff(X:Number=0, Y:Number=0, SimpleGraphic:Class=null)
		{
			super(X, Y, shader);
		}
	}
}