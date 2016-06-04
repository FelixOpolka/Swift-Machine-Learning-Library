//
//  SMLLMatrixTests.swift
//  Swift Machine Learning Library
//
//  Created by Felix Opolka on 16.05.16.
//  Copyright © 2016 Felix Opolka. All rights reserved.
//

import XCTest
@testable import SwiftMachineLearningLibrary

class SMLLMatrixTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTranspose() {
        let matrix34 = SMLLMatrix(rows: 3, columns: 4, sequence: true).transpose()
        let checkMatrix = SMLLMatrix(rows: 4, columns: 3, values:
            [1.0, 5.0, 9.0,
            2.0, 6.0, 10.0,
            3.0, 7.0, 11.0,
            4.0, 8.0, 12.0])
        XCTAssertEqual(matrix34, checkMatrix)
    }
    
    func testTransposePerformance() {
        let testMatrix = SMLLMatrix(rows: 1_000, columns: 10_000, sequence: true)
        self.measureBlock {
            testMatrix.transpose()
        }
    }
    
    func testMaxIndex() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [0.03, 0.3, 1.003,
            0.0002223, 2.299, 0.02])
        XCTAssertEqual(testMatrix.maxIndex().row, 1)
        XCTAssertEqual(testMatrix.maxIndex().column, 1)
    }
    
    func testMaxIndexPerformance() {
        let testMatrix = SMLLMatrix(rows: 900, columns: 1000, normalRandomValues: true)
        self.measureBlock { // Un-Accelerated: 0.116
            testMatrix.maxIndex()
        }
    }
    
    func testSubmatrix() {
        let testMatrix = SMLLMatrix(rows: 3, columns: 3, sequence: true).submatrixFromRowStart(0, rowEnd: 1, columnStart: 1, columnEnd: 2)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 2, values:
            [2.0, 3.0,
            5.0, 6.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    func testSubmatrixPerformance() {
        self.measureBlock {
            _ = SMLLMatrix(rows: 1_000, columns: 1_000, sequence: true).submatrixFromRowStart(300, rowEnd: 999, columnStart: 1, columnEnd: 600)
        }
    }
    
    func testAddition() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 4, sequence: true) + SMLLMatrix(rows: 2, columns: 4, sequence: true)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 4, values:
            [2.0, 4.0, 6.0, 8.0,
            10.0, 12.0, 14.0, 16.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    
    func testAdditionPerformance() {
        let leftMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        let rightMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock { // Un-Accelerated: 3.125
            _ = leftMatrix + rightMatrix
        }
    }
    
    
    func testScalarMatrixAddition() {
        let testMatrix = 3.0 + SMLLMatrix(rows: 2, columns: 4, sequence: true)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 4, values:
            [4.0, 5.0, 6.0, 7.0,
            8.0, 9.0, 10.0, 11.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    
    func testScalarMatrixAdditionPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock {
            _ = 11.0 + testMatrix
        }
    }
    
    
    func testSubtraction() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 4, sequence: true) - SMLLMatrix(rows: 2, columns: 4, repeatedValue: 2.0)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 4, values:
            [-1.0, 0.0, 1.0, 2.0,
            3.0, 4.0, 5.0, 6.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    func testSubtractionPerformance() {
        let leftMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        let rightMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock {
            _ = leftMatrix - rightMatrix
        }
    }
    
    
    func testNegation() {
        let testMatrix = -SMLLMatrix(rows: 2, columns: 3, sequence: true)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [-1.0, -2.0, -3.0,
            -4.0, -5.0, -6.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    func testNegationPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock {
            _ = -testMatrix
        }
    }
    
    
    func testScalarMultiplication() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, sequence: true) * 2.0
        let checkMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [2.0, 4.0, 6.0,
            8.0, 10.0, 12.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    
    func testScalarMultiplicationPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock { // Un-Accelerated: 0.244
            _ = testMatrix * 2.0
        }
    }
    
    
    func testMatrixScalarDivision() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, sequence: true) / 2.0
        let checkMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [0.5, 1.0, 1.5,
            2.0, 2.5, 3.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    
    func testMatrixScalarDivisionPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock { // Un-Accelerated: 0.243
            _ = testMatrix / 2.0
        }
    }
    
    
    func testScalarMatrixDivision() {
        let testMatrix = 30.0 / SMLLMatrix(rows: 2, columns: 3, sequence: true)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [30.0, 15.0,
            10.0, 7.5,
            6.0, 5.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    
    func testScalarMatrixDivisionPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock {
            _ = 50.0 / testMatrix
        }
    }
    
    
    func testMatrixMultiplication() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, values: [3.0, 2.0, 1.0, 1.0, 0.0, 2.0]) * SMLLMatrix(rows: 3, columns: 2, values: [1.0, 2.0, 0.0, 1.0, 4.0, 0.0])
        let checkMatrix = SMLLMatrix(rows: 2, columns: 2, values:
            [7.0, 8.0,
            9.0, 2.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    func testMatrixMultiplicationPerformance() {
        let leftTestMatrix = SMLLMatrix(rows: 200, columns: 100, sequence: true)
        let rightTestMatrix = SMLLMatrix(rows: 100, columns: 50, sequence: true)
        self.measureBlock( {    // Un-Accelerated: 0.463
            leftTestMatrix * rightTestMatrix
        })
    }
    
    
    func testHadamadProduct() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, sequence: true) ○ SMLLMatrix(rows: 2, columns: 3, sequence: true)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [1.0, 4.0, 9.0,
            16.0, 25.0, 36.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    func testHadamadProductPerformance() {
        let leftMatrix = SMLLMatrix(rows: 1_000, columns: 800, sequence: true)
        let rightMatrix = SMLLMatrix(rows: 1_000, columns: 800, sequence: true)
        self.measureBlock { // Un-Accelerated: 0.030
            _ = leftMatrix ○ rightMatrix
        }
        
    }
    
    
    func testExponential() {
        let testMatrix = exp(SMLLMatrix(rows: 2, columns: 2, sequence: true))
        XCTAssertEqualWithAccuracy(testMatrix[0,0], M_E, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(testMatrix[0,1], M_E*M_E, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(testMatrix[1,0], M_E*M_E*M_E, accuracy: 0.01)
        XCTAssertEqualWithAccuracy(testMatrix[1,1], M_E*M_E*M_E*M_E, accuracy: 0.01)
    }
    
    func testExponentialPerformance() {
        let testMatrix = SMLLMatrix(rows: 1_000, columns: 800, sequence: true)
        self.measureBlock {
            _ = exp(testMatrix)
        }
        
    }
}
