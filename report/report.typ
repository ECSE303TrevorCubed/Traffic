#import "@preview/merman:0.6.0": mermaid-figure

#show link: set text(fill: blue)
#show title: set text(size: 17pt)
#show title: set align(center)

#title[
  ECSE303 Lab Assignment 6 \
  Kernel Modules
]
#align(center)[Trevor Swan, Justin Fossum, Trevor Nichols]

#set heading(numbering: "1.")

= Assignment Statement and Objective
The main objective of this assignment is to design and emulate a traffic controller at a hypothetical intersection of two one-way streets, named A and B. This task is achieved through the use of an Arduino Uno micro controller and corresponding custom breadboard circuit to control red and green LED lights that are to represent this hypothetical intersection's traffic lights. In order to keep the scope of this endeavor manageable, two assumptions were made. Firstly, no turns are allowed on either street, meaning the hypothetical vehicles pass straight through the intersection. Secondly, the traffic light is capable of only showing solid green or solid red, meaning yellow lights or flashing lights in general are not considered.

To accommodate the traffic controller's lack of yellow light functionality, the green light is to be dimmed for 10 seconds prior to turning red to inform drivers of the upcoming light change. Additionally, with safety in mind, an additional delay of 10 seconds is added to the end of the red lights interval. This ensures a period of time where the red lights for both streets are simultaneously on, reducing the likelihood of collisions if a vehicle happens to run through a recently switched on red light. With these considerations, the light timings are: 70 seconds red, 50 seconds green, 10 seconds dimmed green. Street A and B alternate these timings every one minute. In the situation where the traffic light is under maintenance, a toggle was implemented that, if engaged, activates both red lights, signaling to traffic that the intersection is closed. To accommodate the crossing of pedestrians, functionality was added that lets a pedestrian who's intent on crossing press a button. When the button is pressed, a dedicated pedestrian light turns on once

// TODO(Justin): Finish above section

= Methodology and Steps

== Part 1: One-way Traffic
#mermaid-figure(
  read("part1.mmd"),
  caption: [One-way Traffic Controller State Transition Diagram],
)

== Part 2: Pedestrian Traffic
#mermaid-figure(
  read("part2.mmd"),
  caption: [Pedestrian Traffic Controller State Transition Diagram],
)

= Results and Observations

=== Part 1: One-way Traffic
#figure(
  image("part1.jpeg", width: 85%),
  caption: [One-way Traffic Controller Circuit],
)

=== Part 2: Pedestrian Traffic
#figure(
  image("part2.jpeg", width: 85%),
  caption: [Pedestrian Traffic Controller Circuit],
)

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

= Notes
- We debugged using ```cpp Serial.println(...)```, but this needed ```cpp Serial.begin()``` at the top of ```cpp setup()```
  - This was used to read the button value during execution
- The pins on the Arduino with a `~` next to them can be used for digital PWM, which we used to connect out green LEDs to
- Using the builtin LED meant that pin 13's state was tied to its output, resulting in us having to switch to pin 11 for the other pedestrian LED
