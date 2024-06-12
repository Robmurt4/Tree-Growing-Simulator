/*
Project Title: Tree Growing Simulator

This game consists of a tree located on the centre of the screen. The user will have to solve
algebraic equations in order to make the tree grow. 

Game Instructions:
-Click on the screen to make a question appear.
-Type in your answers using the number keys and '-' key.
-Input your answer by pressing the enter key
-Your score will increase as you answer questions. 
-Your time and combo will be factored into the score.

Libraries used: 
-"Minim" by Damien Di Fede and Anderson Mills, Source: https://code.compartmental.net/minim/
*/

//Sound Effect from <a href="https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=27052">Pixabay</a>

import ddf.minim.analysis.*;
import ddf.minim.*; 
Minim minim;
AudioPlayer grow;

PFont f;
PImage Background,EquationBackground, Correct, Wrong, Tree, Speech;

PImage[] trees = new PImage[4]; //Array of images for tree sprites
PImage[] leaves = new PImage[4]; //Array of images for leaves sprites

// Variable to store text currently being typed
String typing = "";

// Variable to store saved text when return is hit
String saved = ""; //Saves the users first input (first answer for x)
String saved2 = ""; //Saves the users second input (second answer for x)
String equation = ""; //The algebraic equation
//String victory = "";


//int sd = 2; //b
double square2; //Used to find the square of b 

String quote = ""; //String for the tree fact that's displayed when the user gets 3 questions correct.
int quote1; //Variable for value of random quote
int quoteCount = 0; //Counter that checks whether tree fact will display
Boolean quoteCheck = false; //Insures that only one quote will draw


int a; //The coefficient of x^2
int b; //The coefficient of x 
int c; //Value of the constant
double result1; //First correct solution
double result2; //Second correct solution

int treeNum = 1; //The number for the tree image currently on display.
int life = 3; //Keeps track of how the leaves will look (green, wilted, absent)

boolean second = false; //Checks whether the user is on there first or second input.
boolean finished = false; //Checks whether the user has just finished a question

int combo = 0; //Questions gotten right in a row.
int score = 0; //The user's score
int timer = 0; //Timer for how long user spends on a question

int seconds = 0;

//Used for converting user inputs to a double 
double x1 = 0;
double x2 = 0;
boolean complete = false;

int tree = 624; //The tree's height
int treeW = 624; //The tree's width

boolean equationOn = false; //Checks whether an equation is currently on

void setup() {
  surface.setTitle("Tree Growing Simulator");
  size(816, 624);
  
  f = createFont("HandDrawnShapes.otf",24); //Font used is a public domain font found on http://www.publicdomainfiles.com/show_file.php?id=13486258342003
  
  /*
  All images used in this project were created by me using a combination 
  of Clip Studio Paint and Gimp on a drawing tablet.
  */
  Background = loadImage("Background.png");
  EquationBackground = loadImage("EquationBackground.png");
  Correct = loadImage("Correct.png");
  Wrong = loadImage("Wrong.png");
  Speech = loadImage("Speech.png");
  /*
  Code adapted from example on: https://discourse.processing.org/t/array-of-images/32120
  This code creates an array of images based on the files in the data folder.
  I have made the following changes:
  -Changed it to work for two arrays of images.
  */
  for(int i = 0; i < 4; i++)
  {
  trees[i] = loadImage("Tree"+(i+1)+".png"); //Array of imagesfor the tree
  leaves[i] = loadImage("Leaves"+(i+1)+".png"); //Array of images for the leaves
  }
}


void draw() 
{
  background(255);
  tint(255,255,255);
  image(Background,0,0);
  
  
  /*
  Loads the image of the tree based on the current number in the trees array. 
  It ensures that the trees drawn will always appear in the centre of the screen by
  using the width of the image and the screen.
  /the height and width of the tree will change as the user gets questions correct.
  */
  fill(100,50,0);
  image(trees[treeNum],width/2-(treeW/2),height - tree + ((tree-624)/8)); 
  trees[treeNum].resize(treeW,tree); //Will resize the image
  image(trees[treeNum],width/2-(treeW/2),height - tree + ((tree-624)/8));

  /*
  Code to display the image of the leaves based on the current number in the leaves array.
  It will also display the trees health:
  -Leaves will be green when life = 3
  -Leaves will be green when life = 2
  -Leaves will not appear if life = 1 
  
  The life variable will increase or decrease based on whether the user gets a question wrong or right.
  */
  if(life > 1){
  
    image(leaves[treeNum],width/2-(treeW/2),height - tree + ((tree-624)/8));
    leaves[treeNum].resize(treeW,tree); //Will resize the image
    if(life == 2)
    {
      tint(140,120,70); //Makes the leaves grey. 
    }
    image(leaves[treeNum],width/2-(treeW/2),height - tree + ((tree-624)/8));
    tint(255,255,255); //Makes the leaves green.
  }

  //Sets the font in the program.
  textFont(f);
  fill(0);

  /*This section of the code will generate a string based on the randomly 
  generated equation. It factors in whether the coefficient is equal to zero,
  as well as whether it's positive or negative.*/ 
  
  equation = "";  //Resets equation from previous question.
  
  //The coefficient of x^2 (a)
  if(a > 1) equation = equation + Integer.toString(a) + "x^2";
  else if(a==1) equation = equation + "x^2";
  else if(a==-1) equation = equation + "- x^2";
  else equation = "- "+equation + Integer.toString(a * -1) + "x^2";
  
  //The coefficient of x (b)
  if(b>1) equation = equation + " + " + Integer.toString(b) + "x";
  else if(b==1)equation = equation + " + x";
  else if(b==-1) equation = equation + " - x";
  else if(b == 0);
  else equation = equation + " - " + Integer.toString(b * -1) + "x";

  //The constant (c)
  if(c>0)equation = equation + " + " + Integer.toString(c) + " = 0";
  else if(c == 0)
  equation = equation + " = 0";
  else equation = equation + " - " + Integer.toString(c * -1) + " = 0";
    
  textAlign(RIGHT);
  text("Score: "+ score, width-10,20);   
  
  //The overlay that will display when the user is not in the middle of a question.
  if(equationOn==false) //Ensures that user is not in the middle of a question.
  {
    //rect(10, 10, 50, 20);
    textSize(24);
    fill(255, 255, 255); //Sets text to white
    textSize(20);
    textAlign(CENTER);
    text("Click anywhere on screen!", width/2,height - 20); 
    textSize(18);
    
/*This section of the code willpick a random fact about the environment out of five and
display it in a speech bubble whenever the user gets 3 questions right.*/

    fill(0); //Sets text to black
    textAlign(CENTER); 
    if(quoteCount >= 3)
    {
      tint(255,255,255);
      image(Speech,560,180);
      if(quoteCheck == false)
      {
      quote1 = (int)random(1,5); //Pulls a random number between 1 and 5.
      quoteCheck = true;
      }
      switch(quote1)
      {
        case 1: text("Did you know\nthat mature trees\nabsorb more than\n48 pounds of \ncarbon dioxide\nevery year?",658,235); break;
        case 2: text("Did you know\nthat it is predicted\nthat 28,000 species \nwill become extinct\nin the next 20\nyears due to\ndeforestation?",658,216); break;
        case 3: text("Did you know\nthat an area of\nforest the size\nof a football field\n is destroyed every\n1.2 seconds?",658,230); break;
        case 4: text("Did you know\nthat at the current\nrate of deforestation\nthe world's \nrainforests could\ndisappear\nin 100 years?",658,215); break;
        case 5: text("Did you know\nthat trees consume\npee and poo lmao?\nThey do so \nas fertiliser",658,250); break; 
      }        
    }
  }

  //This section of the code diaplays the UI  for when the user is answering a question.
  else
  {
    image(EquationBackground,0,0);
    
    fill(255);
    textSize(20); 
    textAlign(CENTER);
    text("Solve the following equation: ", width/2, 230);
    stroke(255);
    strokeWeight(2);
    line((width/2-200),235,(width/2+200),235);
    textSize(58); 
    
    text(equation, width/2, 300);
    textSize(38);
    fill(255,220,0);
    text("Input: " + typing, width/2,355); //Displays what the user is currently typing.
    fill(255);
    textAlign(LEFT);
    text("x = " + saved,(width/2)-150,400); //Displays the users first input.
    
    text("x = " + saved2,(width/2)+100,400); //Displays the users second input.
    
    /* text(""+ result1, 20,250);
    text(""+ result2, 20,290); */ //Code that displayed the results for faster bug testing.
    
    fill(0);
    textSize(24);
    text("Time: "+ seconds, 10,20); //Displays the timer.
  
  /* The time for each question, since there are 60 frames in a second in processing,
  the seconds variable will increase each frame and increase the timer variable by 
  1 once it reaches 60 */
    if(equationOn == true)
    {
      timer++;
      if(timer==60 )
      {
        seconds++;
        timer = 0;
      }
    }
  }
  fill(0);
  textAlign(LEFT);
  
  if(finished==true) //Will only run if the user finishes with their previous question
                     //It will reset everything for the next question
  {   
      delay(1800); //Makes the program wait before removing the correct/wrong photos. 
      timer=0;
      seconds = 0;
      saved = ""; //Resets the user inputed answers.
      saved2 = "";
      second = false; 
      equationOn = false;  
      finished = false;
      typing = "";   
      
/*This section of the code checks whether the user presses the mouse in order to start 
a new question. It ensures that the user is not already in the middle of a question 
by using a boolean.*/
  }    
   if (mousePressed)
   {
     //if (mouseX>10 && mouseX <60 && mouseY>10 && mouseY <30)
     //{
       if(equationOn==false)
       {
         if(quoteCount>=3){
         quoteCheck = false;  
         quoteCount = 0;}
         
         timer = 0;
         seconds = 0;
         //victory = "";
         /*Here is the generation of a random equation The program will run a loop until 
         it verifies that the equation has real solutions and that the equation is  a
         quadratic.
         */
         do{
            equationOn = true;
    
            a = (int)random(-10, 10); //The coefficient of x^2
            
            b = (int)random(-12, 12); //The coefficient of x
            c = (int)random(-100, 100);//The constant
            
            /*This part of the code is derived from the -b formula 
            in order to find the solutions*/
            double square = Math.pow(b,2);
            //println("square " +square);
            square2 = square - (4 * a * c);
            //println("square2 " +square2);
            
            if(square2 >= 0) //Checks that there are solutions
            {
                double root = Math.sqrt(square2); 
                double b2 = b * -1;
    
                double div = a * 2;
                
                result1 = (b2 + root)/div; //Correct answer 1
                result2 = (b2 - root)/div; //Correct answer 2
                //println("result1"+result1); 
                //println("result2"+result2); 
            }
          }while(square2 < 0 | a == 0 | result1 != (int)result1 | result2 != (int)result2); 
          /*This condition for the do while loop ensures that the equation is a quadratic, that the 
            equation is a quadratic and that the solutions are whole numbers.*/
    }
  }
}
/*
This code is adapted from an example on  http://learningprocessing.com/examples/chp18/example-18-01-userinput
I have made changes as follows:
-Made it so that the user can only input numbers or the '-' character.
-Changed the code to save two seperate strings instead of one, necessary for the two solutions of a quadratic.
-Made it so that users can erase numbers inputed by pressing backspace.
-Made it so that the code converts the inputed strings to doubles and checks whether the user is correct or not.
*/
void keyPressed() 
{
  if(equationOn == true){
  /*What occurs if the user pushes enter. It ensures that the string
  is not equal to a single "-" char.*/
  if (key == '\n' & typing != "" & typing.equals("-") == false)
  {
    
    if(second == false) //Checks whether the user is inputing the first or second solution.
    {
        
      saved = typing; //Saves the users first input
      x1 = Double.parseDouble(saved); //Converts answer to a double
      second = true;
    }
    else
    {
    saved2 = typing;
        
    x2 = Double.parseDouble(saved2);
    
    if((x1 == result1 & x2 == result2) | (x1 == result2 & x2 == result1))//If answer is correct.
    {
      minim = new Minim(this);
      grow = minim.loadFile("Correct.wav"); // load the music file into memory
      grow.play();
      image(Correct,0,0);
      combo++;
      tree += 50;
      treeW += 50;
      /*The scoring system. It factors in the ammount of questions 
      the user got right in a row as well as their timing.
      It also ensures that the timer is not equal to zero, which would
      cause an error.*/
      if(seconds != 0)score += (int)((100 * combo)/seconds); 
      else score += (int)((100 * combo));
      
      
      if(life < 3) life++; //Increases the leave health if not already at the max(i.e if the leaves are already green.)
      quoteCount++; //Increases the value for the counter for when the next tree fact will appear.
      
      if(tree > 1020 -(125 * treeNum) & treeNum < 3)//Checks if program is ready to progress to the next tree image
      {
        tree = 624;
        treeW = 624;
        treeNum++; 
      }
    }
    else //If answer is wrong.
    {
      //Sound effect for wrong answer
      minim = new Minim(this);
      grow = minim.loadFile("Wrong.wav");
      grow.play();
      image(Wrong,0,0); //Image for wrong answer
      combo = 0;
      if(life > 1) life--;
    }
    finished = true;
  }
  typing = ""; //Resets the user input string 
  }
  /*Alows user to delete characters by pressing backspace.
  Does not occur if no characters are  inputet*/
  else if (key == '\b' & typing != "") 
  {
    minim = new Minim(this);
      grow = minim.loadFile("Back.wav");
      grow.play();
    typing = typing.substring(0, typing.length()-1); //Deletes last character
  }
  else if((key >= '0' && key <= '9') | key == '-') //Ensures that users can only type numbers and "-"
  {
    minim = new Minim(this);
      grow = minim.loadFile("Click.wav"); // load the music file into memory
      grow.play();
      
    //Caps the input string at 6 and ensures that a "-" cannot be inputed at the middle or end of a number
    if((typing.length() != 0 & key == '-') | typing.length() > 6){ 
    }
    else{ typing = typing + key; } //Adds typed key to the string.
  }
  else if(key == 'x')println("Result1: "+result1+" Result2: "+result2); /*This is a cheat to display the answers in the 
                                                                                                 console in order to make bug testing easier.*/
  }
}
