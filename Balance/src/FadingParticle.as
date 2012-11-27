package  
{
	import flash.utils.getTimer;
	
	import org.flixel.FlxG;
	import org.flixel.FlxParticle;
	import org.flixel.FlxPoint;
	import org.flixel.FlxTimer;
	
	/**
	 * 
	 */
	public class FadingParticle extends FlxParticle 
	{
		protected var FadingTimer:FlxTimer;
		private var isBoidParticle:Boolean;
		
		[Embed(source="assets/images/single_triangle.png")] public var Img0:Class;
		[Embed(source="assets/images/plant_triangle.png")] public var Img1:Class;
		
		public function FadingParticle(boid:Boolean, xPos:Number = -20, yPos:Number = -20) 
		{
			super();
			this.x  = xPos;
			this.y  = yPos;
			this.exists = true;
			isBoidParticle = boid;
			if(isBoidParticle){
				loadGraphic(Img0);
			} else{
				loadGraphic(Img1);
			}
			alpha = 1;
			FadingTimer = new FlxTimer();
		}
		
		override public function onEmit():void
		{
			elasticity = 0.8;
			drag = new FlxPoint(4, 0);
			FadingTimer = new FlxTimer();
			alpha = 1;
			
		}
		
		private function distance(f:FlxPoint):Number
		{
			var xd:Number = this.x - f.x;
			var yd:Number = this.y - f.y;
			return Math.sqrt(xd * xd + yd*yd);
		}
		
		protected function fade(Timer:FlxTimer):void
		{
			if (!alpha>0.15){
				this.exists = false;
				if(!isBoidParticle){
					//Potential to create new plant
					var s:PlayState = FlxG.state as PlayState;
					var memberPos:FlxPoint = new FlxPoint;
					var newPlant:Boolean = true;
					for each(var member:* in s.plants.members){
						if(member !=null && member.alive){
							memberPos.x = member.x;
							memberPos.y = member.y;
							if(distance(memberPos) < 70){
								newPlant = false;
							}
						}
					}
					
					if(newPlant && FlxG.random() > 0.6) {
						var p:Plant = new PlantSpeciesX(s.plantEmitter, this.x, this.y);
						s.plants.add(p);
					}
				}
			} else {
				alpha -= 0.01;
				FadingTimer.start(1, 1, fade);
			}
			
		}
		
		override public function update():void
		{
			super.update();
			fade(FadingTimer);
			
		}
	}
	
}