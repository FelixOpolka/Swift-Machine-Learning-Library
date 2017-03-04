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

public enum SMLLMatrixShape {
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
    public init(rows: Int, columns: Int, normalRandomValues: Bool) {
        self.rows = rows
        self.columns = columns
        elements = [Double]()
        for _ in 0..<(rows*columns) {
            elements.append(normalRandomValue())
        }
    }
    
    
    /**
     Initializes a matrix of the given shape (column or row vector) with a secondary dimension of `numberOfElements` and set all elements to `repeatedValue` which defaults to `0.0`.
     */
    public init(shape: SMLLMatrixShape, numberOfElements: Int, repeatedValue: Double = 0.0) {
        if shape == .columnVector {
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
    public init(shape: SMLLMatrixShape, values: [Double]) {
        if shape == .columnVector {
            self.rows = values.count
            self.columns = 1
        } else {
            self.rows = 1;
            self.columns = values.count
        }
        elements = values
    }
    
    
    /**
     Initializes a vector with all-zero components except for one which is set to 1.0 (often referred to a "versor").
     - Parameters:
        - component: Index of the non-zero component.
        - shape: Shape of the vector; either column or row vector.
        - numberOfElements: Dimension of the vector.
     */
    public init(versorWithNonZeroComponent component: Int, shape: SMLLMatrixShape, numberOfElements: Int) {
        self.init(shape: shape, numberOfElements: numberOfElements, repeatedValue: 0.0)
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
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return elements[(row*columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
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
    public func maxIndex() -> (row: Int, column: Int) {
        var maxIndex = vDSP_Length()
        var maxValue = 0.0
        vDSP_maxviD(elements, 1, &maxValue, &maxIndex, vDSP_Length(elements.count))
        
        return ((Int)(maxIndex) / columns, (Int)(maxIndex) % columns)
    }
    
    
    /**
     Returns a submatrix specified by an index rectangle.
     */
    public func submatrixFromRowStart (_ rowStart: Int, rowEnd: Int, columnStart: Int, columnEnd: Int) -> SMLLMatrix {
        assert(rowStart < rowEnd, "Invalid row index range")
        assert(columnStart < columnEnd, "Invalid column index range")
        var values: [Double] = [Double]();
        // Copy parts of the existing matrix row-wise into the new one
        for rowIndex in rowStart ... rowEnd {
            values.append(contentsOf: elements[(rowIndex*columns+columnStart)...(rowIndex*columns+columnEnd)])
        }
        return SMLLMatrix(rows: (rowEnd-rowStart+1), columns: (columnEnd-columnStart+1), values: values)
    }
    
    
    // - Private methods
    
    fileprivate func indexIsValidForRow (_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    
    fileprivate func normalRandomValue () -> Double {
        let u = (Double)(arc4random() % 1000 + 1) / 1000.0
        let v = (Double)(arc4random() % 1000 + 1) / 1000.0
        let random = sqrt( -2 * log(u) ) * cos( 2 * M_PI * v )
        
        return random
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
