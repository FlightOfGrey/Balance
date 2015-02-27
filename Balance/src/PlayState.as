package
{
	import flash.events.OutputProgressEvent;
	
	import org.flixel.*;
	
	//Main game state, used to intitialise all game objects and 
	//perform things like check collisions etc
	
	public class PlayState extends FlxState
	{
		
		public var testboids:FlxGroup = new FlxGroup(); //Base AI group
		public var predators:FlxGroup = new FlxGroup();
		public var plants:FlxGroup = new FlxGroup();
		private var bg:Backdrop = new Backdrop();
		private var intro:IntroPic = new IntroPic();
		private var outro:OutroPic = new OutroPic();
		private var start:StartPic = new StartPic();
		
		private var mouseStuff:MouseStuff = MouseStuff.getMouseStuff();
		
		private var oldMouseX:int = 1;
		private var oldMouseY:int = 1;
		
		public var particleEmitter:FlxEmitter;
		public var plantEmitter:FlxEmitter;
		
		private var framesFromStart:int = 0;
		private var fading:Boolean = false;
		private var title:Boolean = true;
		private var endGame:Boolean = false;
		private var predAreReset:Boolean = false;
		private var gameStart:Boolean = true;
		
		[Embed(source="assets/sounds/Gymnopedie No 1.mp3")] static private  var bgMusic1:Class;
		/**
		 *  Used to initialises all game assets and entities
		*/
		override public function create(): void
		{
			var music:FlxSound = new FlxSound();
			music.loadEmbedded(bgMusic1, true);
			music.play();
			
			initParticleEmitter();
			initPlantEmitter();
			
			add(new Backdrop()); //HAVE TO ADD NEW SPECIES/PLANTS AFTER THE BACKDROP
								 //OTHERWISE BACKDROP GETS DRAWN OVER TOP
			
			add(plants);
			add(predators);
			add(testboids);
			add(particleEmitter);
			add(plantEmitter);
			add(intro);
			add(outro);
			add(start);
			add(mouseStuff);
			initialisePlaystate();
		}
		
		private function initialisePlaystate():void
		{
			if(!gameStart){
			outro.alpha = 1;
			}else{
			outro.alpha = 0;
			}
			for each(var member:* in plants.members){
				if(member !=null && member.alive){
					member.kill();
				}
			}
			
			spawnFlock(6)
			spawnPlants(8);
			intro.alpha = 1;
			fading = false;
			title = true;
			framesFromStart = 0;
			endGame = false;
			predAreReset = false;
		}
		
		private function spawnPreds(number:Number):void
		{
			for(var i:Number = 0; i < number; i++){
				predators.add(new Predator(testboids));
			}
		}
		
		/**
		 * Creates a flock of @number boids and adds them to the scene
		 */ 
		public function spawnFlock(number:Number):void
		{
			for(var i:Number = 0; i < number; i++){
				var b:Boid = new Boid(testboids, predators, plants, particleEmitter);
				testboids.add(b);
			}
		}
		
		/**
		 * Creates the plants
		 */
		
		private function spawnPlants(number:int):void
		{
			
			for(var i:int = 0; i < number; i++)
			{
				var p:Plant = new PlantSpeciesX(plantEmitter);
				plants.add(p);
			}
		}
		
		/**
		 * The main game loop function 
		*/
		override public function update():void
		{
			//Updates everything added to this state by calling each objects update method
			super.update();
			FlxG.overlap(plants, testboids, collisions);
			FlxG.overlap(predators, testboids, collision);
			
			cheats();
			
			++framesFromStart;
			if(((framesFromStart > 150  && FlxG.mouse.pressed()) || fading) && title)
			{
				intro.alpha -= 0.01;
				if(!fading)fading = true;
				if(intro.alpha < 0.02){
					title = false;
				}
			}
			if(framesFromStart == 900)
			{
				spawnPreds(2);
			}
			if(!endGame && framesFromStart > 30)
			{
				if(!gameStart){outro.alpha -= 0.01;}
				else{start.alpha -= 0.01;}
			}
			gameWipe();
		}
		
		private function cheats():void
		{
			if(FlxG.keys.O){
				if(testboids.countLiving() >0){
					testboids.getFirstAlive().kill();
				}
			}
			
			if(FlxG.keys.P){
				testboids.add(new Boid(testboids, predators, plants, particleEmitter, FlxG.mouse.screenX, FlxG.mouse.screenY));
			}
			
			if(FlxG.keys.U){
				if(predators.countLiving() >0){
					predators.getFirstAlive().kill();
				}
			}
			
			if(FlxG.keys.I){
				predators.add(new Predator(testboids, FlxG.mouse.screenX, FlxG.mouse.screenY));
			}
			
			if(FlxG.keys.T){
				if(plants.countLiving() >0){
					plants.getFirstAlive().kill();
				}
			}
			
			if(FlxG.keys.Y){
				plants.add(new PlantSpeciesX(plantEmitter, FlxG.mouse.screenX, FlxG.mouse.screenY));
			}
		}
		
		private function gameWipe():void
		{
			if(testboids.countLiving() == 0){
				if(predators.countLiving() == 0){
					endGame = true;
					gameStart = false;
					outro.alpha += 0.01;
					if(outro.alpha >=1){
						initialisePlaystate();
					}
				} else {
					if(!predAreReset){
						for each(var member:* in predators.members){
							if(member !=null && member.alive){
								member.hungerTimerThreshold = 5;
								member.hungerTimer = 0;
							}
						}
						predAreReset = true;
					}
				}
			}
		}
		
		private function initParticleEmitter():void
		{
			//	Particle emitter - maximum pool size of 40
			particleEmitter = new FlxEmitter(0, 0, 40);
			particleEmitter.setRotation(-360, 360);
			particleEmitter.setXSpeed(-50, 50);
			particleEmitter.setYSpeed(-50, 50);
			
			//	This loop creates each particle
			for (var i:int = 0; i <particleEmitter.maxSize; i++)
			{
				particleEmitter.add(new FadingParticle(true));
			}
		}
		
		private function initPlantEmitter():void
		{
			//	Particle emitter - maximum pool size of 2s0
			plantEmitter = new FlxEmitter(0, 0, 20);
			plantEmitter.setRotation(-360, 360);
			plantEmitter.setXSpeed(-50, 50);
			plantEmitter.setYSpeed(-50, 50);
			
			//	This loop creates each particle
			for (var i:int = 0; i <plantEmitter.maxSize; i++)
			{
				plantEmitter.add(new FadingParticle(false));
			}
		}
		
		private function collision(pred:Predator, boid:Boid):void
		{
			boid.eatenByPred();
			pred.eat();
		}
		/**
		 * 
		 */
		
		private function collisions(plant:Plant, boid:Boid):void
		{
			if(boid.eat())
			{
			plant.eat();
			}
		}
	}
}