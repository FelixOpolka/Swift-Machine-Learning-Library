# Digit Recognition Example

This example is a small iOS App allowing you to train networks to recognize
handwritten digits drawn onscreen. You can create your own data sets by drawing
multiple samples for each digit (that's a bit tedious but less effort than you
might think) and train neural networks with different parameters using these
data sets. Once trained, you can test them in action by letting them recognize
new digits you draw on your screen.


## Usage

> **How do I create a new data set?**

Before you can train your first network, you will have to create a data set. You can do this by pressing "Data Sets" in the main menu that shows up right after starting the app. Add a new data set by pressing "+" and give it any name you like. By selecting the data set you reach the drawing area, which you can draw digits in. To add a sample you have drawn, press the digit button in the bottom row which corresponds to your drawing.

> **How many samples do I need?**

That may depend on what results you expect. I have found that entering 100-200
samples (in total) is sufficient, though you might achieve better results by
entering more samples. Entering 100 digits takes about 5 minutes; it helps when
you consider it meditation.

> **How do I create and train a network?**

In the main menu, just press the plus button, specify some parameters, select
the network and hit "Train". Again specify some parameters for training and off
we go. Please note that in the current state of the app, the network's
performance after each epoch is only printed to the console (I will change that
soon).

> **Which parameter values work well?**

I have found that using a network with 35 hidden units on a data set of ~150
samples in total achieves a reasonable performance after about 400 epochs of
training. I think the biggest impediment to a better performance is the
preprocessing which is rather naive in the current state of the app. It crops
the drawing to its bounding box and scales it to size 28x28. I aim to replace it
with a more elaborate method soon.

> **How do I use/ test a network?**

That's simple: Select the network and start drawing. Press "Recognize" to
politely ask the network to recognize your digit. It hopefully highlights the
correct digit in the bottom line of the screen.


## Features

Here is a list of features already implemented and some features I plan to add
in the future:

  - [x] Custom data sets
  - [x] Networks with adjustable number of hidden units
  - [x] Network training with adjustable number of epochs and user-selected data
  set
  - [x] Network testing in action
  - [ ] Better preprocessing
  - [ ] More adjustable parameters (learning rate, minibatch size)
  - [ ] Better logging
  - [ ] Custom test sets
  - [ ] Different network architectures
  - [ ] Cross-entropy error function and softmax activation (or adjustable of
    course)
