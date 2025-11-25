//
//  BgRemover+MaskGenerator.swift
//  MonKi
//
//  Created by Yonathan Handoyo on 28/10/25.
//

import Vision

struct BackgroundRemoverMaskGenerator {
    func generate(from cgImage: CGImage) async throws -> (CVPixelBuffer, VNImageRequestHandler) {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try handler.perform([request])

                guard let result = request.results?.first,
                      !result.allInstances.isEmpty else {
                    continuation.resume(throwing: ProcessingError.noForeground)
                    return
                }

                let mask = try result.generateScaledMaskForImage(
                    forInstances: result.allInstances,
                    from: handler
                )
                continuation.resume(returning: (mask, handler))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
