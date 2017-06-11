/*
arduino_input
 
 Demonstrates the reading of digital and analog pins of an Arduino board
 running the StandardFirmata firmware.
 
 To use:
 * Using the Arduino software, upload the StandardFirmata example (located
 in Examples > Firmata > StandardFirmata) to your Arduino board.
 * Run this sketch and look at the list of serial ports printed in the
 message area below. Note the index of the port corresponding to your
 Arduino board (the numbering starts at 0).  (Unless your Arduino board
 happens to be at index 0 in the list, the sketch probably won't work.
 Stop it and proceed with the instructions.)
 * Modify the "arduino = new Arduino(...)" line below, changing the number
 in Arduino.list()[0] to the number corresponding to the serial port of
 your Arduino board.  Alternatively, you can replace Arduino.list()[0]
 with the name of the serial port, in double quotes, e.g. "COM5" on Windows
 or "/dev/tty.usbmodem621" on Mac.
 * Run this sketch. The squares show the values of the digital inputs (HIGH
 pins are filled, LOW pins are not). The circles show the values of the
 analog inputs (the bigger the circle, the higher the reading on the
 corresponding analog input pin). The pins are laid out as if the Arduino
 were held with the logo upright (i.e. pin 13 is at the upper left). Note
 that the readings from unconnected pins will fluctuate randomly. 
 
 For more information, see: http://playground.arduino.cc/Interfacing/Processing
 */

import processing.serial.*;
import cc.arduino.*;

Arduino arduino;

import ddf.minim.*;

Minim minim;
AudioPlayer player;

// -------------------------------------------------------------------
// Options
int dataPin = 0;          // the input pin for the ultrasonic sensor 
int delay = 1000;         // length of time the song will play for 
                          // after last trigger (ms)
int fadeOutLength = 1000; // length of time the fade out takes (ms)
int fadeInLength = 1000;  // length of time the fade in takes (ms)
int stopDelay = 5000;     // length of time a pause can happen before 
                          // resetting the song to beginning (ms)
float threshold = 30.0;   // minimum distance to trigger playback (in)
int minVolume = -80;      // minimum volume
int maxVolume = 13;       // maximum volume

// -------------------------------------------------------------------
// Program state variables
boolean isFading = false; // whether player is fading out
int startTime = 0;        // time since start of playback
int lastPause = 999999;        // time since last pause

// -------------------------------------------------------------------
// Runs once when program is started
void setup() {
  size(470, 280);

  // Prints out the available serial ports.
  println(Arduino.list());

  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  arduino = new Arduino(this, Arduino.list()[1], 57600);

  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  // arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);

  // Set the Arduino digital pins as an input.
  arduino.pinMode(dataPin, Arduino.INPUT);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  // player = minim.loadFile("440.wav");
  // player = minim.loadFile("loopmedaddy.wav");
  player = minim.loadFile("test.mp3");
}

// ------------------------------------------------------------------
// Runs continuously in a loop while programming is running
void draw() {
 
  // ---------------------------------------------------- 
  // Take filterWidth measurements of the space and       
  // execute a filter to get the best data.               
  
  // Number of samples to take
  int filterWidth = 10;                                    
  // Array to store samples
  float[] samples = new float[filterWidth];               
  
  for (int i = 0; i < filterWidth; i++) {
    // -------------------------------------------------- 
    // Measure the distance to an object                  
    // Vcc/512 per inch --> divide raw by 2 for inches    
    
    // raw analog input
    int unscaled_distance = arduino.analogRead(dataPin);
    // scaled input to inches
    float sample = unscaled_distance / 2;
    
    // Add sample to array of samples
    samples[i] = sample;
    
    // Wait to let the sensor take another sample
    delay(10); // ms
  }
  
  float distance = minFilter(samples);
  // Uncomment this line to print sensor distance values
  // println("Distance to object is " + distance + ".");
  
  // Determine what to do about sound playback
  handleSound(distance);
}

// -------------------------------------------------------------------
// Return the minimum value from a sample array
float minFilter(float[] samples) {
  float min = 1024; // highest possible value
  for (int i = 0; i < samples.length; i++) {
    if (samples[i] < min) {
      min = samples[i];
    }
  }
  return min; 
}

// -------------------------------------------------------------------
// Execute sound logic
void handleSound(float distance) {
  // Check to see if we've hit the end of the song. 
  // If yes, repeat it.
  if ( player.position() == player.length() ) {
    player.rewind();
  }
  
  // Reset song if nobody has triggered it recently 
  int now = millis();
  if ( now - lastPause > stopDelay && !player.isPlaying()) {
    println("Now:" + now + "\nlastPause: " + lastPause);
    player.rewind();
  }
  
  // If the measured distance is less than the threshold
  // fade the music in; else fade it out.
  if (distance < threshold) {
    fadeIn();
  } else {
    fadeOut();
  }
}


// -------------------------------------------------------------------
// Fades music in
void fadeIn() {
  // Check to see whether the player is going 
  if (!player.isPlaying()) {
    player.loop();
    player.shiftGain(minVolume, maxVolume, fadeInLength);
  }
  
  // Reset the timestamp
  startTime = millis();
}

// -------------------------------------------------------------------
// Fades music out
void fadeOut() {
  // The time since program started up
  int now = millis();
    
  // If the player is playing AND not fading, start the fade
  if ((now - startTime > delay) && player.isPlaying() && !isFading) {
    player.shiftGain(maxVolume, minVolume, fadeOutLength);
    isFading = true;
  }
  
  // If the player has played for long enough 
  // AND we're not fading, pause playback
  if (now - startTime > delay + fadeOutLength && player.isPlaying()) {
    isFading = false;
    player.pause();
    lastPause = now;
  }
}