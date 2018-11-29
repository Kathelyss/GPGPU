//
//  MetalFile.metal
//  GPGPU
//
//  Created by kathelyss on 29/10/2018.
//  Copyright © 2018 Екатерина Рыжова. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef int DataType;

kernel void arrayProcessFunction(const device DataType* data [[ buffer(0) ]],
                                 const device uint& dataLength [[ buffer(1) ]],
                                 device DataType* sums [[ buffer(2) ]],
                                 const device uint& elementsPerSum [[ buffer(3) ]],
                                 const uint tgPos [[ threadgroup_position_in_grid ]],
                                 const uint tPerTg [[ threads_per_threadgroup ]],
                                 const uint tPos [[ thread_position_in_threadgroup ]]) {
    // This is the index of the individual result, this var is unique to this thread
    uint resultIndex = tgPos * tPerTg + tPos;
    // Where the summation should begin
    uint dataIndex = resultIndex * elementsPerSum;
    // The index where summation should end
    uint endIndex = dataIndex + elementsPerSum < dataLength ? dataIndex + elementsPerSum : dataLength;
    
    for (; dataIndex < endIndex; dataIndex++) {
        sums[resultIndex] += data[dataIndex];
    }
}
