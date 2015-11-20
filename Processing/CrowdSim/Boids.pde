Flock flock;
ArrayList<Obstacle> Obstacles;

void setup() {
  size(640, 360);
  flock = new Flock();
  Obstacles = new ArrayList<Obstacle>();
  // Add an initial set of boids into the system
  for (int i = 0; i < 50; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
  for (int i = 0; i < 10; i++) {
    Obstacles.add(new Obstacle()); 
  }
}

void draw() {
  background(50);
  flock.run();
  for (Obstacle o : Obstacles) {
  o.run();
  }
  
}

// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(mouseX,mouseY));
}



// The Flock (a list of Boid objects)

class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}

class Obstacle {
   PVector location;
   float r;
  
   Obstacle() {
     location = new PVector(random(640), random(360));
     r = random(20);
   }
     
   void run() {
   fill(0x888888);
   stroke(255);
   pushMatrix();
   translate(location.x, location.y);
   ellipse(0, 0, r, r);
   popMatrix();
   }
}

// The Boid class

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  //ahead and ahead2 are used for simplified collision detection
  //http://gamedevelopment.tutsplus.com/tutorials/understanding-steering-behaviors-collision-avoidance--gamedev-7777
  PVector ahead;
  PVector ahead2;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float MAX_SEE_AHEAD = 1;
  float MAX_AVOID_FORCE = .1;

    Boid(float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    location = new PVector(x, y);
    r = 2.0;
    maxspeed = 2;
    maxforce = 0.03;
  }

  private PVector collisionAvoidance(){
    ahead = location.add(velocity.normalize().mult(MAX_SEE_AHEAD));
    ahead2 = location.add(velocity.normalize().mult(MAX_SEE_AHEAD*2)); // calculate the ahead2 vector
 
    Obstacle mostThreatening = findMostThreateningObstacle();
    PVector avoidance = new PVector(0, 0, 0);
 
    if (mostThreatening != null) {
        avoidance.x = ahead.x - mostThreatening.location.x;
        avoidance.y = ahead.y - mostThreatening.location.y;
 
        avoidance.normalize();
        avoidance.mult(MAX_AVOID_FORCE);
    } else {
        avoidance.mult(0); // nullify the avoidance force
    }
 
    return avoidance;
}
 
private Obstacle findMostThreateningObstacle() {
    Obstacle mostThreatening= null;
 
    for (int i = 0; i < Obstacles.size(); i++) {
        Obstacle obstacle = Obstacles.get(i);
        Boolean collision = (obstacle.location.sub(ahead).mag() <= obstacle.r) || (obstacle.location.sub(ahead2).mag() <= obstacle.r);
 
        // "position" is the character's current position
        if (collision && (mostThreatening == null || location.sub(obstacle.location).mag() < location.sub(mostThreatening.location).mag())) {
            mostThreatening = obstacle;
        }
    }
    return mostThreatening;
}

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    //applyForce(collisionAvoidance());
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(location.x, location.y);
    ellipse(0, 0, r, r);
    popMatrix();
  }

  void borders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } 
    else {
      return new PVector(0, 0);
    }
  }
}