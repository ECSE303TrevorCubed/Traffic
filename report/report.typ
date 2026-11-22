#import "@preview/merman:0.6.0": mermaid-figure

#show link: set text(fill: blue)
#show title: set text(size: 17pt)
#show title: set align(center)

#title[
  ECSE303 Lab Assignment 6 \
  Traffic Controller
]
#align(center)[Trevor Swan, Justin Fossum, Trevor Nichols]

#set heading(numbering: "1.")

= Assignment Statement and Objective

The main objective of this assignment is to design and emulate a traffic controller at a hypothetical intersection of two one-way streets, named A and B. This task is achieved through the use of an Arduino Uno micro controller and corresponding custom breadboard circuit to control red and green LED lights that are to represent this hypothetical intersection's traffic lights. In order to keep the scope of this endeavor manageable, two assumptions were made. Firstly, no turns are allowed on either street, meaning the hypothetical vehicles pass straight through the intersection. Secondly, the traffic light is capable of only showing solid green or solid red, meaning yellow lights or flashing lights in general are not considered.

To accommodate the traffic controller's lack of yellow light functionality, the green light is to be dimmed for 10 seconds prior to turning red to inform drivers of the upcoming light change. Additionally, with safety in mind, an additional delay of 10 seconds is added to the end of the red lights interval. This ensures a period of time where the red lights for both streets are simultaneously on, reducing the likelihood of collisions if a vehicle happens to run through a recently switched on red light. With these considerations, the light timings are: 70 seconds red, 50 seconds green, 10 seconds dimmed green. Street A and B alternate these timings every one minute. In the situation where the traffic light is under maintenance, a toggle button was implemented that, if engaged, turns on the red lights and consequently turns off the green lights for both streets, signaling to traffic that the intersection is under repair and closed.

To accomodate the crossing of pedestrians, functionality was added that lets a pedestrian interupt the natural traffic light cycle to cross either street safely. To allow crossing for both streets, two additonal buttons and their correpsonding dedicated pedestrian lights were installed to alert oncomming traffic. Now, any pedestrian intent on crossing a particular street need only press that street's button to make known their request. When this button is pressed, the associated pedestrian light turns on once that street has finished its current red or green light phase. The moment the pedestrian light turns on, the red light for that street also simultaneously turns on to stop that street's traffic. This pedestrian light stays lit for a total of 60 seconds, allowing plenty of time for the pedestrian to traverse the street safely. Meanwhile, the traffic lights for the opposite street continue uninterupted. After the pedestrian light turns off, the street's traffic lights will resyncronize and resume as normal. To enhance robustness, this system shall only respond to one pedestrian request at a time in the order they were requested in. In the situation where requests are processed simultaneously, priority is to be given to the pedesrian crossing street A. Additionally, the pedestrian light is to not respond to subsequent requests on the same street during the first requests interval.

= Methodology and Steps

== Hardware Configuration

We implemented the entire circuit for both parts on a single breadboard directly connected to the pins on the Arduino. This was necessary as the 'Hat' mentioned in the instructions could not be located in the lab at the time of completion. The following describe our pin layout:
- Pins 4 and 5 were selected for the red and green LEDs for Street A, respectively
  - Pin 4's choice was arbitrary
  - Pin 5 was specifically chosen as it was annotated with a tilde on the board, indicating that it supported PWM, which was needed for slightly dimming the green LED
- Pins 7 and 6 were selected for the red and green LEDs for Street B, respectively
  - Pin 7 was arbitrarily chosen
  - Pin 6 was chosen due to its PWM capability as it had to fulfill the same duty as Pin 5 in Street A
- A standard button was used for maintenance control and pedestrian lighting
  - Pull-down resistors (10 kOhms) were set up for each button to prevent noise in their reads
  - Buttons were wired with 3.3V power and digital read on one side of the probes and the pull-down resistor diagonally across from the power line connected to ground
- Pedestrian indicators were constructed using two yellow LEDs (the only other color in our toolbox) connected to Pin 11 (Street A) and Pin 9 (Street B)
- 220 Ohm resistors were used to wire up all LEDs used in the circuit

== Part 1: One-way Traffic
1. Implemented strongly typed ```cpp enum class```'s with an overloaded postfix increment operator and overloaded boolean not operator for clean code to implement the state transitions
2. ```cpp delay()``` calls were avoided entirely to prevent unresponsive inputs, Timing was instead handled using ```cpp millis()``` calls coupled with tracked timestamps via ```cpp next_time = now + timeout(state)```
3. Solid green LEDs were shown for the standard 'Go' signal for vehicles. This phase lasts 50 seconds
4. Caution signals were implemented using PWM-controlled green LEDs (dubbed pale green) instead of the standard yellow signal. This caution signal lasts 10 seconds following the solid green
5. In all downtime, the street's red LED is solid. It is disabled in all other cases
6. An overlapping period was implemented where both states are at their red state to minimize collision hazards

== Part 2: Pedestrian Traffic
1. Tracked pedestrian button requests that can occur at arbitrary moments in the cycle by polling every iteration of ```cpp loop()```. Internal latches (```cpp ped_req_a = true``` or ```cpp ped_req_b = true```) are managed to make it so that pedestrians don't need to time their button presses precisely when they'd have the right-of-way
2. Pedestrian crosswalk signals (yellow LEDs) are only enabled when both directions have red lights, as is the case in real life. During this time, the crosswalk not involving the pedestrian is allowed to continue its cycle, though the pedestrian's crosswalk remains red for vehicles for safety
3. The crossing cycle lasts a full 60 seconds and is calculated with ```cpp ped_end_time = now + ped_time```. During this time, the corresponding LED is enabled and the builtin LED is turned on when it is safe to cross. The standard cycle continues for vehicles once this cycle is over

= Results and Observations

=== Part 1: One-way Traffic
#mermaid-figure(
  read("part1.mmd"),
  caption: [One-way Traffic Controller State Transition Diagram],
  width: 80%,
)

#figure(
  image("part1.jpeg", width: 85%),
  caption: [One-way Traffic Controller Circuit],
)

We observed that there are only 3 states per street, plus the maintenance state for a total of 7 states. Most states just operate in a circular motion, cycling through all regular states, except when the maintenance mode is active.

=== Part 2: Pedestrian Traffic
#mermaid-figure(
  read("part2.mmd"),
  caption: [Pedestrian Traffic Controller State Transition Diagram],
  width: 85%,
)

#figure(
  image("part2.jpeg", width: 85%),
  caption: [Pedestrian Traffic Controller Circuit],
)

The pedestrian crossing rules described above were determined to be safe through a few intuitive verifications.
- The first safety concern is that a pedesrian may be permitted to cross when that street's traffic has not been stopped. This is not a concern since when the pedestrian light turns on the corresponding street's red light also turns on.
- The second concern is if the lights respond immediately to the pedestrian pressing the button, a red light may activate without warning (no pale green light) and cause more accidents. This is addressed by the fact that the pedestrian light only turns on after the current red or green light phase has completed.
- A third issue, is if after the pedestrian light turns off that the traffic lights for the two streets become desyncronized. However, because both streets' lights use the same timings in their logic, they never get out of sync to begin with. Since the specified pedestrian crossing time is 60 seconds which is less than the total red cycle time of 70s, the interuption in the light cycle from the pedestrian light never exceeds one period.
- A fourth concern, while more related to the management of heavy traffic such as during rush hour than explicitly saftey, is that if when a pedestrian crosses, all traffic is stopped for the allotted 60 seconds, traffic jams may increase unnecessarily  regardless if their paths intersect. This is also not an issue since traffic on the opposite street is allowed to continue normally.
- In a similar light, if pedestrians could retrigger the pedestrian light within the interval of the first press, then traffic could be interupted for far longer than 60 seconds. Since the predestrian crossing button is only responsive to one press at a time, it fairly alternates between pedestrians crossing, and vehicles driving through the intersection.
- The last concern is a matter of robustness. Namely, if pedestrians happen to press their respective buttons simultaneously, there is a contigency in place that gives priority over to the pedestrian crossing street A.

= Conclusions

== Techniques learned
- We learned how to use C++ (through Arduino IDE) in a more complex scenario, using more of the languages features
- We got experience overloading operators in C++ and defining custom enums for implementing the state transitions
- We got experience with working with buttons, learning how to connect them to the Arduino and read their digital values

== Assignment Feedback
- This assignment was feasible to complete before the deadline
- The timing diagram in Part 1's PDF was different from the textual explanation above, making initial implementation confusing
- The date on Canvas (prior to the announcement) listed at 2023 deadline, adding some confusion about when the assignment would be due
- There was no "Arduino Hat" as described in the Lab instructions, adding some confusion
  - We used the raw arduino pins to handle this shortcoming

= Demo
We uploaded our demo online as it was performed outside of standard lab hours. You can find our demo here: https://drive.google.com/drive/folders/1Ge1S0vGDlnULTEumr6zLJCX-vTABJKOA?usp=sharing

== Explanation
For both pedestrian buttons, yellow LEDs were used to indicate that the pedestrian could cross. It is not safe to cross until the traffic has stopped for that road. This is guaranteed to be true when both lights are on their 'red' state. We also had the builtin LED turn on to indicate a pedestrian crossing, but this is slightly obscured by a wire connected to the arduino.
- First, we pressed the cross walk for street a, which turned on the builtin LED and the corresponding yellow LED once it was safe
- Second, we pressed the cross walk for street b, which turned on the builtin LED and the other yellow LED
- Finally, we pressed the maintenance button, which waits until the lights are both red so it is safe before freezing the cycle in that state
  - This button acts as a toggle, so the cycle is not resumed until the button is pressed again, as shown at the end
- The cycles in the demo are significantly shorter than those in the submitted code to prevent the submitted video from being very long and large

= Notes
- We debugged using ```cpp Serial.println(...)```, but this needed ```cpp Serial.begin()``` at the top of ```cpp setup()```
  - This was used to read the button value during execution
  - We viewed these debug logs by opening the serial monitor at 'Tools -> Serial Monitor'
- The pins on the Arduino with a `~` next to them can be used for digital PWM, which we used to connect out green LEDs to
- Using the builtin LED meant that pin 13's state was tied to its output, resulting in us having to switch to pin 11 for the other pedestrian LED
- The arduino has a button on it that, when pressed, resets the uploaded firmware
  - This doensn't clear the firmware from the board but seems to have the same effect as recompiling and reuploading the sketch from scratch
- Sketches in Arduino IDE must have the same name as their parent folder, and the IDE will reject opening sketches that were not laid out in this way
- We tested our work in a few ways:
  - Pressing multiple buttons at the same time -> resulted in no conflicting states due to sequential state machine implementation
  - Pressing maintenance mode at any stage in the state transitions correctly waited until a safe state was reached
  - LEDs were visually verified against their expected behavior
