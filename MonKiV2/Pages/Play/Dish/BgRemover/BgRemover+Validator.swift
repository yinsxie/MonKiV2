//
//  BgRemover+MaskValidation.swift
//  MonKi
//
//  Created by Yonathan Handoyo on 28/10/25.
//

import CoreVideo

struct BackgroundRemoverValidator {
    func validate(_ mask: CVPixelBuffer) async throws {
        let coverage = estimateCoverage(mask)

        if coverage > 0.9 {
            throw ProcessingError.tooMuchForeground
        } else if coverage < 0.01 {
            throw ProcessingError.noForegroundDetected
        }
    }

    private func estimateCoverage(_ pixelBuffer: CVPixelBuffer) -> Float {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let total = width * height

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return 0 }
        let rowBytes = CVPixelBufferGetBytesPerRow(pixelBuffer)
        var foreground = 0

        for yPos in 0..<height {
            let row = base.advanced(by: yPos * rowBytes)
            let pixels = row.assumingMemoryBound(to: UInt8.self)
            for xPos in 0..<width where pixels[xPos] > 128 {
                foreground += 1
            }
        }

        return Float(foreground) / Float(total)
    }
}
