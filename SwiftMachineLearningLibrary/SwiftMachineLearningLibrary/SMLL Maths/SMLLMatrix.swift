//
//  SMLLMatrix.swift
//  Swift Machine Learning Library
//
//  Created by Felix Opolka on 16.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//
import Foundation
import Accelerate

public enum SMLLMatrixError: ErrorType {
    case InvalidIOData(dataIdentifier: String)
}

public enum SMLLMatrixShape {
    case ColumnVector, RowVector
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
            let contents = (0..<columns).map{"\(self[i, $0])"}.joinWithSeparator("\t")
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
        elements = Array (count: rows*columns, repeatedValue: repeatedValue)
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
        elements = Array (count: rows*columns, repeatedValue: 0.0)
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
        if shape == .ColumnVector {
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
        if shape == .ColumnVector {
            self.rows = values.count
            self.columns = 1
        } else {
            self.rows = 1;
            self.columns = values.count
        }
        elements = values
    }
    
    
    /**
     Initializes a matrix with the shape of a given matrix and sets all elements to `repeatedValue` which defaults to `0.0`.
     */
    public init(mirrorShapeOf shapeModel: SMLLMatrix, repeatedValue: Double = 0.0) {
        self.rows = shapeModel.rows
        self.columns = shapeModel.columns
        elements = Array(count: rows*columns, repeatedValue: repeatedValue)
    }
    
    
    /**
     Initializes a matrix from a given storage dictionary.
     */
    public init(ioRepresentation: NSDictionary) throws {
        if let rows = (ioRepresentation.valueForKey("Rows") as? Int) {
            self.rows = rows
        } else { throw SMLLMatrixError.InvalidIOData(dataIdentifier: "Rows") }
        
        if let columns = (ioRepresentation.valueForKey("Columns") as? Int) {
            self.columns = columns
        } else { throw SMLLMatrixError.InvalidIOData(dataIdentifier: "Columns") }
        
        if let elements = (ioRepresentation.valueForKey("Elements") as? [Double]) {
            self.elements = elements
        } else { throw SMLLMatrixError.InvalidIOData(dataIdentifier: "Elements") }
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
    
    
    public func transposeValueForRow (row: Int, column: Int) -> Double {
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
    public func submatrixFromRowStart (rowStart: Int, rowEnd: Int, columnStart: Int, columnEnd: Int) -> SMLLMatrix {
        assert(rowStart < rowEnd, "Invalid row index range")
        assert(columnStart < columnEnd, "Invalid column index range")
        var values: [Double] = [Double]();
        // Copy parts of the existing matrix row-wise into the new one
        for rowIndex in rowStart ... rowEnd {
            values.appendContentsOf(elements[(rowIndex*columns+columnStart)...(rowIndex*columns+columnEnd)])
        }
        return SMLLMatrix(rows: (rowEnd-rowStart+1), columns: (columnEnd-columnStart+1), values: values)
    }
    
    
    // - Private methods
    
    private func indexIsValidForRow (row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    
    private func normalRandomValue () -> Double {
        let u = (Double)(arc4random() % 1000 + 1) / 1000.0
        let v = (Double)(arc4random() % 1000 + 1) / 1000.0
        let random = sqrt( -2 * log(u) ) * cos( 2 * M_PI * v )
        
        return random
    }
    
    
    // MARK: - Storage methods
    
    public func getIORepresentation() -> NSDictionary {
        let ioRepresentation = NSDictionary()
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