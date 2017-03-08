//
//  SMLLOperators.swift
//  Swift Machine Learning Library
//
//  Created by Felix Opolka on 16.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//

import Foundation
import Accelerate

/**
 Addition of two matrices of the same size.
 */
public func + (leftMatrix: SMLLMatrix, rightMatrix: SMLLMatrix) -> SMLLMatrix {
    assert(leftMatrix.rows == rightMatrix.rows && leftMatrix.columns == rightMatrix.columns, "Trying to add matrices of different sizes")
    var resultMatrix = SMLLMatrix(rows: leftMatrix.rows, columns: leftMatrix.columns)
    vDSP_vaddD(leftMatrix.elements, 1, rightMatrix.elements, 1, &resultMatrix.elements, 1, vDSP_Length(resultMatrix.elements.count))
    
    return resultMatrix
}


/**
 Adds every element of the given matrix and a scalar.
 */
public func + (leftScalar: Double, rightMatrix: SMLLMatrix) -> SMLLMatrix {
    var result = SMLLMatrix(rows: rightMatrix.rows, columns: rightMatrix.columns)
    var scalar = leftScalar
    vDSP_vsaddD(rightMatrix.elements, 1, &scalar, &result.elements, 1, vDSP_Length(result.elements.count))
    return result
}


/**
 Subtraction of two matrices of the same size.
 */
public func - (leftMatrix: SMLLMatrix, rightMatrix: SMLLMatrix) -> SMLLMatrix {
    assert(leftMatrix.rows == rightMatrix.rows && leftMatrix.columns == rightMatrix.columns, "Trying to subtract matrices of different sizes")
    var resultMatrix = SMLLMatrix(rows: leftMatrix.rows, columns: leftMatrix.columns)
    // Left and right matrix need to be switched to achieve a correct result
    vDSP_vsubD(rightMatrix.elements, 1, leftMatrix.elements, 1, &resultMatrix.elements, 1, vDSP_Length(resultMatrix.elements.count))
    return resultMatrix
}


/**
 Subtracts every element of the given matrix from a scalar.
 */
public func - (leftScalar: Double, rightMatrix: SMLLMatrix) -> SMLLMatrix {
    return leftScalar + (-rightMatrix)
}


/**
 Element-wise negation of the given matrix.
 */
public prefix func - (matrix: SMLLMatrix) -> SMLLMatrix {
    var resultMatrix = SMLLMatrix(rows: matrix.rows, columns: matrix.columns)
    vDSP_vnegD(matrix.elements, 1, &resultMatrix.elements, 1, vDSP_Length(resultMatrix.elements.count))
    return resultMatrix
}


/**
 Divide every element of the matrix by a scalar double value.
 */
public func / (leftMatrix: SMLLMatrix, rightScalar: Double) -> SMLLMatrix {
    assert(rightScalar != 0, "Trying to divide by 0")
    var result = SMLLMatrix(rows: leftMatrix.rows, columns: leftMatrix.columns)
    var scalar = rightScalar
    vDSP_vsdivD(leftMatrix.elements, 1, &scalar, &result.elements, 1, vDSP_Length(leftMatrix.elements.count))
    return result
}


/**
 Returns a matrix resulting from dividing a scalar by the corresponding element of the given matrix.
 - Warning: No entry of the given matrix must be `0.0`.
 */
public func / (leftScalar: Double, rightMatrix: SMLLMatrix) -> SMLLMatrix {
    
    var result = SMLLMatrix(rows: rightMatrix.rows, columns: rightMatrix.columns)
    var scalar = leftScalar
    vDSP_svdivD(&scalar, rightMatrix.elements, 1, &result.elements, 1, vDSP_Length(result.elements.count))
    return result
}


/**
 Multiply every element of the matrix by a scalar double value.
 */
public func * (leftMatrix: SMLLMatrix, rightScalar: Double) -> SMLLMatrix {
    var result = SMLLMatrix(rows: leftMatrix.rows, columns: leftMatrix.columns)
    var scalar = rightScalar
    vDSP_vsmulD(leftMatrix.elements, 1, &scalar, &result.elements, 1, vDSP_Length(leftMatrix.elements.count))
    return result
}


/**
 SMLLMatrixmultiplication of two matrices
 */
public func * (leftMatrix: SMLLMatrix, rightMatrix: SMLLMatrix) -> SMLLMatrix {
    assert(leftMatrix.columns == rightMatrix.rows, "The left matrix' number of columns (\(leftMatrix.columns)) does not match the right matrix' number of rows (\(rightMatrix.rows))")
    var resultMatrix = SMLLMatrix(rows: leftMatrix.rows, columns: rightMatrix.columns)
    vDSP_mmulD(leftMatrix.elements, 1, rightMatrix.elements, 1, &resultMatrix.elements, 1, vDSP_Length(leftMatrix.rows), vDSP_Length(rightMatrix.columns), vDSP_Length(leftMatrix.columns))
    return resultMatrix
}


/**
 Hadamad-Product of two matrices
 */
infix operator ○ : MultiplicationPrecedence
public func ○ (leftMatrix: SMLLMatrix, rightMatrix: SMLLMatrix) -> SMLLMatrix {
    assert(leftMatrix.rows == rightMatrix.rows && leftMatrix.columns == rightMatrix.columns, "Trying to calculate the Hadamad product of two matrices of different sizes")
    var result = SMLLMatrix(rows: leftMatrix.rows, columns: leftMatrix.columns)
    vDSP_vmulD(leftMatrix.elements, 1, rightMatrix.elements, 1, &result.elements, 1, vDSP_Length(result.elements.count))
    
    return result
}


/**
 Performs a convolution on the given signal matrix using the given kernel (must have odd dimensions). Kernel does not extend beyond the boundaries of the signal matrix, therefore the resulting matrix is smaller than signal matrix (``result.rows = signal.rows - kernel.rows + 1`` and ``result.columns = signal.columns - kernel.columns + 1``)
 */
public func convolute(signalMatrix: SMLLMatrix, kernelMatrix: SMLLMatrix) -> SMLLMatrix {
    var result = SMLLMatrix(mirrorShapeOf: signalMatrix)
    vDSP_imgfirD(signalMatrix.elements, vDSP_Length(signalMatrix.rows), vDSP_Length(signalMatrix.columns), kernelMatrix.elements, &result.elements, vDSP_Length(kernelMatrix.rows), vDSP_Length(kernelMatrix.columns))
    
    // Cut borders
    let verticalBorderWidth = (kernelMatrix.columns-1)/2
    let horizontalBorderWidth = (kernelMatrix.rows-1)/2
    let elementsWithoutBorders = result.elements.enumerated().filter({(index, element) in
        let notTopBorder = index >= (horizontalBorderWidth*result.columns)
        let notBottomBorder = index < (result.elements.count - (horizontalBorderWidth*result.columns))
        let notLeftBorder = index % result.columns >= verticalBorderWidth
        let notRightBorder = index % result.columns < (result.columns-verticalBorderWidth)
        return notTopBorder && notBottomBorder && notLeftBorder && notRightBorder
    }).map({(index, element) in
        return element
    })
    return SMLLMatrix(rows: result.rows-2*horizontalBorderWidth, columns: result.columns-2*verticalBorderWidth, values: elementsWithoutBorders)
}


/**
 The element-wise exponential of a given matrix
 */
public func exp(_ matrix: SMLLMatrix) -> SMLLMatrix {
    var result = SMLLMatrix(rows: matrix.rows, columns: matrix.columns)
    vvexp(&result.elements, matrix.elements, [Int32(result.elements.count)])
    return result
}
