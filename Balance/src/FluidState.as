package
{
	import org.flixel.*;
	import com.hopmanlars.fluid.fluidShader;
	
	public class FluidState extends FlxState
	{
		
		private var shader:fluidShader;
		private var oldMouseX:Number = 0;
		private var oldMouseY:Number = 0;
		
		public function FluidState()
		{
			super();
		}
		
		override public function create():void
		{
			super.create();
			shader = new fluidShader(128, 128);
			shader.scaleX = shader.scaleY = 4;
			add(shader);
		}
	}
}