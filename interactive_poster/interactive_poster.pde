//Press 'Y' key to generate the second part of the image
//Press left mouse button to generate the text again on the first part
//Push button sensor to generate the second page instead of the 'y' key

//Ashley
PImage W1;
PImage W2;
PImage W3;
PImage W4;
PFont font1;

//Amy
// Global variables
ArrayList<Particle> particles = new ArrayList<Particle>();
int pixelSteps = 9; // Amount of pixels to skip
boolean drawAsPoints = false;
ArrayList<String> words = new ArrayList<String>();
int wordIndex = 0;
color bgColor = color(190, 147, 212); //light violet
String fontName = "Play-Regular-48.vlw";

class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0); 
  float closeEnoughTarget = 50;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float particleSize = 5;
  boolean isKilled = false;

  color startColor = color(0); //black
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;

  void move() {
    // Check if particle is close enough to its target to slow down
    float proximityMult = 1.0;
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < this.closeEnoughTarget) {
      proximityMult = distance/this.closeEnoughTarget;
    }

    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);

    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    steer.normalize();
    steer.mult(this.maxForce);
    this.acc.add(steer);

    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  void draw() {
    // Draw particle
    color currentColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
    if (drawAsPoints) {
      stroke(currentColor);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(currentColor);
      ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
    }

    // Blend towards its target color
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }

  void kill() {
    if (! this.isKilled) {
      // Set its target outside the scene
      PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
      this.target.x = randomPos.x;
      this.target.y = randomPos.y;

      // Begin blending its color to black
      this.startColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;

      this.isKilled = true;
    }
  }
}


// Picks a random position from a point's radius
PVector generateRandomPos(int x, int y, float mag) {
  PVector randomDir = new PVector(random(0, width), random(0, height));
  
  PVector pos = new PVector(x, y);
  pos.sub(randomDir);
  pos.normalize();
  pos.mult(mag);
  pos.add(x, y);
  
  return pos;
}


// Makes all particles draw the next word
void nextWord(String word) {
  // Draw word in memory
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(90);
  pg.textAlign(CENTER);
  PFont font = createFont(fontName, 90);
  pg.textFont(font);
  pg.text(word, width/2, 200);
  pg.endDraw();
  pg.loadPixels();

  // Next color for all pixels to change to
  color newColor = color(random(150.0, 255.0), 0.0, random(100.0, 150.0)); // range from medium to dark pinks and purples

  int particleCount = particles.size();
  int particleIndex = 0;

  // Collect coordinates as indexes into an array
  // This is so we can randomly pick them to get a more fluid motion
  ArrayList<Integer> coordsIndexes = new ArrayList<Integer>();
  for (int i = 0; i < (width*height)-1; i+= pixelSteps) {
    coordsIndexes.add(i);
  }

  for (int i = 0; i < coordsIndexes.size (); i++) {
    // Pick a random coordinate
    int randomIndex = (int)random(0, coordsIndexes.size());
    int coordIndex = coordsIndexes.get(randomIndex);
    coordsIndexes.remove(randomIndex);
    
    // Only continue if the pixel is not blank
    if (pg.pixels[coordIndex] != 0) {
      // Convert index to its coordinates
      int x = coordIndex % width;
      int y = coordIndex / width;

      Particle newParticle;

      if (particleIndex < particleCount) {
        // Use a particle that's already on the screen 
        newParticle = particles.get(particleIndex);
        newParticle.isKilled = false;
        particleIndex += 1;
      } else {
        // Create a new particle
        newParticle = new Particle();
        
        PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
        newParticle.pos.x = randomPos.x;
        newParticle.pos.y = randomPos.y;
        
        newParticle.maxSpeed = random(6.0, 8.0);
        newParticle.maxForce = newParticle.maxSpeed*0.025;
        newParticle.particleSize = random(5, 8);
        newParticle.colorBlendRate = random(0.01, 0.05);
        
        particles.add(newParticle);
      }
      
      // Blend it from its current color
      newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = newColor;
      newParticle.colorWeight = 0;
      
      // Assign the particle's new target to seek
      newParticle.target.x = x;
      newParticle.target.y = y;
    }
  }

  // Kill off any left over particles
  if (particleIndex < particleCount) {
    for (int i = particleIndex; i < particleCount; i++) {
      Particle particle = particles.get(i);
      particle.kill();
    }
  }
}


void setup(){
  //Ashley
  size(792,1000);
  background(#BE93D4); //light violet
  
  W1 = loadImage("W1.jpg");
  W2 = loadImage("W2.jpg");
  W3 = loadImage("W3.jpg");
  W4 = loadImage("W4.jpg");
  font1 = loadFont("Arial-BoldMT-48.vlw");
  
  //Amy
  words.add("Women's Month");

  nextWord(words.get(wordIndex));
  
}


void draw(){
  //Ashley
  if (key == 'y'){
    background(#BE93D4); //light violet
    
    image(W1,0,0,width/2, height/2);
    image(W2,396,0,width/2,height/2);
    image(W3,0,500,width/2,height/2);
    image(W4,396,500,width/2,height/2);
  
    textFont(font1,50);
    fill(255); // white
    text("WE",15,60);
    text("RUN",415,60);
    text("THE",15,560);
    text("WORLD",415,560);
   } else {
     
    //Amy
    // Background & motion blur
    fill(bgColor);
    noStroke();
    rect(0, 0, width*2, height*2);

    for (int x = particles.size ()-1; x > -1; x--) {
      // Simulate and draw pixels
      Particle particle = particles.get(x);
      particle.move();
      particle.draw();

      // Remove any dead pixels out of bounds
      if (particle.isKilled) {
        if (particle.pos.x < 0 || particle.pos.x > width || particle.pos.y < 0 || particle.pos.y > height) {
          particles.remove(particle);
        }
      }
    }
  
  //Gabrielle
  
  //frame
  fill(#9867C5); //light neon purple
  noStroke();
  circle(396,730,730);
  
  //hair_back
  fill(#E56717); //papaya orange
  ellipse(370,600,250,300);
  ellipse(430,600,250,300);
  rect(245,590,310,350);
  
  //left_shoulder
  fill(#FFDBAC); //light orange
  quad(307,880,305,1000,270,1000,270,910);
  quad(270,910,240,920,240,1000,270,1000);
  circle(245,1000,160);
  fill(#F1C27D);
  circle(555,1000,160);
  
  //neck
  fill(#FFDBAC);
  quad(310,800,490,800,500,1000,300,1000);
  fill(#F1C27D);
  quad(310,800,490,800,499,1000,306,880);
  
  //right_shoulder
  fill(#F1C27D); //sunset
  quad(487,880,498,1000,530,1000,525,910);
  quad(524,910,529,1000,555,1000,555,920);
  
  
  //forehead
  fill(#FFDBAC);
  ellipse(400,600,260,190);
  
  //face
  fill(#FFDBAC);
  rect(270,600,260,160);
  quad(270,760,530,760,430,870,370,870);
  
  //hair_front_1
  fill(#E56717);
  quad(290,500,400,480,420,520,245,680);
  
  //hair_front_2
  fill(#E56717);
  quad(400,480,520,500,550,680,380,520);
  
  //eyebrow_1
  fill(#CC6600); //alloy orange
  ellipse(360,640,30,15);
  rect(300,632,60,16);
  triangle(300,632,300,648,272,660);
  
  //eyebrow_2
  ellipse(430,640,30,15);
  rect(430,632,65,16);
  triangle(495,632,495,648,525,662);
  
  //ear_1
  fill(#FFDBAC);
  circle(260,680,25);
  quad(248,680,285,680,285,740,259,740);
  circle(267,740,15);
  
  //ear_2
  circle(540,680,25);
  quad(520,680,553,680,542,740,519,740);
  circle(534,740,15);
  
  //eye_1
  fill(#CC6600);
  ellipse(335,680,65,33);
  fill(230);
  ellipse(335,683,60,28);
  fill(#0020C2); //medium blue 
  ellipse(335,683,30,30);
  
  //eye_2
  fill(#CC6600);
  ellipse(460,680,65,33);
  fill(230);
  ellipse(460,683,60,28);
  fill(#0020C2);
  ellipse(460,683,30,30);
  
  //nose
  fill(#F1C27D);
  noStroke();
  triangle(400,735,420,755,380,755);
  
  //lip_lower
  fill(#FE7F9C); //light pink
  ellipse(400,800,70,35);
  fill(#FFDBAC);
  rect(360,770,80,30);
  
  //lip_upper
  fill(#FE7F9C);
  ellipse(390,800,50,25);
  ellipse(410,800,50,25);
  
  //mouth
  stroke(0);
  strokeWeight(1.5);
  line(365,800,434,800);
 }
}

//Amy 

// Show next word
void mousePressed() {
  if (mouseButton == LEFT) {
    wordIndex += 1;
    if (wordIndex > words.size()-1) { 
      wordIndex = 0;
    }
    nextWord(words.get(wordIndex));
  }
}



// Kill pixels that are in range
void mouseDragged() {
  if (mouseButton == RIGHT) {
    for (Particle particle : particles) {
      if (dist(particle.pos.x, particle.pos.y, mouseX, mouseY) < 50) {
        particle.kill();
      }
    }
  }
}


// Toggle draw modes
void keyPressed() {
  drawAsPoints = (! drawAsPoints);
  if (drawAsPoints) {
    background(0);
    bgColor = color(0, 40);
  } else {
    background(255);
    bgColor = color(255, 100);
  }
}

/*
import processing.io.*;
//import gpio hardware input/output library

//Ashley
PImage W1;
PImage W2;
PImage W3;
PImage W4;
PFont font1;

//Amy
// Global variables
ArrayList<Particle> particles = new ArrayList<Particle>();
int pixelSteps = 9; // Amount of pixels to skip
boolean drawAsPoints = false;
ArrayList<String> words = new ArrayList<String>();
int wordIndex = 0;
color bgColor = color(190, 147, 212);
String fontName = "Play-Regular-48.vlw";

class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0); 
  float closeEnoughTarget = 50;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float particleSize = 5;
  boolean isKilled = false;

  color startColor = color(0); //black
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;

  void move() {
    // Check if particle is close enough to its target to slow down
    float proximityMult = 1.0;
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < this.closeEnoughTarget) {
      proximityMult = distance/this.closeEnoughTarget;
    }

    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);

    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    steer.normalize();
    steer.mult(this.maxForce);
    this.acc.add(steer);

    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  void draw() {
    // Draw particle
    color currentColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
    if (drawAsPoints) {
      stroke(currentColor);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(currentColor);
      ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
    }

    // Blend towards its target color
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }

  void kill() {
    if (! this.isKilled) {
      // Set its target outside the scene
      PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
      this.target.x = randomPos.x;
      this.target.y = randomPos.y;

      // Begin blending its color to black
      this.startColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;

      this.isKilled = true;
    }
  }
}


// Picks a random position from a point's radius
PVector generateRandomPos(int x, int y, float mag) {
  PVector randomDir = new PVector(random(0, width), random(0, height));
  
  PVector pos = new PVector(x, y);
  pos.sub(randomDir);
  pos.normalize();
  pos.mult(mag);
  pos.add(x, y);
  
  return pos;
}


// Makes all particles draw the next word
void nextWord(String word) {
  // Draw word in memory
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(90);
  pg.textAlign(CENTER);
  PFont font = createFont(fontName, 90);
  pg.textFont(font);
  pg.text(word, width/2, 200);
  pg.endDraw();
  pg.loadPixels();

  // Next color for all pixels to change to
  color newColor = color(random(150.0, 255.0), 0.0, random(100.0, 150.0)); // range from medium to dark pinks and purples

  int particleCount = particles.size();
  int particleIndex = 0;

  // Collect coordinates as indexes into an array
  // This is so we can randomly pick them to get a more fluid motion
  ArrayList<Integer> coordsIndexes = new ArrayList<Integer>();
  for (int i = 0; i < (width*height)-1; i+= pixelSteps) {
    coordsIndexes.add(i);
  }

  for (int i = 0; i < coordsIndexes.size (); i++) {
    // Pick a random coordinate
    int randomIndex = (int)random(0, coordsIndexes.size());
    int coordIndex = coordsIndexes.get(randomIndex);
    coordsIndexes.remove(randomIndex);
    
    // Only continue if the pixel is not blank
    if (pg.pixels[coordIndex] != 0) {
      // Convert index to its coordinates
      int x = coordIndex % width;
      int y = coordIndex / width;

      Particle newParticle;

      if (particleIndex < particleCount) {
        // Use a particle that's already on the screen 
        newParticle = particles.get(particleIndex);
        newParticle.isKilled = false;
        particleIndex += 1;
      } else {
        // Create a new particle
        newParticle = new Particle();
        
        PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
        newParticle.pos.x = randomPos.x;
        newParticle.pos.y = randomPos.y;
        
        newParticle.maxSpeed = random(6.0, 8.0);
        newParticle.maxForce = newParticle.maxSpeed*0.025;
        newParticle.particleSize = random(5, 8);
        newParticle.colorBlendRate = random(0.01, 0.05);
        
        particles.add(newParticle);
      }
      
      // Blend it from its current color
      newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = newColor;
      newParticle.colorWeight = 0;
      
      // Assign the particle's new target to seek
      newParticle.target.x = x;
      newParticle.target.y = y;
    }
  }

  // Kill off any left over particles
  if (particleIndex < particleCount) {
    for (int i = particleIndex; i < particleCount; i++) {
      Particle particle = particles.get(i);
      particle.kill();
    }
  }
}


void setup(){
  //Ashley
  size(792,1000);
  background(#BE93D4); //light violet
  
  W1 = loadImage("W1.jpg");
  W2 = loadImage("W2.jpg");
  W3 = loadImage("W3.jpg");
  W4 = loadImage("W4.jpg");
  font1 = loadFont("Arial-BoldMT-48.vlw");
  
  //Amy
  words.add("Women's Month");

  nextWord(words.get(wordIndex));
  
  // set GPIO pin 10 as input for push button
  GPIO.pinMode(10, GPIO.INPUT);
  
}


void draw(){
  //Ashley
  // button is pressed, pin is low
  if (GPIO.digitalRead(10) == GPIO.LOW){
    background(#BE93D4); //light violet
    
    image(W1,0,0,width/2, height/2);
    image(W2,396,0,width/2,height/2);
    image(W3,0,500,width/2,height/2);
    image(W4,396,500,width/2,height/2);
  
    textFont(font1,50);
    fill(255); // white
    text("WE",15,60);
    text("RUN",415,60);
    text("THE",15,560);
    text("WORLD",415,560);
   } 
   
  // button is not pressed, pin is high
  if (GPIO.digitalRead(10) == GPIO.HIGH){
     
    //Amy
    // Background & motion blur
    fill(bgColor);
    noStroke();
    rect(0, 0, width*2, height*2);

    for (int x = particles.size ()-1; x > -1; x--) {
      // Simulate and draw pixels
      Particle particle = particles.get(x);
      particle.move();
      particle.draw();

      // Remove any dead pixels out of bounds
      if (particle.isKilled) {
        if (particle.pos.x < 0 || particle.pos.x > width || particle.pos.y < 0 || particle.pos.y > height) {
          particles.remove(particle);
        }
      }
    }
  
  //Gabrielle
  
  //frame
  fill(#9867C5); //light neon purple
  noStroke();
  circle(396,730,730);
  
  //hair_back
  fill(#E56717); //papaya orange
  ellipse(370,600,250,300);
  ellipse(430,600,250,300);
  rect(245,590,310,350);
  
  //left_shoulder
  fill(#FFDBAC); //light orange
  quad(307,880,305,1000,270,1000,270,910);
  quad(270,910,240,920,240,1000,270,1000);
  circle(245,1000,160);
  fill(#F1C27D);
  circle(555,1000,160);
  
  //neck
  fill(#FFDBAC);
  quad(310,800,490,800,500,1000,300,1000);
  fill(#F1C27D);
  quad(310,800,490,800,499,1000,306,880);
  
  //right_shoulder
  fill(#F1C27D); //sunset
  quad(487,880,498,1000,530,1000,525,910);
  quad(524,910,529,1000,555,1000,555,920);
  
  
  //forehead
  fill(#FFDBAC);
  ellipse(400,600,260,190);
  
  //face
  fill(#FFDBAC);
  rect(270,600,260,160);
  quad(270,760,530,760,430,870,370,870);
  
  //hair_front_1
  fill(#E56717);
  quad(290,500,400,480,420,520,245,680);
  
  //hair_front_2
  fill(#E56717);
  quad(400,480,520,500,550,680,380,520);
  
  //eyebrow_1
  fill(#CC6600); //alloy orange
  ellipse(360,640,30,15);
  rect(300,632,60,16);
  triangle(300,632,300,648,272,660);
  
  //eyebrow_2
  ellipse(430,640,30,15);
  rect(430,632,65,16);
  triangle(495,632,495,648,525,662);
  
  //ear_1
  fill(#FFDBAC);
  circle(260,680,25);
  quad(248,680,285,680,285,740,259,740);
  circle(267,740,15);
  
  //ear_2
  circle(540,680,25);
  quad(520,680,553,680,542,740,519,740);
  circle(534,740,15);
  
  //eye_1
  fill(#CC6600);
  ellipse(335,680,65,33);
  fill(230);
  ellipse(335,683,60,28);
  fill(#0020C2);
  ellipse(335,683,30,30);
  
  //eye_2
  fill(#CC6600);
  ellipse(460,680,65,33);
  fill(230);
  ellipse(460,683,60,28);
  fill(#0020C2); //medium blue
  ellipse(460,683,30,30);
  
  //nose
  fill(#F1C27D);
  noStroke();
  triangle(400,735,420,755,380,755);
  
  //lip_lower
  fill(#FE7F9C); //light pink
  ellipse(400,800,70,35);
  fill(#FFDBAC);
  rect(360,770,80,30);
  
  //lip_upper
  fill(#FE7F9C);
  ellipse(390,800,50,25);
  ellipse(410,800,50,25);
  
  //mouth
  stroke(0);
  strokeWeight(1.5);
  line(365,800,434,800);
 }
}

//Amy 

// Show next word
void mousePressed() {
  if (mouseButton == LEFT) {
    wordIndex += 1;
    if (wordIndex > words.size()-1) { 
      wordIndex = 0;
    }
    nextWord(words.get(wordIndex));
  }
}



// Kill pixels that are in range
void mouseDragged() {
  if (mouseButton == RIGHT) {
    for (Particle particle : particles) {
      if (dist(particle.pos.x, particle.pos.y, mouseX, mouseY) < 50) {
        particle.kill();
      }
    }
  }
}


// Toggle draw modes
void keyPressed() {
  drawAsPoints = (! drawAsPoints);
  if (drawAsPoints) {
    background(0);
    bgColor = color(0, 40);
  } else {
    background(255);
    bgColor = color(255, 100);
  }
}

*/
