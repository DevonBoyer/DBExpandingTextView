# DBExpandingTextView

![alt tag](https://cloud.githubusercontent.com/assets/5367914/6086748/2b59b470-ae12-11e4-8b18-e944aa6fc7af.png)

####What is this repository for?####

A text view that will expand and compress to fit the currently composed text until it reaches it's
the maximum height. It also contains support for a placeholder.

####Supports####

iOS 7.0+

####How do I get set up?####

#####Autolayout#####
- Do not use 'NSLayoutAttributeHeight' constraints since the text view expands and compresses as needed, which will continuously cause the constraint to break. Instead use 'NSLayoutAttributeTop' and 'NSLayoutAttributeBottom'


