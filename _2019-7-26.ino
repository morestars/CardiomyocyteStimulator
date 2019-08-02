/* Title: pulseTrainTest_20190620
 * Author: Andrew Masteller
 * Contact: amasteller5@gmail.com
 * Date: 2019-06-20 (yyyy-mm-dd)
 * Total time = sum(cycleLengthArray) * 2i pulses + 1 second buffer
 */

#define numCycles 6
int cycleLength;
int cycleLengthArray[numCycles] = {2000, 1500, 1000, 700, 500, 400};
int pulseDuration = 10;
int offTime;
long dur = 90000L;
int numIters;

void setup() {
  pinMode(2, OUTPUT); // forward  pulse gate
  pinMode(4, OUTPUT); // reverse pulse gate
  pinMode(7, OUTPUT); // led indicator
  Serial.begin(9600);
}

void loop() {
  digitalWrite(7, HIGH);
  delay(5000);
  digitalWrite(7, LOW);
  delay(250);

  // flash 10 times over 5 seconds
  for (int k = 0; k < 10; k++) {
    digitalWrite(7, HIGH);
    delay(250);
    digitalWrite(7, LOW);
    delay(250);
  }
  Serial.print("No Stimulation");
  Serial.println();

  delay(60000);
  
  // run through the cycleLengthArray
  // keep j equal to the size of the array if it is update
  for (int j = 0; j < numCycles; j++) {
    cycleLength = cycleLengthArray[j];      // iterate over cycleLengthArray
    offTime = cycleLength - pulseDuration;  // calculate offTime for each cycleLength
    numIters = dur/cycleLength/2;
    Serial.print("Cycle Length: ");
    Serial.print(cycleLength);
    Serial.println();
    Serial.print("Number of Iterations: ");
    Serial.print(numIters);
    Serial.println();

    digitalWrite(7, HIGH);
    delay(5000);
    digitalWrite(7, LOW);
    
    // run the given cycleLength for i=10 iterations of forward and reverse (2i pulses total)
    for (int i = 0; i <  numIters; i++) {  
      digitalWrite(7, HIGH);  // led indicator on
      delay(100);
      digitalWrite(7, LOW);   // led indicator off
      delay(100);
      
      digitalWrite(2, HIGH);  // open forward pulse gate
      delay(pulseDuration);   // keep forward pulse gate open for pulseDuration ms
      digitalWrite(2, LOW);   // close forward pulse gate
      delay(offTime - 200);

      digitalWrite(7, HIGH);  // led indicator on
      delay(100);
      digitalWrite(7, LOW);   // led indicator off
      delay(100);
      
      digitalWrite(4, HIGH);  // open reverse pulse gate
      delay(pulseDuration);   // keep reverse puse gate open for pulseDuration ms
      digitalWrite(4, LOW);   // close reverse pulse gate
      delay(offTime - 200);
    }
  }
}
