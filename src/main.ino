// Pin number initialization
  const int RA = 4; // red only needs on / off capability
  const int GA = 5; // Green needs dimming capability use PWM
  const int RB = 7;
  const int GB = 6;
  const int maintenance_pin = 2;

// Light durations initialization
  const unsigned long R_time = 6;    // Red light duration
  const unsigned long DR_time = 1;    // Delay red light duration
  const unsigned long G_time = 5;     // Green light duration
  const unsigned long PG_time = 1;    // Pale green light duration
  const int G_level = 200;  // Green brightness level
  const int PG_level = 100; // Pale green brightness level
  bool maintenance_state;

void setup() {
  Serial.begin(9600);
  pinMode(RA,OUTPUT);
  pinMode(GA,OUTPUT);
  pinMode(RB,OUTPUT);
  pinMode(GB,OUTPUT);
  pinMode(maintenance_pin,INPUT);

  // Explicitly defining initial conditions
  digitalWrite(RA,LOW);
  digitalWrite(RB,HIGH);
  analogWrite(GA,G_level);
  analogWrite(GB,0);
}

void loop() {
  maintenance_state = digitalRead(maintenance_pin); // Read value of maintenance pin
  Serial.println(maintenance_state);
  if (maintenance_state == HIGH){
    // If maintence is in progress turn both red lights on
    digitalWrite(RA,HIGH);
    digitalWrite(RB,HIGH);
    analogWrite(GA,0);
    analogWrite(GB,0);

    return;
    }
  else if (maintenance_state == LOW) {

    // Phase 6:
      // Street A red stays off
      analogWrite(GA,PG_level); // Dim street A green to pale green
      // Street B red stays on
      // Street B green stays off
      delay(1000*PG_time);

    // Phase 1:
      analogWrite(GA,0); // Turn street A pale green off
      digitalWrite(RA,HIGH); // Turn street A red on
      // Street B red changes to delay red but no real change
      // Street B green is already off
      delay(1000*DR_time);

     // Phase 2:
      // Street A red stays on
      // Street A green stays off
      digitalWrite(RB,LOW); // Turn street B delay red off
      analogWrite(GB,G_level); // Turn street B green on
      delay(1000*G_time);

     // Phase 3:
      // Street A red stays on
      // Street A green stays off
      // Street B red stays off
      analogWrite(GB,PG_level); // Dim street B green to pale green
      delay(1000*PG_time);

     // Phase 4:
      // Street A red changes to delay red but no real change
      // Street A green stays off
      analogWrite(GB,0); // Turn street B pale green off
      digitalWrite(RB,HIGH); // Turn street B red on
      delay(1000*DR_time);

     // Phase 5:
      digitalWrite(RA,LOW); // Turn street A delay red off
      analogWrite(GA,G_level); // Turn street A green on
      // Street B red stays on
      // Street B green stays off
      delay(1000*G_time);

    }

}
