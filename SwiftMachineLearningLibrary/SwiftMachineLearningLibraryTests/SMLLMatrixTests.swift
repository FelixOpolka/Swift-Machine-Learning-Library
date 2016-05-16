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
        XCTAssertEqual(matrix34[0, 0], 1.0)
        XCTAssertEqual(matrix34[0, 1], 5.0)
        XCTAssertEqual(matrix34[0, 2], 9.0)
        XCTAssertEqual(matrix34[1, 0], 2.0)
        XCTAssertEqual(matrix34[1, 1], 6.0)
        XCTAssertEqual(matrix34[1, 2], 10.0)
        XCTAssertEqual(matrix34[2, 0], 3.0)
        XCTAssertEqual(matrix34[2, 1], 7.0)
        XCTAssertEqual(matrix34[2, 2], 11.0)
        XCTAssertEqual(matrix34[3, 0], 4.0)
        XCTAssertEqual(matrix34[3, 1], 8.0)
        XCTAssertEqual(matrix34[3, 2], 12.0)
    }
    
    func testTransposePerformance() {
        let testMatrix = SMLLMatrix(rows: 1_000, columns: 10_000, sequence: true)
        self.measureBlock {
            testMatrix.transpose()
        }
    }
    
    func testSubmatrix() {
        let testMatrix = SMLLMatrix(rows: 3, columns: 3, sequence: true).submatrixFromRowStart(0, rowEnd: 1, columnStart: 1, columnEnd: 2)
        XCTAssertEqual(testMatrix[0,0], 2.0)
        XCTAssertEqual(testMatrix[0,1], 3.0)
        XCTAssertEqual(testMatrix[1,0], 5.0)
        XCTAssertEqual(testMatrix[1,1], 6.0)
    }
    
    func testSubmatrixPerformance() {
        self.measureBlock {
            _ = SMLLMatrix(rows: 1_000, columns: 1_000, sequence: true).submatrixFromRowStart(300, rowEnd: 999, columnStart: 1, columnEnd: 600)
        }
    }
    
    func testAddition() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 4, sequence: true) + SMLLMatrix(rows: 2, columns: 4, sequence: true)
        XCTAssertEqual(testMatrix[0,0], 2.0)
        XCTAssertEqual(testMatrix[0,1], 4.0)
        XCTAssertEqual(testMatrix[0,2], 6.0)
        XCTAssertEqual(testMatrix[0,3], 8.0)
        XCTAssertEqual(testMatrix[1,0], 10.0)
        XCTAssertEqual(testMatrix[1,1], 12.0)
        XCTAssertEqual(testMatrix[1,2], 14.0)
        XCTAssertEqual(testMatrix[1,3], 16.0)
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
        XCTAssertEqual(testMatrix[0,0], 4.0)
        XCTAssertEqual(testMatrix[0,1], 5.0)
        XCTAssertEqual(testMatrix[0,2], 6.0)
        XCTAssertEqual(testMatrix[0,3], 7.0)
        XCTAssertEqual(testMatrix[1,0], 8.0)
        XCTAssertEqual(testMatrix[1,1], 9.0)
        XCTAssertEqual(testMatrix[1,2], 10.0)
        XCTAssertEqual(testMatrix[1,3], 11.0)
    }
    
    
    func testScalarMatrixAdditionPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock {
            _ = 11.0 + testMatrix
        }
    }
    
    
    func testSubtraction() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 4, sequence: true) - SMLLMatrix(rows: 2, columns: 4, repeatedValue: 2.0)
        XCTAssertEqual(testMatrix[0,0], -1.0)
        XCTAssertEqual(testMatrix[0,1], 0.0)
        XCTAssertEqual(testMatrix[0,2], 1.0)
        XCTAssertEqual(testMatrix[0,3], 2.0)
        XCTAssertEqual(testMatrix[1,0], 3.0)
        XCTAssertEqual(testMatrix[1,1], 4.0)
        XCTAssertEqual(testMatrix[1,2], 5.0)
        XCTAssertEqual(testMatrix[1,3], 6.0)
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
        XCTAssertEqual(testMatrix[0,0], -1.0)
        XCTAssertEqual(testMatrix[0,1], -2.0)
        XCTAssertEqual(testMatrix[0,2], -3.0)
        XCTAssertEqual(testMatrix[1,0], -4.0)
        XCTAssertEqual(testMatrix[1,1], -5.0)
        XCTAssertEqual(testMatrix[1,2], -6.0)
    }
    
    func testNegationPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock {
            _ = -testMatrix
        }
    }
    
    
    func testScalarMultiplication() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, sequence: true) * 2.0
        XCTAssertEqual(testMatrix[0,0], 2.0)
        XCTAssertEqual(testMatrix[0,1], 4.0)
        XCTAssertEqual(testMatrix[0,2], 6.0)
        XCTAssertEqual(testMatrix[1,0], 8.0)
        XCTAssertEqual(testMatrix[1,1], 10.0)
        XCTAssertEqual(testMatrix[1,2], 12.0)
    }
    
    
    func testScalarMultiplicationPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock { // Un-Accelerated: 0.244
            _ = testMatrix * 2.0
        }
    }
    
    
    func testMatrixScalarDivision() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, sequence: true) / 2.0
        XCTAssertEqual(testMatrix[0,0], 0.5)
        XCTAssertEqual(testMatrix[0,1], 1.0)
        XCTAssertEqual(testMatrix[0,2], 1.5)
        XCTAssertEqual(testMatrix[1,0], 2.0)
        XCTAssertEqual(testMatrix[1,1], 2.5)
        XCTAssertEqual(testMatrix[1,2], 3.0)
    }
    
    
    func testMatrixScalarDivisionPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock { // Un-Accelerated: 0.243
            _ = testMatrix / 2.0
        }
    }
    
    
    func testScalarMatrixDivision() {
        let testMatrix = 30.0 / SMLLMatrix(rows: 2, columns: 3, sequence: true)
        XCTAssertEqual(testMatrix[0,0], 30.0)
        XCTAssertEqual(testMatrix[0,1], 15.0)
        XCTAssertEqual(testMatrix[0,2], 10.0)
        XCTAssertEqual(testMatrix[1,0], 7.5)
        XCTAssertEqual(testMatrix[1,1], 6.0)
        XCTAssertEqual(testMatrix[1,2], 5.0)
    }
    
    
    func testScalarMatrixDivisionPerformance() {
        let testMatrix = SMLLMatrix(rows: 3_000, columns: 4_000, sequence: true)
        self.measureBlock {
            _ = 50.0 / testMatrix
        }
    }
    
    
    func testMatrixMultiplication() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, values: [3.0, 2.0, 1.0, 1.0, 0.0, 2.0]) * SMLLMatrix(rows: 3, columns: 2, values: [1.0, 2.0, 0.0, 1.0, 4.0, 0.0])
        XCTAssertEqual(testMatrix[0,0], 7.0)
        XCTAssertEqual(testMatrix[0,1], 8.0)
        XCTAssertEqual(testMatrix[1,0], 9.0)
        XCTAssertEqual(testMatrix[1,1], 2.0)
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
        XCTAssertEqual(testMatrix[0,0], 1.0)
        XCTAssertEqual(testMatrix[0,1], 4.0)
        XCTAssertEqual(testMatrix[0,2], 9.0)
        XCTAssertEqual(testMatrix[1,0], 16.0)
        XCTAssertEqual(testMatrix[1,1], 25.0)
        XCTAssertEqual(testMatrix[1,2], 36.0)
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
