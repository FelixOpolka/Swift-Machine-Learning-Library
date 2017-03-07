//
//  SMLLLayer.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 06.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Corresponds to one layer of the network along with the connections leading into the layer (i.e. connections "in front of the layer" not "behind the layer").
 */
protocol SMLLLayer {
    
    /**
     Number of neurons in the layer.
     */
    var neuronCount: Int { get }
    
    
    /**
     Feeds a given input vector through the layer by combining the input with the layer's weights and biases and performing further computation.
     - Parameters:
        - input: Input to the layer. Can be output of a previous layer or input to the network.
     - Returns: The layer's computation output.
     */
    func forwardPropagate(input: SMLLMatrix) -> SMLLMatrix
    
    
    /**
     Calculates the layer's gradients given the error in the successive layer or the overall network error/ cost (if this layer is the network's output layer) and adds them to the total gradients. Total gradients can later be used to adjust the layer's parameters (refer to ``adjustParameters``).
     - Parameters:
        - successiveLayerError: Error in parameters of successive layer or the overall network error/ cost if this layer is the network's output layer.
     - Returns: Error in this layer.
     */
    func updateTotalGradients(successiveLayerError: SMLLMatrix) -> SMLLMatrix
    
    
    /**
     Adjusts the layer's parameters by adding a delta value dependent on the total gradients calculated in previous calls of ``updateTotalGradients``: ``param = param + stepCalculation(totalParamGradient)``
     - Parameters:
        - stepCalculation: Function for calculation the step for each parameter given the total gradient for this parameter.
     */
    func adjustParameters(stepCalculation: (SMLLMatrix) -> SMLLMatrix)
}
