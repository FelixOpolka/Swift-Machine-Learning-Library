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
        self.measure {
            _ = testMatrix.transpose()
        }
    }
    
    func testMaxIndex() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [0.03, 0.3, 1.003,
            0.0002223, 2.299, 0.02])
        XCTAssertEqual(testMatrix.maxIndex().row, 1)
        XCTAssertEqual(testMatrix.maxIndex().column, 1)
    }
    
    func testMaxIndexAndValue() {
        let testMatrix = SMLLMatrix(rows: 2, columns: 3, values:
            [0.03, 0.3, 1.003,
             0.0002223, 2.299, 0.02])
        let max = testMatrix.maxValueAndIndex()
        XCTAssertEqual(max.row, 1)
        XCTAssertEqual(max.column, 1)
        XCTAssertEqual(max.value, 2.299)
    }
    
    func testMaxIndexPerformance() {
        let testMatrix = SMLLMatrix(normalRandomValuesMatrixWithRows: 900, columns: 1000)
        self.measure { // Un-Accelerated: 0.116
            _ = testMatrix.maxIndex()
        }
    }
    
    func testSubmatrix() {
        let testMatrix = SMLLMatrix(rows: 3, columns: 4, sequence: true).submatrix(byCuttingTopBorderOfWidth: 0, bottomBorderWidth: 1, leftBorderWidth: 1, rightBorderWidth: 1)
        print(testMatrix)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 2, values:
            [2.0, 3.0,
            6.0, 7.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    func testSubmatrixPerformance() {
        self.measure {  // Un-Accelerated: 0.555
            _ = SMLLMatrix(rows: 1_000, columns: 1_000, sequence: true).submatrix(byCuttingTopBorderOfWidth: 100, bottomBorderWidth: 100, leftBorderWidth: 100, rightBorderWidth: 100)
        }
    }
    
    
    func testReverseRows() {
        var testMatrix = SMLLMatrix(rows: 3, columns: 4, sequence: true)
        testMatrix.reverseRows()
        let checkMatrix = SMLLMatrix(rows: 3, columns: 4, values: [4.0, 3.0, 2.0, 1.0,
                                                                   8.0, 7.0, 6.0, 5.0,
                                                                   12.0, 11.0, 10.0, 9.0,])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    func testReverseColumns() {
        var testMatrix = SMLLMatrix(rows: 3, columns: 4, sequence: true)
        testMatrix.reverseColumns()
        let checkMatrix = SMLLMatrix(rows: 3, columns: 4, values: [9.0, 10.0, 11.0, 12.0,
                                                                   5.0, 6.0, 7.0, 8.0,
                                                                   1.0, 2.0, 3.0, 4.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    
    func testRotatePlus90Degrees() {
        var testMatrix = SMLLMatrix(rows: 3, columns: 4, sequence: true)
        testMatrix.rotatePlus90Degrees()
        let checkMatrix = SMLLMatrix(rows: 4, columns: 3, values: [9.0, 5.0, 1.0,
                                                                   10.0, 6.0, 2.0,
                                                                   11.0, 7.0, 3.0,
                                                                   12.0, 8.0, 4.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }

    func testRotateMinus90Degrees() {
        var testMatrix = SMLLMatrix(rows: 3, columns: 4, sequence: true)
        testMatrix.rotateMinus90Degrees()
        let checkMatrix = SMLLMatrix(rows: 4, columns: 3, values: [4.0, 8.0, 12.0,
                                                                   3.0, 7.0, 11.0,
                                                                   2.0, 6.0, 10.0,
                                                                   1.0, 5.0, 9.0])
        XCTAssertEqual(testMatrix, checkMatrix)
    }
    
    
    func testRotate180Degrees() {
        var testMatrix = SMLLMatrix(rows: 3, columns: 4, sequence: true)
        testMatrix.rotate180Degrees()
        let checkMatrix = SMLLMatrix(rows: 3, columns: 4, values: [12.0, 11.0, 10.0, 9.0,
                                                                   8.0, 7.0, 6.0, 5.0,
                                                                   4.0, 3.0, 2.0, 1.0])
        XCTAssertEqual(testMatrix, checkMatrix)
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
        self.measure { // Un-Accelerated: 3.125
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
        self.measure {
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
        self.measure {
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
        self.measure {
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
        self.measure { // Un-Accelerated: 0.244
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
        self.measure { // Un-Accelerated: 0.243
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
        self.measure {
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
        self.measure( {    // Un-Accelerated: 0.463
            _ = leftTestMatrix * rightTestMatrix
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
        self.measure { // Un-Accelerated: 0.030
            _ = leftMatrix ○ rightMatrix
        }
    }
    
    
    func testValidConvolution() {
        let testMatrix = SMLLMatrix(rows: 6, columns: 6, sequence: true)
        let kernelMatrix = SMLLMatrix(rows: 3, columns: 3, repeatedValue: 0.5)
        let checkMatrix = SMLLMatrix(rows: 4, columns: 4, values: [36.0, 40.5, 45.0, 49.5,
                                                                   63.0, 67.5, 72.0, 76.5,
                                                                   90.0, 94.5, 99.0, 103.5,
                                                                   117.0, 121.5, 126.0, 130.5])
        let resultMatrix = convoluteValidKernelOnly(signalMatrix: testMatrix, kernelMatrix: kernelMatrix)
        XCTAssertEqual(resultMatrix, checkMatrix)
    }
    
    func testValidConvolution2() {
        let testMatrix = SMLLMatrix(rows: 6, columns: 6, sequence: true)
        let kernelMatrix = SMLLMatrix(rows: 5, columns: 3, repeatedValue: 0.5)
        let checkMatrix = SMLLMatrix(rows: 2, columns: 4, values: [105.0, 112.5, 120.0, 127.5,
                                                                   150.0, 157.5, 165.0, 172.5])
        let resultMatrix = convoluteValidKernelOnly(signalMatrix: testMatrix, kernelMatrix: kernelMatrix)
        XCTAssertEqual(resultMatrix, checkMatrix)
    }
    
    func testValidConvolutionPerformance() {
        let testMatrix = SMLLMatrix(rows: 100, columns: 100, sequence: true)
        let kernelMatrix = SMLLMatrix(rows: 11, columns: 11, sequence: true)
        self.measure {
            _ = convoluteValidKernelOnly(signalMatrix: testMatrix, kernelMatrix: kernelMatrix)
        }
    }
    
    func testFullConvolution() {
        let testMatrix = SMLLMatrix(rows: 5, columns: 5, sequence: true)
        let kernelMatrix = SMLLMatrix(rows: 3, columns: 3, repeatedValue: 0.5)
        let checkMatrix = SMLLMatrix(rows: 5, columns: 5, values: [8.0, 13.5, 16.5, 19.5, 14.0,
                                                                   19.5, 31.5, 36.0, 40.5, 28.5,
                                                                   34.5, 54.0, 58.5, 63.0, 43.5,
                                                                   49.5, 76.5, 81.0, 85.5, 58.5,
                                                                   38.0, 58.5, 61.5, 64.5, 44.0])
        let resultMatrix = convoluteFullKernel(signalMatrix: testMatrix, kernelMatrix: kernelMatrix)
        XCTAssertEqual(resultMatrix, checkMatrix)
    }
    
    func testFullConvolutionPerformance() {
        let testMatrix = SMLLMatrix(rows: 100, columns: 100, sequence: true)
        let kernelMatrix = SMLLMatrix(rows: 11, columns: 11, sequence: true)
        self.measure {  // Un-Accelerated: 0.370s
            _ = convoluteFullKernel(signalMatrix: testMatrix, kernelMatrix: kernelMatrix)
        }
    }
    
    
    func testMaxValueAndIndexOfRegion() {
        let testMatrix = SMLLMatrix(rows: 3, columns: 4, values: [2.5, 3.5, 5.55, 7.84,
                                                                  2.2, 3.3, 4.4, 5.5,
                                                                  6.7, 8.9, 9.8, 1.2])
        let max = testMatrix.maxValueAndIndexOfRegion(rowStartIndex: 1, columnStartIndex: 1, width: 2, height: 1)
        XCTAssertEqual(max.row, 0)
        XCTAssertEqual(max.column, 1)
        XCTAssertEqual(max.value, 4.4)
    }
    
    func testMaxOfRegionPerformance() {
        let testMatrix = SMLLMatrix(rows: 1000, columns: 2000, sequence: true)
        self.measure {
            _ = testMatrix.maxValueAndIndexOfRegion(rowStartIndex: 500, columnStartIndex: 1005, width: 150, height: 120)
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
        self.measure {
            _ = exp(testMatrix)
        }
        
    }
}
