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
import ddf.minim.*;

Minim minim;
AudioPlayer player;
Arduino arduino;

int dataPin = 3; // the input pin for the PIR sensor 
boolean isHigh = false;
color off = color(4, 79, 111);
color on = color(84, 145, 158);

int delay = 15000;     // 10 seconds
int stopDelay = 1000; // 10 seconds 

boolean isFading = false;

int startTime = 0;

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
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);
  
  // Set the Arduino digital pins as an input.
  arduino.pinMode(dataPin, Arduino.INPUT);
  
  // we pass this to Minim so that it can load files from the data directory
  minim = new Minim(this);
  
  // loadFile will look in all the same places as loadImage does.
  // this means you can find files that are in the data folder and the 
  // sketch folder. you can also pass an absolute path, or a URL.
  player = minim.loadFile("440.wav");
   //player = minim.loadFile("test.mp3");
}

void draw() {
  background(off);
  stroke(on);
  
  // Check to see if we've hit the end of the song. If yes, repeat it.
  if ( player.position() == player.length() ) {
    player.rewind();
  }
  
  // Draw a filled box for each digital pin that's HIGH (5 volts).
  for (int i = 0; i <= 13; i++) {
    if (arduino.digitalRead(i) == Arduino.HIGH && i == 3) {
      fill(on);
      playSound();
    }
    else {
      fill(off);
      isHigh = false;
      stopSound();
    }
      
    rect(420 - i * 30, 30, 20, 20);
  }

  // Draw a circle whose size corresponds to the value of an analog input.
  noFill();
  for (int i = 0; i <= 5; i++) {
    ellipse(280 + i * 30, 240, arduino.analogRead(i) / 16, arduino.analogRead(i) / 16);
  }
}

void playSound() {
  // Check to see whether the player is going
  //boolean wasPlaying = player.isPlaying();
  
  if (!player.isPlaying()) {
    player.play();
    player.shiftGain(-80, 13, 1000);
  }
  //player.play();
  
  // Reset the timestamp
  startTime = millis();
}

void stopSound() {
  int now = millis();
  if ((now - startTime > delay) && player.isPlaying() && !isFading) {
    player.shiftGain(13,-80, stopDelay);
    isFading = true;
  }
  if (now - startTime > delay + stopDelay) {
    isFading = false;
    player.pause();
  }
}