//
//  SMLLLayer.swift
//  SwiftMachineLearningLibrary
//
//  Created by Felix Opolka on 06.03.17.
//  Copyright © 2017 Felix Opolka. All rights reserved.
//

import Foundation

/**
 Corresponds to one layer of the network along with the connections leading into the layer (i.e. connections "in front" of the layer not "behind" the layer).
 */
public protocol SMLLLayer {
    
    /**
     Shape of the output the layer produces.
     */
    var outputShape: SMLLLayerShape { get }
    
    
    /**
     Shape of the input the layer receives from previous layers. This property is set by the encapsulating network in correspondance with the previous layer.
     */
    var inputShape: SMLLLayerShape! { get set }
    
    
    /**
     Feeds a given input vector through the layer by performing computation determined by the type of the layer (e.g. combining the input with the layer's weight and biases, convolution or pooling).
     - Parameters:
        - input: Input to the layer. Can be output of a previous layer or input to the network (via input layer). Shape must correspond to `inputShape`.
     - Returns: The layer's computation output.
     */
    func forwardPropagate(input: [SMLLMatrix]) -> [SMLLMatrix]
    
    
    /**
     Calculates the layer's gradients given the error in the output of the layer and adds them to the total gradients. Total gradients can later be used to adjust the layer's parameters (refer to ``adjustParameters``).
     - Parameters:
        - layerOutputError: Error in outputs of this layer.
     - Returns: Error in output of previous layer.
     */
    func updateTotalGradients(layerOutputError: [SMLLMatrix]) -> [SMLLMatrix]
    
    
    /**
     Adjusts the layer's parameters by adding a delta value depending on the total gradients calculated in previous calls of ``updateTotalGradients``: ``param = param + stepCalculation(totalParamGradient)``
     - Parameters:
        - stepCalculation: Function for calculation the step for each parameter given the total gradient for this parameter.
     */
    func adjustParameters(stepCalculation: (SMLLMatrix) -> SMLLMatrix)
}
