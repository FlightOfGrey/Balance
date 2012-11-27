package
{
	import org.flixel.*;
	
	/**
	 *Class representing any species which acts like a plant ie. does not move
	 * on its own accord or by the force of the current.  Can be eaten by herbavors(Boids).
	 * 
	 * @author Lars Hopman
	 */
	
	public class Plant extends FlxSprite
	{
		
		static private var emitter:FlxEmitter;
		
		[Embed(source="assets/images/plants/plant_01.png")] public var sprite1:Class;
		[Embed(source="assets/images/plants/plant_02.png")] public var sprite2:Class;
		[Embed(source="assets/images/plants/plant_03.png")] public var sprite3:Class;
		[Embed(source="assets/images/plants/plant_04.png")] public var sprite4:Class;
		
		/**Lower numbers have higher chance of regrowth. Must be less than 1 for any
		 * growth to happen.  Default 0.5.
		 */
		public var growSpeed:Number = 0.5;
		
		/**Sets the max health of the plant ie. how many bites can be taken out of it 
		 * before the plant dies.  Default 5.*/
		public var maxHealth:int = 5;
		
		override public function Plant(pEmitter:FlxEmitter, X:Number=0, Y:Number=0, SimpleGraphic:Class=null)
		{
			super(X, Y, SimpleGraphic);
			emitter = pEmitter;
			
			if(X==0 || Y==0){
				this.x = Math.random()*(FlxG.width -80)+40;
				this.y = Math.random()*(FlxG.height-80)+40;
			} else if(X<0 || Y<0 || X>FlxG.width || Y>FlxG.height){
				this.kill()
			} else{
				this.x = X;
				this.y = Y;
			}
			
			
			
			this.health = 1;
			
			chooseSprite();
			
			var s:PlayState = FlxG.state as PlayState;
			var memberPos:FlxPoint = new FlxPoint;
			for each(var member:* in s.plants.members){
				if(member !=null && member.alive){
					memberPos.x = member.x;
					memberPos.y = member.y;
					if(distance(memberPos) < 50){
						this.kill();
						var p:Plant = new PlantSpeciesX(s.plantEmitter);
						s.plants.add(p);
						break;
					}
				}
			}
		}
		
		private function distance(f:FlxPoint):Number
		{
			var xd:Number = this.x - f.x;
			var yd:Number = this.y - f.y;
			return Math.sqrt(xd * xd + yd*yd);
		}
		
		override public function update():void
		{
			super.update();
			regrow();
			imgState();
		}
		
		private function chooseSprite():void
		{
			var rand:int = FlxG.random()*4+1;
			this.angle = FlxG.random()*360;
			switch (rand){
				case 1:
					loadGraphic(sprite1, false, false, 38, 32);
					break;	
				case 2:
					loadGraphic(sprite2, false, false, 32, 32);
					break;
				case 3:
					loadGraphic(sprite3, false, false, 32, 32);
					break;
				case 4:
					loadGraphic(sprite4, false, false, 32, 32);
					break;
				
				
			}
		}
		
		/**
		 * A method for when a creature attempts to take a bite out of the plant. The 
		 * plant dies if its health reaches 0;
		 * 
		 * @return return whether or not the creature succeded at eating the plant.
		 */
		
		public function eat():Boolean
		{
			this.health -= 1;
			emitter.x = this.getMidpoint().x;
			emitter.y = this.getMidpoint().y;
			
			emitter.start(true, 0, 0, 1);
			if(this.health <= 0)
			{
				this.kill();
				
			}
			return true;
			
		}
		
		/**
		 * A method that when called gives a random chance for the plant to regrow/heal. 
		 */
		
		public function regrow():void
		{
			
			if(Math.random() > growSpeed)
			{
				if(this.health >= maxHealth)
				{
					return;
				}
				this.health += 1;
			}
		}
		
		/**
		 *Sets the max health and growth speed of the plant. Only called in the constructor of subclasses.
		 */
		
		public function setStats(maxHealth:int, growSpeed:Number):void
		{
			this.maxHealth = maxHealth;
			this.growSpeed = growSpeed;
		}
		
		/**
		 * Changes the sprite of the object bassed on its health 
		 * compared to the maxHealth.
		 */
		
		private function imgState():void
		{
			frame = health/maxHealth*8;
			
			/*
			if(health < (maxHealth/2))
			{
				loadGraphic(low);
			}
			else if(health >= maxHealth)
			{
				loadGraphic(full);
			}
			else
			{
				loadGraphic(half);
			}*/
		}
	
	}
}