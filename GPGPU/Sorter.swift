import Foundation

import Metal

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
    let resultsArray = Array.init(dataBufferPointer)
    
    var resultString = ""
    resultsArray.forEach { (item) in
        resultString += "\(item), "
    }
    
    return resultString
}
