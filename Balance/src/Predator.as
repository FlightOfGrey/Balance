package
{
	import org.flixel.*;
	
	public class Predator extends FlxSprite
	{
		
		static private var food:FlxGroup;
		
		static private var perception:Number = 140;
		
		private var wanderTheta:Number = 0.1;
		static private var maxSpeed:Number = 200;
		static private var maxForce:Number = 0.1;    // Maximum steering force
		
		private var hunger:int = 0;
		public var hungerTimer:int = 0;
		private var maxHunger:int = 10;
		
		public var hungerTimerThreshold:Number = 100;
		
		private var matingTimer:int = 0;
		
		private var flowMaker:MouseStuff = MouseStuff.getMouseStuff();
		
		[Embed(source="assets/images/boid/pred.png")] public var img:Class;
		
		public function Predator(fd:FlxGroup, xPos:Number = -1, yPos:Number = -1)
		{
			super();
			
			velocity.x = -20;
			velocity.y = -20;
			
			food = fd;
			loadGraphic(img, false);
			if(yPos == -1){
				startAtEdge();
			} else{
				this.x = xPos;
				this.y = yPos;
			}
		}
		
		override public function update():void
		{
			super.update();
			speedLimiting();
			edgeBounce();
			
			wander();
			bloodFrenzy();
			doTheHunger();
			breedBabyBreed();
			rotateSprite();
			opacity();
			
		}
		
		private function startAtEdge():void
		{
			var xPos:Number = FlxG.random()*FlxG.width;
			var yPos:Number = FlxG.random()*FlxG.height;
			var wall1:Number = FlxG.random();
			var wall2:Number = FlxG.random();
			
			if (wall1 <= 0.5) {
				if (wall2 <= 0.5) {
					this.x = xPos;
					this.y = 0 - height;
				} else {
					this.x = 0 - height;
					this.y = yPos;			
				}
			} else {
				if (wall2 <= 0.5) {
					this.x = xPos;
					this.y = FlxG.height + height;			
				} else {
					this.x = FlxG.width + height;
					this.y = yPos;			
				}
			}
		}
		
		private function breedBabyBreed():void
		{
			var s:PlayState = FlxG.state as PlayState;
			if(s.predators.countLiving() > 1){
				
				var memberPos:FlxPoint = new FlxPoint;
				var nearest:Predator;
				var nearestDist:Number = 10000;
				var currentDist:Number;
				
				for each(var member:* in s.predators.members){
					if(member !=null && member.alive && member!= this){
						if(hunger <= maxHunger/3 && member.hunger <= member.maxHunger/3 && matingTimer > s.predators.countLiving()*300 && s.predators.countLiving() <= 4){
							
							memberPos.x = member.x;
							memberPos.y = member.y;
							
							currentDist = distance(memberPos);
							
							if(currentDist < nearestDist){
								nearest = member;
								nearestDist = currentDist;
							}
							
							
							if(distance(memberPos) < 30){
								var p:Predator = new Predator(s.testboids, this.x+1, this.y+1);
								s.predators.add(p);
								matingTimer = 0;
								member.matingTimer = 0;	
							}
						}
					}
				}
				
				if(nearestDist < perception)
					effector(memberPos, perception, maxSpeed/2);
			
			}
		}
		
		private function opacity():void
		{
			alpha = (maxHunger-hunger)/maxHunger+0.2;
		}
		
		public function eat():void{
			hunger = 0;
		}
		
		private function speedLimiting():void
		{
			maxSpeed = hunger/maxHunger*50+150;			
		}
		
		private function doTheHunger():void
		{
			hungerTimer++;
			matingTimer++;
			if(hungerTimer == hungerTimerThreshold)
			{
				hunger++;
				hungerTimer = 0;
				if(hunger == maxHunger)
				{
					this.kill();
				}
			}
		}
		
		private function bloodFrenzy():void
		{
			if(food.countLiving() > 0 && hunger > maxHunger/5) {
				var nearest:Boid;
				var boidLocation:FlxPoint = new FlxPoint();
				var nearestDist:Number = 10000;
				var currentDist:Number;
				for each(var member:* in food.members){
					if(member !=null && member.alive){
						boidLocation.x = member.x;
						boidLocation.y = member.y;
						
						currentDist = distance(boidLocation);
						
						if(currentDist < nearestDist){
							nearest = member;
							nearestDist = currentDist;
						}
					}
				}
				
				if(nearest !=null){
					boidLocation.x = nearest.x;
					boidLocation.y = nearest.y;
				}
				if(nearestDist < perception)
					effector(boidLocation, perception, maxSpeed);
			}
			
		}
		
		/**
		 * Affect boid velocity with an linear point force.
		 * @param  a aura of the effector (effect distance)
		 * @param  i intensity of the effector. > 0 for attraction, < 0 for repulsion
		 */
		private function effector(location:FlxPoint, a:Number, e:Number):void
		{
			var d:Number = distance(location);
			if(d < a)
			{
				var v:FlxPoint = new FlxPoint();
				if(x >= location.x) v.x += (a-d) * e * 0.01;
				else v.x -= (a-d) * e * 0.01;
				if(y >= location.y) v.y += (a-d) * e * 0.01;
				else v.y -= (a-d) * e * 0.01;
				velocity = sub(velocity, v);
			}
		}
		
		
		/**
		 * Randomly changes the direction based off a circle projected off in front of the predator,
		 * giving the wandering type movement.
		 */ 		
		private function wander():void
		{
			var wanderRadius:Number = 16; //radius of wander circle
			var wanderDist:Number = 60; //distance for wander circle
			var change:Number = -0.5;
			/*wanderTheta += randomRange(-change*hunger/maxHunger - 0.1, change*hunger/maxHunger + 0.1);*/ //randomly change the wander theta
			wanderTheta += randomRange(-change, change); //randomly change the wander theta
			
			var circleLocation:FlxPoint = new FlxPoint(velocity.x, velocity.y);
			circleLocation = normalize(circleLocation);
			circleLocation = mulNumb(circleLocation, wanderDist);
			circleLocation.x += x;
			circleLocation.y += y;
			
			var circleOffSet:FlxPoint = new FlxPoint(wanderRadius*Math.cos(wanderTheta), wanderRadius*Math.sin(wanderTheta));
			var target:FlxPoint = add(circleLocation, circleOffSet);	
			velocity = add(velocity, mulNumb(steer(target), 0.5));  // Steer towards it
		}
		
		/**
		 * Steers the predator towards a target FlxPoint with the urgency/importance based upon how far away the target is
		 */ 
		private function steer(target: FlxPoint):FlxPoint
		{
			var steer:FlxPoint;
			var desired:FlxPoint = sub(target, new FlxPoint(x, y));
			var d:Number = magnitude(desired);
			
			if(d > 0){
				desired = normalize(desired);
				if(d<100) desired = mulNumb(desired, (d/100*maxSpeed));
				else desired = mulNumb(desired, maxSpeed);
				steer = sub(desired, velocity);				
			}
			else
			{
				steer = new FlxPoint(0,0);
			}
			return steer;
		}
		
		/**
		 * Makes the boid bounce off the edge of the screen
		 */
		private function edgeBounce():void
		{			
			// When a boid approach a side, an opposite vector is added to velocity (bounce)
			var efficiency:Number = 1;
			// efficiency ~ 10 : boids immediately rejected
			// efficiency ~ .1  : boids slowly change direction
			var v:FlxPoint = new FlxPoint();
			
			if(this.getMidpoint().x <= perception/5*3 +5){ //leftside
				v.x = (perception/5*3 - x) * efficiency;
			}
			else if(this.getMidpoint().x >= FlxG.width - perception/5*3 -5){//rightside
				v.x = (FlxG.width - perception/5*3 - x) * efficiency;
			}
			if(this.getMidpoint().y <= perception/5*3 +5){//top
				v.y = (perception/5*3 -y) * efficiency;
			}
			else if(this.getMidpoint().y >= FlxG.height - perception/5*3 -5){//bottom
				v.y = (FlxG.height - perception/5*3 - y) * efficiency;
			}
			
			velocity = add(velocity, v);
		}
		
		/**
		 * Returns the magnitude of the FlxPoint
		 */ 
		private function magnitude(one:FlxPoint):Number{ return (Math.sqrt(one.x*one.x + one.y*one.y)); }
		
		/**
		 * Multiply and divide a FlxPoint by a scalar number
		 */ 
		private function divNumb(one:FlxPoint, two:Number):FlxPoint{ return new FlxPoint(one.x/two ,one.y/two); }		
		private function mulNumb(one:FlxPoint, two:Number):FlxPoint{ return new FlxPoint(one.x*two ,one.y*two); }
		
		/**
		 * Add and subtract two FlxPoints, returns the result
		 */
		private function sub(one:FlxPoint, two:FlxPoint):FlxPoint{ return new FlxPoint(one.x-two.x ,one.y-two.y); }
		private function add(one:FlxPoint, two:FlxPoint):FlxPoint{ return new FlxPoint(one.x+two.x ,one.y+two.y); }
		
		/**
		 * Returns the FlxPoint, normalized
		 */
		private function normalize(p:FlxPoint):FlxPoint
		{			
			const nf:Number = 1 / Math.sqrt(p.x * p.x + p.y * p.y);
			if(nf ==0 || nf ==Infinity)	return new FlxPoint;
			else return new FlxPoint((p.x * nf), (p.y * nf));
		}
		
		/**
		 * Roatates the sprite according to the velocity vector
		 */ 
		private function rotateSprite():void
		{
			this.angle = -Math.atan2(velocity.x, velocity.y) * 180/Math.PI +180;				
		}
		
		/**
		 * Returns a random number between the number range specified
		 */ 
		private function randomRange(min:Number, max:Number):Number
		{
			return Math.random() * (max - min) + min;
		}
		
		/**
		 * Distance from the current boids location to another specified FlxPoint
		 */
		private function distance(f:FlxPoint):Number
		{
			var xd:Number = this.x - f.x;
			var yd:Number = this.y - f.y;
			return Math.sqrt(xd * xd + yd*yd);
		}
	}
}