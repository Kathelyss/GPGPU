import Foundation

import Metal

//class Sorter 
var sortedArray: [DataType] = []

func sortElements(arrayOfNumbers: [DataType]) -> String {
    let device = MTLCreateSystemDefaultDevice()!
    let commandQueue = device.makeCommandQueue()!
    let library = device.makeDefaultLibrary()!
    let sortFunction = library.makeFunction(name: "parallelBitonicShader")!
    let pipeline = try! device.makeComputePipelineState(function: sortFunction)
    
    let dataBuffer = device.makeBuffer(bytes: arrayOfNumbers, length: MemoryLayout<DataType>.stride * arrayOfNumbers.count, options: [.storageModeShared])!
    
    let threadgroupsPerGrid = MTLSize(width: arrayOfNumbers.count, height: 1, depth: 1)
    let threadsPerThreadgroup = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)
    
    guard let logn = Int(exactly: log2(Double(arrayOfNumbers.count))) else {
        fatalError("data.count is not a power of 2")
    }
    
    var calculationStartTime, calculationEndTime: UInt64
    calculationStartTime = mach_absolute_time()

    for p in 0..<logn {
        for q in 0..<p+1 {
            
            var n1 = p
            var n2 = q
            
            let commands = commandQueue.makeCommandBuffer()!
            let encoder = commands.makeComputeCommandEncoder()!
            
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(dataBuffer, offset: 0, index: 0)
            encoder.setBytes(&n1, length: MemoryLayout<DataType>.stride, index: 1)
            encoder.setBytes(&n2, length: MemoryLayout<DataType>.stride, index: 2)
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
            
            commands.commit()
            commands.waitUntilCompleted()
            
        }
    }
    
    let dataPointer = dataBuffer.contents().assumingMemoryBound(to: DataType.self)
    let dataBufferPointer = UnsafeMutableBufferPointer(start: dataPointer, count: arrayOfNumbers.count)
    var resultsArray = Array.init(dataBufferPointer)
    calculationEndTime = mach_absolute_time()
    let gpuCalculationTime = Double(calculationEndTime - calculationStartTime) / 1_000_000
    var resultText = "Сортировка элементов массива\nВремя GPU: \(gpuCalculationTime) мс"
    
    resultsArray.removeAll()
    
    calculationStartTime = mach_absolute_time()
    resultsArray = mergeSort(arrayOfNumbers)
    calculationEndTime = mach_absolute_time()
    sortedArray = resultsArray
    let cpuCalculationTime = Double(calculationEndTime - calculationStartTime) / 1_000_000
    resultText += "\nВремя CPU: \(cpuCalculationTime) мс\n"
    
    resultText += compareAndWriteFasterPU(gpuTime: gpuCalculationTime, cpuTime: cpuCalculationTime)
    
    return resultText
}

func mergeSort(_ array: [DataType]) -> [DataType] {
    guard array.count > 1 else { return array }
    
    let middleIndex = array.count / 2
    let leftArray = mergeSort(Array(array[0..<middleIndex]))
    let rightArray = mergeSort(Array(array[middleIndex..<array.count]))
    
    return merge(leftPile: leftArray, rightPile: rightArray)
}

func merge(leftPile: [DataType], rightPile: [DataType]) -> [DataType] {
    var leftIndex = 0
    var rightIndex = 0
    var orderedPile = [DataType]()
    
    while leftIndex < leftPile.count && rightIndex < rightPile.count {
        if leftPile[leftIndex] < rightPile[rightIndex] {
            orderedPile.append(leftPile[leftIndex])
            leftIndex += 1
        } else if leftPile[leftIndex] > rightPile[rightIndex] {
            orderedPile.append(rightPile[rightIndex])
            rightIndex += 1
        } else {
            orderedPile.append(leftPile[leftIndex])
            leftIndex += 1
            orderedPile.append(rightPile[rightIndex])
            rightIndex += 1
        }
    }
    
    while leftIndex < leftPile.count {
        orderedPile.append(leftPile[leftIndex])
        leftIndex += 1
    }
    while rightIndex < rightPile.count {
        orderedPile.append(rightPile[rightIndex])
        rightIndex += 1
    }
    
    return orderedPile
}
