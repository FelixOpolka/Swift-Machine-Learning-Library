# Swift Machine Learning Library
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/FelixOpolka/Swift-Machine-Learning-Library/blob/master/LICENSE)

The Swift Machine Learning Library (SMLL) is a small collection of machine learning algorithms written in Swift with support for iOS and macOS. SMLL is not meant to be a competitive machine learning library but rather a learning space for implementing ML algorithms. I hope the library proves useful as a resource for other as well. All algorithms are implemented from scratch and do not use any third-party libraries. Moreover, Swift is a very intuitive programming language without much high-level magic going on, so one can easily comprehend what's going on.

## Features

The library bears a pretty fancy name which is by far not justified in its current state. But as I learn more about machine learning I plan to extend this library with more and more features. You can see a list of features already implemented and a rough outline of what is planned to be added next:

  - [x] Matrix Library using SIMD (GPU accelerated) instructions via Apple's Accelerate framework
  - [x] Feedforward Neural Network trained using backpropagation
  - [x] Convolutional Network
  - [x] Numeric Gradient Checks
  - [ ] Recurrent Networks

## Examples

To demonstrate the usage of the library, I have provided some examples that make use of the its functionality. The following projects are already implemented or planned to be added:

  - [x] Recognition of handwritten digits using the MNIST-dataset (see [MNISTExample](https://github.com/FelixOpolka/Swift-Machine-Learning-Library/tree/master/Examples/MNISTExample))
  - [x] Handwriting-recognition on iOS (see [DigitRecognition](https://github.com/FelixOpolka/Swift-Machine-Learning-Library/tree/master/Examples/DigitRecognition))
