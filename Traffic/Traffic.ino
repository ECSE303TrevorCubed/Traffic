// Pin number initialization
const int RA = 4;  // red only needs on / off capability
const int GA = 5;  // Green needs dimming capability use PWM
const int RB = 7;
const int GB = 6;

const int maintenance_pin = 2;

const int ped_a_light = 13;
const int ped_b_light = 9;
const int ped_a_button = 12;
const int ped_b_button = 8;

// Light durations initialization
const unsigned long time_scale = 1000;
const unsigned long DR_time = 1 * time_scale;  // Delay red light duration
const unsigned long G_time = 5 * time_scale;   // Green light duration
const unsigned long PG_time = 1 * time_scale;  // Pale green light duration
const unsigned long ped_time = 10 * time_scale;
const int PG_level = 100;  // Pale green brightness level

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

Light operator++(Light &state, int) {
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

Light operator!(Light state) {
  if (state == Light::OFF) {
    return Light::GREEN;
  }
  return Light::OFF;
}

Street operator!(Street street) {
  switch (street) {
    case Street::A:
      return Street::B;
    case Street::B:
      return Street::A;
  }
}

bool maintenance_active = false;
bool last_maintenance_reading = LOW;

Light state = Light::GREEN;
Street active_street = Street::A;
unsigned long next_time = 0;

bool ped_req_a = false;
bool ped_req_b = false;
bool ped_active = false;
Street ped_street = Street::A;
unsigned long ped_end_time = 0;

void writeLight(Light state, Street street) {
  int pin_red, pin_green;
  switch (street) {
    case Street::A:
      pin_red = RA;
      pin_green = GA;
      break;
    case Street::B:
      pin_red = RB;
      pin_green = GB;
      break;
  }

  switch (state) {
    // Green
    case Light::GREEN:
      digitalWrite(pin_red, LOW);
      digitalWrite(pin_green, HIGH);
      break;
    // Pale Green
    case Light::PALE:
      digitalWrite(pin_red, LOW);
      analogWrite(pin_green, PG_level);
      break;
    // Red
    case Light::RED:
      digitalWrite(pin_red, HIGH);
      digitalWrite(pin_green, LOW);
      break;
    // Off
    case Light::OFF:
    default:
      digitalWrite(pin_red, LOW);
      digitalWrite(pin_green, LOW);
      break;
  }
}

void update_lights() {
  if (maintenance_active) {
    writeLight(Light::RED, Street::A);
    writeLight(Light::RED, Street::B);
    digitalWrite(ped_a_light, LOW);
    digitalWrite(ped_b_light, LOW);
    return;
  }

  // active_street gets current state, other street gets RED
  Light light_a = (active_street == Street::A) ? state : Light::RED;
  Light light_b = (active_street == Street::B) ? state : Light::RED;

  // Override if a pedestrian crossing is active on one street
  if (ped_active) {
    // Non-ped street can continue cycle freely
    if (ped_street == Street::A) {
      light_a = Light::RED;
      light_b = (active_street == Street::B) ? state : Light::RED;
      digitalWrite(ped_a_light, HIGH);
    } else {
      light_b = Light::RED;
      light_a = (active_street == Street::A) ? state : Light::RED;
      digitalWrite(ped_b_light, HIGH);
    }
  } else {
    digitalWrite(ped_a_light, LOW);
    digitalWrite(ped_b_light, LOW);
  }

  writeLight(light_a, Street::A);
  writeLight(light_b, Street::B);
}

unsigned long timeout(Light l) {
  switch (l) {
    case Light::GREEN: return G_time;
    case Light::PALE: return PG_time;
    case Light::RED: return DR_time;
    default: return 0;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(RA, OUTPUT);
  pinMode(GA, OUTPUT);
  pinMode(RB, OUTPUT);
  pinMode(GB, OUTPUT);
  pinMode(maintenance_pin, INPUT);

  pinMode(ped_a_light, OUTPUT);
  pinMode(ped_b_light, OUTPUT);
  pinMode(ped_a_button, INPUT);
  pinMode(ped_b_button, INPUT);

  // Explicitly defining initial conditions
  state = Light::GREEN;
  active_street = Street::A;
  next_time = millis() + timeout(state);
  update_lights();
}

void loop() {
  unsigned long now = millis();

  // poll maintenance
  bool maintenance_reading = digitalRead(maintenance_pin);
  if (maintenance_reading == HIGH && last_maintenance_reading == LOW) {
    if (maintenance_active) {
      maintenance_active = false;
      ped_active = false;
      ped_req_a = false;
      ped_req_b = false;

      // Go back to a 'zero' state
      active_street = Street::A;
      state = Light::GREEN;
      next_time = now + timeout(state);
      update_lights();
    } else {
      maintenance_active = true;  // end current cycle
    }
  }
  last_maintenance_reading = maintenance_reading;

  // poll pedestrians
  if (digitalRead(ped_a_button) == HIGH && (!ped_active && ped_street == Street::A)) {
    ped_req_a = true;
  }
  if (digitalRead(ped_b_button) == HIGH && (!ped_active && ped_street == Street::B)) {
    ped_req_b = true;
  }

  // check for finished peds
  if (ped_active && now >= ped_end_time) {
    ped_active = false;
    update_lights();
  }

  // advance state machine
  if (now >= next_time) {
    if (state == Light::GREEN) {
      state = Light::PALE;
      next_time = now + timeout(state);
    } else if (state == Light::PALE) {
      state = Light::RED;
      next_time = now + timeout(state);
    } else if (state == Light::RED) {
      // Only freeze intersection here since its safe
      if (maintenance_active) {
        update_lights();
        return;
      }

      // pending peds
      if (!ped_active && (ped_req_a || ped_req_b)) {
        ped_active = true;
        if (ped_req_a) {
          ped_street = Street::A;
          ped_req_a = false;
        } else {
          ped_street = Street::B;
          ped_req_b = false;
        }
        ped_end_time = now + ped_time;
      }

      // active street switch only wo peds
      active_street = !active_street;
      if (ped_active && active_street == ped_street) {
        active_street = !active_street;
      }

      state = Light::GREEN;
      next_time = now + timeout(state);
    }
    update_lights();
  }
}
