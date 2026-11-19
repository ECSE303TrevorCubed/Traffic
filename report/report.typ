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
The main objective of this assignment is to

== Summary of Contents

= Methodology and Steps

== Part 1: One-way Traffic
1. 

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
