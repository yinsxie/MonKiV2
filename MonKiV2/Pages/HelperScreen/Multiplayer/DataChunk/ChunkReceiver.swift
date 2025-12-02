//
//  ChunkReceiver.swift
//  MonKiV2
//
//  Created by William on 29/11/25.
//
import Foundation

final class ChunkReceiver {
    // transferID → list of chunks
    private var buffers: [String: [Int: Data]] = [:]
    // transferID → total chunks
    private var totalCount: [String: Int] = [:]
    
    var onComplete: ((Data) -> Void)?
    
    func handleIncoming(_ chunk: DataChunk) {
        let id = chunk.transferID
        
        if buffers[id] == nil {
            buffers[id] = [:]
            totalCount[id] = chunk.total
        }
        
        // store chunk
        buffers[id]?[chunk.index] = chunk.payload
        
        // check if all received
        if buffers[id]?.count == totalCount[id] {
            assemble(transferID: id)
        }
    }
    
    private func assemble(transferID id: String) {
        guard let total = totalCount[id],
              let dict = buffers[id] else { return }
        
        var full = Data()
        
        for i in 0..<total {
            if let chunkData = dict[i] {
                full.append(chunkData)
            } else {
                print("Missing chunk \(i)")
                return
            }
        }
        
        // cleanup
        buffers.removeValue(forKey: id)
        totalCount.removeValue(forKey: id)
        
        onComplete?(full)
    }
}
