//
//  ProcessFile.swift
//  GPGPU
//
//  Created by kathelyss on 29/10/2018.
//  Copyright © 2018 Екатерина Рыжова. All rights reserved.
//

import Foundation
import Metal

typealias DataType = CInt

func sumElements(arrayOfNumbers: [DataType]) -> String {
    let countOfElementsInArray = arrayOfNumbers.count
    let elementsPerSum = Int(arrayOfNumbers.count / 1000) > 10 ? Int(arrayOfNumbers.count / 1000) : 10
    let device = MTLCreateSystemDefaultDevice()!
    let arrayProcessFunction = device.makeDefaultLibrary()!.makeFunction(name: "arrayProcessFunction")!
    let pipeline = try! device.makeComputePipelineState(function: arrayProcessFunction)
    
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
            return "Error!"
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
    let gpuCalculationTime = Double(calculationEndTime - calculationStartTime) / Double(NSEC_PER_SEC)
    var resultText = "Сумма элементов массива:\nРезультат GPU: \(result)\nВремя: \(gpuCalculationTime)"
    
    result = 0
    
    calculationStartTime = mach_absolute_time()
    arrayOfNumbers.withUnsafeBufferPointer { buffer in
        for element in buffer {
            result += element
        }
    }
    calculationEndTime = mach_absolute_time()
    
    let cpuCalculationTime = Double(calculationEndTime - calculationStartTime) / Double(NSEC_PER_SEC)
    resultText += "\n\nРезультат CPU: \(result)\nВремя: \(cpuCalculationTime)\n-----\n"
    
    return resultText
}
