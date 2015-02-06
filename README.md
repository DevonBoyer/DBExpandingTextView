# DBExpandingTextView

![alt tag](https://cloud.githubusercontent.com/assets/5367914/6086799/9acf5ae4-ae12-11e4-90ca-9bb60f5854cd.png)

####What is this repository for?####

A text view that will expand and compress to fit the currently composed text until it reaches a
maximum height. It also contains support for a placeholder.

####Supports####

Written in Swift.
iOS 7.0+

####How do I get set up?####

#####Autolayout#####
- Do not use 'NSLayoutAttributeHeight' constraints since the text view expands and compresses as needed, which will continuously cause the constraint to break. Instead use 'NSLayoutAttributeTop' and 'NSLayoutAttributeBottom'


