// Pin number initialization
  const int RA = 4; // red only needs on / off capability
  const int GA = 5; // Green needs dimming capability use PWM
  const int RB = 7;
  const int GB = 6;
  const int maintenance_pin = 2;

// Light durations initialization
  const unsigned long time_scale = 1000;
  const unsigned long DR_time = 1 * time_scale;    // Delay red light duration
  const unsigned long G_time = 5 * time_scale;     // Green light duration
  const unsigned long PG_time = 1 * time_scale;    // Pale green light duration
  const int PG_level = 100; // Pale green brightness level

  enum class Light {
      GREEN = 0,
      PALE = 1,
      RED = 2,
      OFF = 3,
  };

  enum class Street {
      A = 0,
      B = 1,
  };

  Light operator ++ (Light &state, int) {
      switch (state) {
          // Green
          case Light::GREEN:
              state = Light::PALE;
              break;
          // Pale Green
          case Light::PALE:
              state = Light::RED;
              break;
          // Red
          case Light::RED:
              state = Light::GREEN;
              break;
          // Off
          case Light::OFF:
          default:
              state = Light::OFF;
              break;
      }
      return state;
  }

  Light operator ! (Light state) {
      if (state == Light::OFF) {
          return Light::GREEN;
      }
      return Light::OFF;
  }

  Street operator ! (Street street) {
      switch (street) {
          case Street::A:
              return Street::B;
          case Street::B:
              return Street::A;
      }
  }

  bool maintenance_state;
  bool next_maintenance;
  // See enum Light
  Light state;
  // False = A, True = B
  Street street;
  bool ped;
  unsigned long next_time;


void writeLight(Light state, Street street) {
    int pin_red, pin_green;
    switch (street) {
        case Street::A:
            pin_red = RA;
            pin_green = GA;
        case Street::B:
            pin_red = RB;
            pin_green = GB;
    }
    switch (state) {
        // Green
        case Light::GREEN:
            digitalWrite(pin_red,LOW);
            digitalWrite(pin_green,HIGH);
            break;
        // Pale Green
        case Light::PALE:
            digitalWrite(pin_red,LOW);
            analogWrite(pin_green,PG_level);
            break;
        // Red
        case Light::RED:
            digitalWrite(pin_red,HIGH);
            digitalWrite(pin_green,LOW);
            break;
        // Off
        case Light::OFF:
        default:
            digitalWrite(pin_red,LOW);
            digitalWrite(pin_green,LOW);
            break;
    }
}

void writeState(Light state, Street street, bool maintenance_state, bool ped) {
    writeLight(Light::RED, !street);
    if (maintenance_state) {
        writeLight(Light::RED, street);
        return;
    }
    if (ped) {
        writeLight(Light::GREEN, street);
        return;
    }
    writeLight(state, street);
}

unsigned long timeout(Light state) {
    unsigned long timeout;
    switch (state) {
        case Light::GREEN:
            timeout = G_time;
            break;
        case Light::PALE:
            timeout = PG_time;
            break;
        case Light::RED:
            timeout = DR_time;
            break;
        case Light::OFF:
        default:
            timeout = 0;
            break;
    }
    return timeout;
}

void setup() {
  Serial.begin(9600);
  pinMode(RA,OUTPUT);
  pinMode(GA,OUTPUT);
  pinMode(RB,OUTPUT);
  pinMode(GB,OUTPUT);
  pinMode(maintenance_pin,INPUT);

  // Explicitly defining initial conditions
  maintenance_state = false;
  next_maintenance = false;
  state = Light::GREEN;
  street = Street::A;
  ped = false;
  next_time  = millis() + G_time;
  writeState(state, street, maintenance_state, ped);
}

void loop() {
  next_maintenance = next_maintenance | digitalRead(maintenance_pin); // Read value of maintenance pin
  unsigned long now = millis();
  if (now >= next_time) {
      maintenance_state = maintenance_state ^ next_maintenance;
      if (maintenance_state) {
          state = Light::RED;
          return;
      }
      next_time = millis() + timeout(state);
      state++;
      writeState(state, street, maintenance_state, ped);
  }
}
