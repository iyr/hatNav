/*
 * hatNavPrototype
 * A sketch to demonstrate how a strip of LEDs can guide one's way
 * Most of the magic happens in the function "drawSimulatedLEDS()"
 */

int numLEDS          = 15; // Can be arbiturary, best with odd values
int numWaypoints     = 5;  // Number of waypoints
int crntWaypoint     = 0;  // Currently selected waypoint
float WaypointRadius = 50; // Size of waypoints
float userHeading    = 0;  // current heading user is facing

// Convenience Variables
color white          = color(255); 
color gray           = color(192);
color green          = color(0, 255, 0);
color purple         = color(128, 0, 255);
color yellow         = color(255, 255, 0);

// Array containing XY coordinates of waypoints
float[][] waypoints = new float[numWaypoints][2];

// Required function; code to be run once at startup
void setup() {
   size(1080, 1080); // Set window size
   background(gray); // Set background to gray
   noStroke();       // Use no outline around primitives

   // Randomly Generate some waypoints
   for (int i = 0; i < numWaypoints; i++) {
      waypoints[i][0] = random(100, width-100);
      waypoints[i][1] = random(100, height-100);
   }

   // Draw waypoints as purple dots
   drawWaypoints();
}

// Required function; code that runs continuously on every frame
void draw() {
   // Clear Screen
   background(gray);

   // Self-explanatory
   drawWaypoints();
  
   // Draw dot where mouse cursor is
   noStroke();
   fill(white);
   circle(mouseX, mouseY, 8);
      
   // Lines must have positive non-zero stroke to render
   strokeWeight(4);  // Set linethickness
      
   // Get angle between mouse position and next waypoint
   float direction = getAng(
      mouseX, 
      mouseY, 
      waypoints[crntWaypoint][0], 
      waypoints[crntWaypoint][1]);
         
   stroke(green);    // Set linecolor
   // Draw Vector (green line) located at mouse position, pointing to next waypoint
   line(mouseX, mouseY, mouseX + 40.0*cos(direction), mouseY + 40.0*sin(direction));

   stroke(yellow);    // Set linecolor
   // Draw Vector (yellow line) located at mouse posoition, pointing where user is facing
   line(
      mouseX, 
      mouseY, 
      mouseX + 40.0*cos(radians(userHeading)), 
      mouseY + 40.0*sin(radians(userHeading)));
          
   // When way point is reached, move to next waypoint
   if (watchPoint(waypoints[crntWaypoint][0], waypoints[crntWaypoint][1], WaypointRadius)) {
      println("Waypoint reached! Targetting next waypoint");
      crntWaypoint += 1;
         
      // Reset way point counter, loop through waypoints
      if (crntWaypoint >= numWaypoints) {
         crntWaypoint = 0;
      }
   }
   
   drawSimulatedLEDS(numLEDS);
   drawLegend();
}

// Returns true if mouse position falls within a circle of pr located at px, py
boolean watchPoint(float px, float py, float pr) {
   if (1.0 >= pow((mouseX - px), 2) / pow(pr/2, 2) + pow((mouseY - py), 2) / pow(pr/2, 2))
   {
      return true;
   } else {
      return false;
   }
}

// Display available inputs
void drawLegend(){
   textAlign(LEFT, BOTTOM);
   textSize(24);
   fill(0);
   text("Left / Right Arrow keys: Change Heading (click window first)", 10, 40);
}

// Draw all way points as purple dots
void drawWaypoints(){
   textAlign(CENTER, CENTER);
   textSize(32);
   noStroke();

   for (int i = 0; i < numWaypoints; i++) {     
      // Set color to purple
      fill(purple);
      circle(waypoints[i][0], waypoints[i][1], WaypointRadius);
      
      // Set color to white
      fill(white);
      text(i+1, waypoints[i][0], waypoints[i][1]);
   }
}

// Get angle between two points
float getAng(float px, float py, float qx, float qy) {
   float xDelta = qx-px;
   float yDelta = qy-py;
   return atan2(yDelta, xDelta);
}

void keyPressed() {
   if (key == CODED) {
      switch (keyCode) {
         case LEFT:  userHeading -= 15; break;
         case RIGHT: userHeading += 15; break;
      }
   }

   // Limit User heading to 0 - 360
   if (userHeading > 360)
      userHeading -= 360;
   if (userHeading < 0)
      userHeading += 360;
}

void drawSimulatedLEDS(int numLEDS) {
   for (int i = 0; i < numLEDS; i++) {
      float xPos = map(i, 0, numLEDS, width/10, width-width/20);
      noStroke();

      // Get angle between mouse position and next waypoint
      float direction = degrees(getAng(
         mouseX,                       // Substitutes GPS Coordinate
         mouseY,                       // Substitutes GPS Coordinate
         waypoints[crntWaypoint][0], 
         waypoints[crntWaypoint][1]));

      // Get difference betwen direction and heading of user, map to LED
      int deltaAng = int(abs(userHeading-direction+180));

      // keep deltaAng < 360
      if (deltaAng > 360)
         deltaAng -= 360;

      // Map Viewrange to LED index
      int LEDindex = int(map(deltaAng, 180-45, 180+45, numLEDS-1, 0));

      // Get distance to way point
      float distance = sqrt(  pow(mouseX-waypoints[crntWaypoint][0], 2) +
                              pow(mouseY-waypoints[crntWaypoint][1], 2));

      // The higher this number, the more LEDS light up as one approaches a waypoint
      int proximityFactor =  400;   
      
      // Brightness of LEDs are protional to distance and number of LEDS
      int grn = (int(proximityFactor/distance) - abs(LEDindex-i))*51;
      fill(0, grn, 0);

      // Ensure the LED most directly facing the way point is fully lit
      if (i == LEDindex)
         fill(0, 255, 0);

      // Draw "LED"
      circle(xPos, height-40, 40); 
   }
}
