//
//  SumCalculation.swift
//  GPGPU
//
//  Created by kathelyss on 29/10/2018.
//  Copyright © 2018 Екатерина Рыжова. All rights reserved.
//

import Foundation
import Metal

let countOfElementsInArray = 10_000_000
let elementsPerSum = 10_000

// Data type has to be the same as in the shader
typealias DataType = CInt

func process() {
    let device = MTLCreateSystemDefaultDevice()!
    let arraySumm = device.makeDefaultLibrary()!.makeFunction(name: "arraySumm")!
    let pipeline = try! device.makeComputePipelineState(function: arraySumm)
    
    let arrayOfNumbers = (0..<countOfElementsInArray).map { _ in DataType(arc4random_uniform(100)) }
    var dataCount = CUnsignedInt(countOfElementsInArray)
    var elementsPerSumC = CUnsignedInt(elementsPerSum)
    // Number of individual results = count / elementsPerSum (rounded up)
    let resultsCount = (countOfElementsInArray + elementsPerSum - 1) / elementsPerSum
    
    // Our data in a buffer (copied)
    let dataBuffer = device.makeBuffer(bytes: arrayOfNumbers,
                                       length: MemoryLayout<DataType>.stride * countOfElementsInArray,
                                       options: [])
    // A buffer for individual results (zero initialized)
    let resultsBuffer = device.makeBuffer(length: MemoryLayout<DataType>.stride * resultsCount, options: [])
    // Our results in convenient form to compute the actual result later
    let pointer = resultsBuffer?.contents().assumingMemoryBound(to: DataType.self)
    let results = UnsafeBufferPointer<DataType>(start: pointer, count: resultsCount)
    
    guard let queue = device.makeCommandQueue(),
        let cmds = queue.makeCommandBuffer(),
        let encoder = cmds.makeComputeCommandEncoder() else {
            print("Error! Cannot get queue, or cmds, or encoder!")
            return
    }
    
    encoder.setComputePipelineState(pipeline)
    encoder.setBuffer(dataBuffer, offset: 0, index: 0)
    encoder.setBytes(&dataCount, length: MemoryLayout.size(ofValue: dataCount), index: 1)
    encoder.setBuffer(resultsBuffer, offset: 0, index: 2)
    encoder.setBytes(&elementsPerSumC, length: MemoryLayout.size(ofValue: elementsPerSumC), index: 3)
    
    // We have to calculate the sum `resultCount` times =>
    // => amount of threadgroups is `resultsCount` / `threadExecutionWidth` (rounded up)
    // because each threadgroup will process `threadExecutionWidth` threads
    let width = (resultsCount + pipeline.threadExecutionWidth - 1) / pipeline.threadExecutionWidth
    let threadgroupsPerGrid = MTLSize( width: width, height: 1, depth: 1)
    
    // Here we set that each threadgroup should process `threadExecutionWidth` threads,
    // the only important thing for performance
    // is that this number is a multiple of `threadExecutionWidth` (here 1 times)
    let threadsPerThreadgroup = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)
    
    encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    encoder.endEncoding()
    
    var calculationStartTime, calculationEndTime: UInt64
    var result: DataType = 0
    
    calculationStartTime = mach_absolute_time()
    cmds.commit()
    cmds.waitUntilCompleted()
    for element in results {
        result += element
    }
    
    calculationEndTime = mach_absolute_time()
    
    print("GPU result: \(result), time: \(Double(calculationEndTime - calculationStartTime) / Double(NSEC_PER_SEC))")
    result = 0
    
    calculationStartTime = mach_absolute_time()
    arrayOfNumbers.withUnsafeBufferPointer { buffer in
        for element in buffer {
            result += element
        }
    }
    calculationEndTime = mach_absolute_time()
    
    print("CPU result: \(result), time: \(Double(calculationEndTime - calculationStartTime) / Double(NSEC_PER_SEC))")
}
