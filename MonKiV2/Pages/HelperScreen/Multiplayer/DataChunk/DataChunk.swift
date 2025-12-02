//
//  DataChunk.swift
//  MonKiV2
//
//  Created by William on 29/11/25.
//
import Foundation

struct DataChunk: Codable {
    let transferID: String
    let index: Int
    let total: Int
    let payload: Data
}

func makeChunks(from data: Data, chunkSize: Int = 25_000) -> [DataChunk] {
    let transferID = UUID().uuidString
    var chunks: [DataChunk] = []
    
    let total = Int(ceil(Double(data.count) / Double(chunkSize)))
    
    for i in 0..<total {
        let start = i * chunkSize
        let end = min(start + chunkSize, data.count)
        let subdata = data.subdata(in: start..<end)
        
        let chunk = DataChunk(
            transferID: transferID,
            index: i,
            total: total,
            payload: subdata
        )
        chunks.append(chunk)
    }
    
    return chunks
}


