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
The main objective of this assignment is to design and emulate a traffic controller at a hypothetical intersection of two one-way streets, named A and B. This task is acheived through the use of an Arduino Uno microcontroller and corresponding custom breadboard circut to control red and green LED lights that are to represent this hypotetical intersection's traffic lights. In order to keep the scope of this endeavor managable, two assumptions were made. Firstly, no turns are allowed on either street, meaning the hypotetical vehicles pass straight through the intersection. Secondly, the traffic light is capabale of only showing solid green or solid red, meaning yellow lights or flashing lights in general are not considered.

To accomodate the traffic controller's lack of yellow light functionality, the green light is to be dimmed for 10 seconds prior to turning red to inform drivers of the upcomming light change. Additonally, with saftey in mind, an additional delay of 10 seconds is added to the end of the red lights interval. This ensures a period of time where the red lights for both streets are simulaneously on, reducing the likelyhood of collisions if a vehicle happens to run through a recently switched on red light. With these considerations, the light timings are: 70 seconds red, 50 seconds green, 10 seconds dimmed green. Street A and B alternate these timings every one minute. In the situation where the traffic light is under maintanence, a toggle was implemented that, if engaged, activates both red lights, signaling to traffic that the intersection is closed. To allow pedestrians to safely cross


= Methodology and Steps

== Part 1: One-way Traffic
1.jnlknlkk




== Part 2: Pedestrian Traffic
1.

= Results and Observations

=== Part 1: One-way Traffic
#figure(
  image("part1.jpeg", width: 85%),
  caption: [One-way Traffic Controller Circuit],
)



=== Part 2: Pedestrian Traffic
// #figure(
//   image("part2.jpeg", width: 85%),
//   caption: [Pedestrian Traffic Controller Circuit],
// )

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

= Notes
- We debugged using ```cpp Serial.println(...)```, but this needed ```cpp Serial.begin()``` at the top of ```cpp setup()```
    - This was used to read the button value during execution
- The pins on the Arduino with a `~` next to them can be used for digital PWM, which we used to connect out green LEDs to
