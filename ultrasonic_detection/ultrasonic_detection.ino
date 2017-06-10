// Feel free to use this code.

// Please be respectful by acknowledging the author in the code 
// if you use or modify it.
// Author: Bruce Allen
// Date: 23/07/09
// Modified: Paul Bucci pbucci@cs.ubc.ca 2017 06 06

// Digital pin 9 for reading in the pulse width from the 
// MaxSonar device.

// This variable is a constant because the pin will not change 
// throughout execution of this code.
const int pwPin = 9;

//variables needed to store values
long pulse, inches, cm;

void setup()

{
  //This opens up a serial connection to shoot the results back to the PC console
  Serial.begin(9600);
}

void loop()

{
  pinMode(pwPin, INPUT);

  //Used to read in the pulse that is being sent by the MaxSonar device.

  //Pulse Width representation with a scale factor of 147 uS per Inch.
  pulse = pulseIn(pwPin, HIGH);

  //147uS per inch
  inches = pulse / 147;

  //change inches to centimetres
  cm = inches * 2.54;

  Serial.print(inches);
  Serial.print("in, ");
  Serial.print(cm);
  Serial.print("cm");
  Serial.println();

  delay(500);

}
