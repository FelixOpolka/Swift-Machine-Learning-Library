# Swift Machine Learning Library
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/FelixOpolka/Swift-Machine-Learning-Library/blob/master/LICENSE)

The Swift Machine Learning Library (SMLL, pronounced *"small"*) is meant to provide various machine learning tools written in Swift with support for iOS and mac OS. For now, it is just a personal project I use as a space to implement algorithms which I have learned about so far. Nevertheless, I give my best to do so in a sensible way in order to be able to make some use of it in the future.

## Features

The library bears a pretty fancy name which is by far not justified in its current state. But as I learn more about machine learning I plan to extend this library with more and more features. You can see a list of feature already implemented and a rough outline of what is planned to be added next:

  - [x] Matrix Library using SIMD (GPU accelerated) instructions via Apple's Accelerate framework
  - [x] Feedforward Neural Network trained using backpropagation
  - [ ] Convolutional Network

## Examples

For demonstrating the usage of the library, different kinds of example applications should be provided. The following projects are already implemented or planned to be added:

  - [x] Recognition of handwritten digits using the MNIST-dataset (see [MNISTExample](https://github.com/FelixOpolka/Swift-Machine-Learning-Library/tree/master/Examples/MNISTExample))
  - [ ] Handwriting-recognition on iOS
