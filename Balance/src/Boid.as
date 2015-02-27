/*
 * Base class that all flocking based AI extends with the basic flocking functionality
*/

package
{
	import org.flixel.*;	
	
	public final class Boid extends FlxSprite
	{
		//Group that the boid is part of
		static public var myGroup:FlxGroup;
		
		static private var emitter:FlxEmitter;
		
		static private var food:FlxGroup;
		static private var predators:FlxGroup;
		
		//The importance of each rule and how much each rule affects the overall
		//movement of each boid.
		static private var cRule:Number = 0.04; //cohesion
		static private var aRule:Number = 20; //avoidance
		static private var iRule:Number = 0.1; //immitation
		
		//Distance which boids respond to things withn it's environment,
		//anything further away is not accounted for.
		static private var perception:Number = 110;
		//Distance it likes to keep from other flockmates
		static private var personalSpace:Number = 40;
		
		public var hunger:int = 0;
		public var hungerTimer:int = 0;
		static private var maxHunger:int = 20;
		
		public var matingTimer:int = 0;
		
		private var mouseStuff:MouseStuff = MouseStuff.getMouseStuff();
		
		
		[Embed(source="assets/images/boid/1.png")] static private  var Img1:Class;
		[Embed(source="assets/images/boid/2.png")] static private  var Img2:Class;
		[Embed(source="assets/images/boid/3.png")] static private  var Img3:Class;
		[Embed(source="assets/images/boid/4.png")] static private  var Img4:Class;
		[Embed(source="assets/images/boid/5.png")] static private  var Img5:Class;
		[Embed(source="assets/images/boid/6.png")] static private  var Img6:Class;
		[Embed(source="assets/images/boid/7.png")] static private  var Img7:Class;
		[Embed(source="assets/images/boid/8.png")] static private  var Img8:Class;
		[Embed(source="assets/images/boid/9.png")] static private  var Img9:Class;
		
		public function Boid(mg:FlxGroup, prd:FlxGroup, fd:FlxGroup, pEmitter:FlxEmitter, xPos:Number = -1, yPos:Number = -1)
		{
			super();
			emitter = pEmitter;
			myGroup = mg;
			predators = prd;
			food = fd;
			maxVelocity = new FlxPoint(FlxG.random()*20+60, FlxG.random()*20+60);
			
			if(yPos == -1){
				this.x = FlxG.width / 2 + 10 * FlxG.random();
				this.y = FlxG.height / 2 + 10 * FlxG.random();
				this.velocity.x = 30 - FlxG.random() * 5;
				this.velocity.y = 30 - FlxG.random() * 5;
			} else{
				this.x = xPos;
				this.y = yPos;
				this.velocity.y = FlxG.random()*20+10;
				this.velocity.x = FlxG.random()*20+10;
			}
			

			
			
			loadRandomSprite();
		}
		
		override public function update():void{
			super.update();
			
			// Only flocks if a predator's not in its range
			// If a predator is in range it runs away from the predator
			if(!predInRange()){
				flock();
			}
			doTheHunger();
			foodingTime();
			
			edgeBounce();
			mouseSolve();
			rotateSprite();
			opacity();
		}
		
		private function opacity():void
		{
			alpha = (maxHunger-hunger)/maxHunger;
		}
		
		
		private function foodingTime():void
		{
			if(food.countLiving() > 0 && hunger > 0){
				var nearest:Plant;
				var plantLocation:FlxPoint = new FlxPoint();
				var nearestDist:Number = 10000;
				var currentDist:Number;
				for each(var member:* in food.members){
					if(member !=null && member.alive){
						plantLocation.x = member.x;
						plantLocation.y = member.y;
						
						currentDist = distance(plantLocation);
						
						if(currentDist < nearestDist){
							nearest = member;
							nearestDist = currentDist;
						}
					}
				}
				
				if(plantLocation != null && nearest != null){
					plantLocation.x = nearest.x;
					plantLocation.y = nearest.y;
					
					if(nearestDist < perception)
						effector(plantLocation, perception, 10);
				}
			}				
			
		}
		
		/**
		 * Affect boid velocity with an linear point force.
		 *
		 * @param  x x-coordinate of the effector
		 * @param  y y-coordinate of the effector
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
		 * 
		 */
		
		private function doTheHunger():void
		{
			hungerTimer++;
			if(hungerTimer == 150)
			{
				matingTimer++;
				hunger++;
				hungerTimer = 0;
				if(hunger == maxHunger)
				{
					this.kill();
				}
			}
		}
		
		public function eat():Boolean
		{
			if(hunger != 0){
				hunger = 0;
				return true;
			}
			return false;
		}
		
		public function eatenByPred():void
		{
			this.kill();
			
			emitter.x = x;
			emitter.y = y;
			
			emitter.start(true, 0, 0, 4);
		}
		
		/**
		 * Sees whether a predator is with in the boids perception range, if it is then move in the opposite 
		 * direction to the predator. Returns true if a predator is within the boids perception range, false otherwise.
		 */ 
		private function predInRange():Boolean{
			if(predators.countLiving() > 0){
				for each(var member:* in predators.members){
					if(member.alive){
						var dist:Number = distance(new FlxPoint(member.x, member.y));
						
						if(dist < perception){
							var v:FlxPoint = sub(new FlxPoint(x, y), new FlxPoint(member.x, member.y));
							v = mulNumb(v, 0.5);
							this.velocity = add(this.velocity, v);
							return true;
						}
					}
				}
			}
			return false;
		}
		
		/**
		 * Calculates and updates the boid's velcoity based upon the 3 flocking rules, cohesion, imitation and avoidance
		 */ 
		private function flock():void
		{
			var cohesionVector:FlxPoint = new FlxPoint();
			var imitationVector:FlxPoint = new FlxPoint();	
			var avoidanceVector:FlxPoint = new FlxPoint();	
			var nbr:Number = 0;
			
			for each(var member:* in myGroup.members){
				var memberPos:FlxPoint = new FlxPoint(member.x, member.y);
				
				if(member != this)
				{
					var dist:Number = distance(memberPos);
					if(dist < perception){					
						cohesionVector = add(cohesionVector, memberPos); //Calculating cohesion
						
						imitationVector = add(imitationVector, member.velocity); //Calculating imitation
						nbr++;
					}
					
					if(dist < personalSpace){
						breed(member);
						//Calculating avoidance
						var u:FlxPoint = sub(new FlxPoint(x, y), memberPos);
						u = normalize(u);
						u = divNumb(u, dist);
						avoidanceVector = add(avoidanceVector, u);
					}					
				}
			}
			if(nbr > 0)
			{
				//Adding cohesion vector
				cohesionVector = divNumb(cohesionVector, nbr); 
				cohesionVector = mulNumb(sub(cohesionVector, new FlxPoint(x, y)), cRule); 
				this.velocity = add(this.velocity, cohesionVector);
				
				//Adding imiation vector
				imitationVector = sub(divNumb(imitationVector, nbr), member.velocity); 
				imitationVector = mulNumb(imitationVector, iRule); 
				this.velocity = add(this.velocity, imitationVector); 
			}	
			//Adding avoidance vector
			avoidanceVector = mulNumb(avoidanceVector, aRule);
			this.velocity = add(this.velocity, avoidanceVector); 
		}
		
		/**
		 * Makes the boid bounce off the endge of the screen
		 */
		private function edgeBounce():void
		{			
			// When a boid approach a side, an opposite vector is added to velocity (bounce)
			var efficiency:Number = 0.4;
			// efficiency ~ 10 : boids immediately rejected
			// efficiency ~ .1  : boids slowly change direction
			var v:FlxPoint = new FlxPoint();
			if(this.getMidpoint().x <= perception/5*3 -5)       v.x = (perception/5*3 - x) * efficiency;
			else if(this.getMidpoint().x >= FlxG.width - perception/5*3 +5) v.x = (FlxG.width - perception/5*3 - x) * efficiency;
			if(this.getMidpoint().y <= perception/5*3 -5)       v.y = (perception/5*3 -y) * efficiency;
			else if(this.getMidpoint().y >= FlxG.height - perception/5*3 +5) v.y = (FlxG.height - perception/5*3 - y) * efficiency;
			velocity = add(velocity, v);
		}
		
		
		/**
		 * Roatates the sprite according to the velocity vector
		 */ 
		private function rotateSprite():void
		{
			this.angle = -Math.atan2(velocity.x, velocity.y) * 180/Math.PI +180;				
		}
		
		/**
		 * Randomly selects one of 4 sprites
		 */ 
		private function loadRandomSprite():void
		{
			var rand:int = FlxG.random()*9+1;
			switch (rand){
				case 1:
					loadGraphic(Img1, false);
					break;	
				case 2:
					loadGraphic(Img2, false);
					break;
				case 3:
					loadGraphic(Img3, false);
					break;
				case 4:
					loadGraphic(Img4, false);
					break;
				case 5:
					loadGraphic(Img5, false);
					break;
				case 6:
					loadGraphic(Img6, false);
					break;
				case 7:
					loadGraphic(Img7, false);
					break;
				case 8:
					loadGraphic(Img8, false);
					break;
				case 9:
					loadGraphic(Img9, false);
					break;
							
			}
		}
		
		
		/**
		 * 
		 */
		private function breed(partner:Boid):void
		{
			if(matingTimer > myGroup.countLiving()/10){
				if(hunger == 0 && partner.hunger == 0)
				{
					var b:Boid = new Boid(myGroup, predators, food, emitter,  this.x+1, this.y+1);
					myGroup.add(b);
					matingTimer = 0;
					partner.matingTimer = 0;	
				}
			}
		}
		
		//*************************************************
		//Helper methods for dealing with FlxPoints/Vectors
		//*************************************************
		
		/**
		 * Distance from the current boids location to another specified FlxPoint
		 */
		private function distance(f:FlxPoint):Number
		{
			var xd:Number = this.x - f.x;
			var yd:Number = this.y - f.y;
			return Math.sqrt(xd * xd + yd*yd);
		}
		
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
	
	
		private function mouseSolve():void
		{
			if(FlxG.mouse.pressed()){
				var dist:Number = distance(mouseStuff.getMidpoint());
				if(dist < 100){
					velocity.x += mouseStuff.getVelX()*20;
					velocity.y += mouseStuff.getVelY()*20;
				}
			}
		}
	}
}