import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import processing.sound.*;

//when in doubt, consult the Processsing reference: https://processing.org/reference/

////////////////////////////////////////////////////////////////
// HEY TEAM PLEASE EDIT THESE!
////////////////////////////////////////////////////////////////

int id = 517; // your custom ID
String dataFile = "results.txt"; // the file that results will be stored in
int numRepeats = 20; //sets the number of times each button repeats in the test

////////////////////////////////////////////////////////////////

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
boolean onTarget = false;
int lastTargetButton = -1;
Robot robot; //initalized in setup
SoundFile clicked;
SoundFile missed;
PrintWriter output;

// For printing data to .txt
int preTrialXPos = -1;
int preTrialYPos = -1;
int lastButtonClickedTime = 0;


// Array of all click regions for buttons
Rectangle[] buttonClickRegions = new Rectangle[16];

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  cursor(CROSS);
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects
  
  clicked = new SoundFile(this, "coin.wav");
  missed = new SoundFile(this, "fail.wav");

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
  
  // Calculate click regions
  for (int i = 0; i < 16; i++)
  {
     Rectangle bounds = getButtonLocation(i);
     
     int clickX = bounds.x - (padding / 2);
     int clickY = bounds.y - (padding / 2);
     int clickSize = bounds.height + padding;
     
     buttonClickRegions[i] = new Rectangle(clickX, clickY, clickSize, clickSize);
  }
  
  output = createWriter(dataFile);
}

void draw()
{
  background(0); //set background to black

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    
    output.flush();
    output.close();
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on

  boolean onTarget = false;
  for (int i = 0; i < 16; i++)// for all button
  {
    boolean withHighlight = false;
    
    // Check if we should draw the selection outline
    Rectangle bounds = buttonClickRegions[i];
    if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height))
    {
      withHighlight = true;
      if (i == trials.get(trialNum))
      {
        onTarget = true;
        stroke(23, 36, 133);
      }
      else
        stroke(150, 150, 150);
     
      strokeWeight(10);
    }
    else
    {
      strokeWeight(0);
    }
    
    drawButton(i, withHighlight); //draw button
  }
  
  int x1 = GetButtonCenterX(trials.get(trialNum));
  int y1 = GetButtonCenterY(trials.get(trialNum));
    
  strokeWeight(8);
  stroke(0, 0, 255, 200);
  line(mouseX, mouseY, x1, y1);

  strokeWeight(0); // disable stroke from buttons
  if (!onTarget)
  {
    fill(255, 0, 0, 200); // set fill color to translucent red
  }
  else
  {
    fill(0, 255, 0, 200); 
  }
  ellipse(mouseX, mouseY, 40, 40); //draw user cursor as a circle with a diameter of 20
}


void onButtonPushed()
{
    if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }
  
  Rectangle bounds = buttonClickRegions[trials.get(trialNum)];
   int minX = margin;
   int minY = margin;
   int maxX = 3 * (padding + buttonSize) + margin + buttonSize;
   int maxY = 4 * (padding + buttonSize) + margin - buttonSize;   
   if (mouseX < minX) {
     mouseX = max(minX, mouseX);
   }
   if (mouseX > maxX) {
     mouseX = min(maxX, mouseX);
   }
   if (mouseY < minY) {
     mouseY = max(minY, mouseY);
   }
   if (mouseY > maxY) {
     mouseY = min(maxY, mouseY);
   }
  
  boolean didHit = false;
 //check to see if mouse cursor is inside button 
  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++;
    didHit = true;
    clicked.play();
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
    missed.play();
  }
  
  // Write to file
  if (trialNum > 0)
  {
    output.print(trialNum + ",");
    output.print(id + ",");
    output.print(preTrialXPos + ",");
    output.print(preTrialYPos + ",");
    output.print(GetButtonCenterX(trials.get(trialNum)) + ",");
    output.print(GetButtonCenterY(trials.get(trialNum)) + ",");
    output.print(40 + ","); // button width
    output.print(nf((millis() - lastButtonClickedTime) / 1000f, 0, 3) + ",");
    output.print(didHit ? 1 : 0);
    output.print("\n");
  }
  
  preTrialXPos = mouseX;
  preTrialYPos = mouseY;
  lastButtonClickedTime = millis();
  
  lastTargetButton = trials.get(trialNum);

  trialNum++; //Increment trial number
}

void mousePressed() // test to see if hit was in target!
{
    onButtonPushed();
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

int GetButtonCenterX(int i)
{
   return (i % 4) * (padding + buttonSize) + margin + (buttonSize / 2);
}

int GetButtonCenterY(int i)
{
    return (i / 4) * (padding + buttonSize) + margin + (buttonSize / 2);
}

//you can edit this method to change how buttons appear
void drawButton(int i, boolean withHighlight)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) {
    if (withHighlight) {
      // see if current button is the target, if so, make the color green
      fill(72, 90, 224);
    } else {
      fill(255, 160, 122);
    }
  } else {
    // if not, fill gray
    if (withHighlight)
    {
      fill(140, 140, 140);
    }
    else
    {
    fill(105, 105, 105);
    }
  }

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
   //System.out.println("mouseX=" + mouseX);
   //System.out.println("mouseY=" + mouseY);
   int minX = margin;
   int minY = margin;
   int maxX = 3 * (padding + buttonSize) + margin + buttonSize;
   int maxY = 4 * (padding + buttonSize) + margin - buttonSize;   
   if (mouseX < minX) {
     mouseX = max(minX, mouseX);
   }
   if (mouseX > maxX) {
     mouseX = min(maxX, mouseX);
   }
   if (mouseY < minY) {
     mouseY = max(minY, mouseY);
   }
   if (mouseY > maxY) {
     mouseY = min(maxY, mouseY);
   }
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html

}

void keyReleased() {
  if (int(key) == 32)
   {
     onButtonPushed();
   }
}
