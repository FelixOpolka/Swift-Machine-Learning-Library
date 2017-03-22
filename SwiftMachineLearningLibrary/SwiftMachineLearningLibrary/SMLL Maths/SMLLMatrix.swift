//
//  SMLLMatrix.swift
//  Swift Machine Learning Library
//
//  Created by Felix Opolka on 16.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//
import Foundation
import Accelerate

public enum SMLLMatrixError: Error {
    case invalidIOData(dataIdentifier: String)
}

public enum SMLLVectorShape {
    case columnVector, rowVector
}

public struct SMLLMatrix: CustomStringConvertible {
    
    /// Number of rows and columns of the matrix.
    public let rows: Int, columns: Int
    /// The elements the matrix comprises.
    public var elements: [Double]
    /// Description-String representing the matrix in text.
    public var description: String {
        // Implementation adapted from github.com/mattt/Surge/blob/master/Source/Matrix.swift on 16/May/2016
        var description = ""
        for i in 0..<rows {
            let contents = (0..<columns).map{"\(self[i, $0])"}.joined(separator: "\t")
            switch (i, rows) {
            case (0, 1):
                description += "(\t\(contents)\t)"
            case (0, _):
                description += "⎛\t\(contents)\t⎞"
            case (rows - 1, _):
                description += "⎝\t\(contents)\t⎠"
            default:
                description += "⎜\t\(contents)\t⎥"
            }
            description += "\n"
        }
        return description
    }
    
    
    // MARK: - Initializers
    
    /**
     Initializes a matrix of the given shape with all elements set to `repeatedValue` which defaults to `0.0`.
     */
    public init(rows: Int, columns: Int, repeatedValue: Double = 0.0) {
        self.rows = rows
        self.columns = columns
        elements = Array (repeating: repeatedValue, count: rows*columns)
    }
    
    
    /**
     Initializes a matrix of the given shape with the elements stored in `values`. The number of elements in `values` must match `rows`*`columns`.
     */
    public init(rows: Int, columns: Int, values: [Double]) {
        self.rows = rows
        self.columns = columns
        self.elements = values
    }
    
    
    /**
     Initializes a matrix of the given shape with a sequence of whole numbers starting at `1.0.
     */
    public init(rows: Int, columns: Int, sequence: Bool) {
        self.rows = rows
        self.columns = columns
        elements = Array (repeating: 0.0, count: rows*columns)
        for rowIndex in 0..<rows {
            for columnIndex in 0..<columns {
                elements[(rowIndex * columns) + columnIndex] = (Double)((rowIndex * columns) + columnIndex) + 1.0
            }
        }
    }
    
    
    /**
     Initializes a matrix of the given shape with normal random values.
     */
    public init(normalRandomValuesMatrixWithRows rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        elements = [Double]()
        for _ in 0..<(rows*columns) {
            elements.append(SMLLMathUtilities.normalRandomValue())
        }
    }
    
    
    /**
     Initializes a matrix of the given shape (column or row vector) with a secondary dimension of `numberOfElements` and set all elements to `repeatedValue` which defaults to `0.0`.
     */
    public init(vectorShape: SMLLVectorShape, numberOfElements: Int, repeatedValue: Double = 0.0) {
        if vectorShape == .columnVector {
            self.rows = numberOfElements
            self.columns = 1
        } else {
            self.rows = 1;
            self.columns = numberOfElements
        }
        elements = [Double]()
        for _ in 0..<(rows*columns) {
            elements.append(repeatedValue)
        }
    }
    
    
    /**
     Initializes a matrix of the given shape (column or row vector) with the elements stored in `values`.
     */
    public init(vectorShape: SMLLVectorShape, values: [Double]) {
        if vectorShape == .columnVector {
            self.rows = values.count
            self.columns = 1
        } else {
            self.rows = 1;
            self.columns = values.count
        }
        elements = values
    }
    
    
    /**
     Initializes a matrix of the given shape (column or row vector) with normal random values.
     */
    public init(normalRandomValuesMatrixWithVectorShape vectorShape: SMLLVectorShape, numberOfElements: Int) {
        if vectorShape == .columnVector {
            self.rows = numberOfElements
            self.columns = 1
        } else {
            self.rows = 1;
            self.columns = numberOfElements
        }
        elements = [Double]()
        for _ in 0 ..< numberOfElements {
            elements.append(SMLLMathUtilities.normalRandomValue())
        }
    }
    
    
    /**
     Initializes a vector with all-zero components except for one which is set to 1.0 (often referred to a "versor").
     - Parameters:
        - component: Index of the non-zero component.
        - vectorShape: Shape of the vector; either column or row vector.
        - numberOfElements: Dimension of the vector.
     */
    public init(versorWithNonZeroComponent component: Int, vectorShape: SMLLVectorShape, numberOfElements: Int) {
        self.init(vectorShape: vectorShape, numberOfElements: numberOfElements, repeatedValue: 0.0)
        elements[component] = 1.0
    }
    
    
    /**
     Initializes a matrix with the shape of a given matrix and sets all elements to `repeatedValue` which defaults to `0.0`.
     */
    public init(mirrorShapeOf shapeModel: SMLLMatrix, repeatedValue: Double = 0.0) {
        self.rows = shapeModel.rows
        self.columns = shapeModel.columns
        elements = Array(repeating: repeatedValue, count: rows*columns)
    }
    
    
    /**
     Initializes a matrix with the shape of a given matrix and the given values.
     */
    public init(mirrorShapeOf shapeModel: SMLLMatrix, values: [Double]) {
        assert(values.count == shapeModel.rows * shapeModel.columns, "Values are not compatible with matrix shape.")
        self.rows = shapeModel.rows
        self.columns = shapeModel.columns
        elements = values
    }
    
    
    /**
     Initializes a matrix from a given storage dictionary.
     */
    public init(ioRepresentation: NSDictionary) throws {
        if let rows = (ioRepresentation.value(forKey: "Rows") as? Int) {
            self.rows = rows
        } else { throw SMLLMatrixError.invalidIOData(dataIdentifier: "Rows") }
        
        if let columns = (ioRepresentation.value(forKey: "Columns") as? Int) {
            self.columns = columns
        } else { throw SMLLMatrixError.invalidIOData(dataIdentifier: "Columns") }
        
        if let elements = (ioRepresentation.value(forKey: "Elements") as? [Double]) {
            self.elements = elements
        } else { throw SMLLMatrixError.invalidIOData(dataIdentifier: "Elements") }
    }
    
    
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValidForRow(row, column: column), "Index \(row),\(column) out of range")
            return elements[(row*columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index \(row),\(column) out of range")
            elements[(row*columns) + column] = newValue
        }
    }
    
    
    // MARK: - Mathematical operations
    
    public func transpose () -> SMLLMatrix {
        var transposedMatrix = SMLLMatrix(rows: columns, columns: rows)
        vDSP_mtransD(elements, 1, &transposedMatrix.elements, 1, vDSP_Length(transposedMatrix.rows), vDSP_Length(transposedMatrix.columns))
        return transposedMatrix
    }
    
    
    public func transposeValueForRow (_ row: Int, column: Int) -> Double {
        return self[column, row]
    }
    
    
    /**
     Returns the index of the maximum element inside the matrix.
     */
    public func maxValueAndIndex() -> (value: Double, row: Int, column: Int) {
        var maxIndex = vDSP_Length()
        var maxValue = 0.0
        vDSP_maxviD(elements, 1, &maxValue, &maxIndex, vDSP_Length(elements.count))
        
        return (maxValue, (Int)(maxIndex) / columns, (Int)(maxIndex) % columns)
    }
    
    /**
     Returns the index of the maximum element inside the matrix.
     */
    public func maxIndex() -> (row: Int, column: Int) {
        let (_, row, column) = maxValueAndIndex()
        return (row, column)
    }
    
    
    /**
     Returns the submatrix one receives when cutting the given borders on each side.
     */
    public func submatrix(byCuttingTopBorderOfWidth topBorderWidth: Int, bottomBorderWidth: Int, leftBorderWidth: Int, rightBorderWidth: Int) -> SMLLMatrix {
        let rowStartIndex = topBorderWidth
        let columnStartIndex = leftBorderWidth
        let height = rows - topBorderWidth - bottomBorderWidth
        let width = columns - leftBorderWidth - rightBorderWidth
        var result = SMLLMatrix(rows: height, columns: width)
        elements.withUnsafeBufferPointer({bufferPointer in
            vDSP_mmovD(bufferPointer.baseAddress!+(rowStartIndex*columns)+columnStartIndex, &result.elements, vDSP_Length(width), vDSP_Length(height), vDSP_Length(columns), vDSP_Length(width))
        })
        return result
    }
    
    
    /**
     Converts the matrix in a vector of given shape.
     */
    public func toMatrix(ofVectorShape vectorShape: SMLLVectorShape) -> SMLLMatrix {
        return SMLLMatrix(vectorShape: vectorShape, values: elements)
    }
    
    
    /**
     Reverses each row of this matrix.
     */
    public mutating func reverseRows() {
        for rowIndex in 0..<rows {
            vDSP_vrvrsD(&elements+(rowIndex*columns), vDSP_Stride(1), vDSP_Length(columns))
        }
    }
    
    
    /**
     Reverses each column of this matrix.
     */
    public mutating func reverseColumns() {
        for columnIndex in 0..<columns {
            vDSP_vrvrsD(&elements+columnIndex, vDSP_Stride(columns), vDSP_Length(rows))
        }
    }
    
    
    /**
     Rotates this matrix by 90 degrees clockwise.
     */
    public mutating func rotatePlus90Degrees() {
        self = self.transpose()
        self.reverseRows()
    }
    
    
    /**
     Rotates this matrix by 90 degrees anti-clockwise.
     */
    public mutating func rotateMinus90Degrees() {
        self = self.transpose()
        self.reverseColumns()
    }
    
    
    /**
     Rotates this matrix by 180 degrees clockwise.
     */
    public mutating func rotate180Degrees() {
        self.reverseRows()
        self.reverseColumns()
    }
    
    
    /**
     Returns the value and index of the maximum component in a given submatrix.
     */
    public func maxValueAndIndexOfRegion(rowStartIndex: Int, columnStartIndex: Int, width: Int, height: Int) -> (value: Double, row: Int, column: Int) {
        let region = submatrix(byCuttingTopBorderOfWidth: rowStartIndex, bottomBorderWidth: rows-rowStartIndex-height, leftBorderWidth: columnStartIndex, rightBorderWidth: columns-columnStartIndex-width)
        return region.maxValueAndIndex()
    }

    
    public func map(transform: (Double) -> Double) -> SMLLMatrix {
        return SMLLMatrix(mirrorShapeOf: self, values: elements.map(transform))
    }
    
    // - Private methods
    
    fileprivate func indexIsValidForRow (_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    
    // MARK: - Storage methods
    
    public func getIORepresentation() -> NSDictionary {
        let ioRepresentation = NSMutableDictionary()
        ioRepresentation.setValue(rows, forKey: "Rows")
        ioRepresentation.setValue(columns, forKey: "Columns")
        ioRepresentation.setValue(NSArray(array: elements), forKey: "Elements")
        
        return ioRepresentation
    }
}


extension SMLLMatrix: Equatable {}
public func == (lhs: SMLLMatrix, rhs: SMLLMatrix) -> Bool {
    return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.elements == rhs.elements
}
