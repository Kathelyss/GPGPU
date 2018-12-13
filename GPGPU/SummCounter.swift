import Foundation
import Metal

func sumElements(arrayOfNumbers: [DataType]) -> String {
    let elementsPerSum = Int(arrayOfNumbers.count / 1000) > 10 ? Int(arrayOfNumbers.count / 1000) : 10
    let device = MTLCreateSystemDefaultDevice()!
    let shader = device.makeDefaultLibrary()!.makeFunction(name: "summatorShader")!
    let pipeline = try! device.makeComputePipelineState(function: shader)
    
    // Number of individual results = count / elementsPerSum (rounded up)
    let resultsCount = (arrayOfNumbers.count + elementsPerSum - 1) / elementsPerSum
    
    // Our data in a buffer (copied)
    let dataBuffer = device.makeBuffer(bytes: arrayOfNumbers,
                                       length: MemoryLayout<DataType>.stride * arrayOfNumbers.count,
                                       options: [])
    // A buffer for individual results (zero initialized)
    let resultsBuffer = device.makeBuffer(length: MemoryLayout<DataType>.stride * resultsCount, options: [])
    // Our results in convenient form to compute the actual result later
    let startPointer = resultsBuffer?.contents().assumingMemoryBound(to: DataType.self)
    let results = UnsafeBufferPointer<DataType>(start: startPointer, count: resultsCount)
    
    guard let queue = device.makeCommandQueue(), let cmds = queue.makeCommandBuffer(),
        let encoder = cmds.makeComputeCommandEncoder() else { return "Error! Cannot get queue, or cmds, or encoder!" }
    
    var dataCount = CUnsignedInt(arrayOfNumbers.count)
    var elementsPerSumC = CUnsignedInt(elementsPerSum)
    
    encoder.setComputePipelineState(pipeline)
    encoder.setBuffer(dataBuffer, offset: 0, index: 0)
    encoder.setBytes(&dataCount, length: MemoryLayout.size(ofValue: dataCount), index: 1)
    encoder.setBuffer(resultsBuffer, offset: 0, index: 2)
    encoder.setBytes(&elementsPerSumC, length: MemoryLayout.size(ofValue: elementsPerSumC), index: 3)
    
    // We have to calculate the sum `resultCount` times =>
    // => amount of threadgroups is `resultsCount` / `threadExecutionWidth` (rounded up)
    // because each threadgroup will process `threadExecutionWidth` threads
    let width = (resultsCount + pipeline.threadExecutionWidth - 1) / pipeline.threadExecutionWidth
    let threadgroupsPerGrid = MTLSize(width: width, height: 1, depth: 1)
    
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
    let gpuCalculationTime = Double(calculationEndTime - calculationStartTime) / 1_000_000
    var resultText = "Сумма элементов массива = \(result)\nВремя GPU: \(gpuCalculationTime) мс"
    
    result = 0
    
    calculationStartTime = mach_absolute_time()
    arrayOfNumbers.withUnsafeBufferPointer { buffer in
        for element in buffer {
            result += element
        }
    }
    calculationEndTime = mach_absolute_time()
    let cpuCalculationTime = Double(calculationEndTime - calculationStartTime) / 1_000_000
    resultText += "\nВремя CPU: \(cpuCalculationTime) мс\n"
    resultText += compareAndWriteFasterPU(gpuTime: gpuCalculationTime, cpuTime: cpuCalculationTime)
    
    return resultText
}

func compareAndWriteFasterPU(gpuTime: Double, cpuTime: Double) -> String {
    if gpuTime > cpuTime {
        return "CPU быстрее GPU в \(String(format: "%.2f", (gpuTime / cpuTime))) раз\n\n"
    } else {
        return "GPU быстрее CPU в \(String(format: "%.2f", (cpuTime / gpuTime))) раз\n\n"
    }
}
