//
//  BgRemover+ImageComposer.swift
//  MonKi
//
//  Created by Yonathan Handoyo on 28/10/25.
//

import CoreImage.CIFilterBuiltins
import Vision
import UIKit

struct BackgroundRemoverImageComposer {
    private let context = CIContext(options: [.useSoftwareRenderer: true])
    private let outlineThickness: CGFloat = 20.0
    
    func processDrawing(_ image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw ProcessingError.invalidImage
        }
        
        let originalCI = CIImage(cgImage: cgImage)
        let whiteDrawing = CIImage(color: .white)
            .cropped(to: originalCI.extent)
            .applyingFilter("CIBlendWithAlphaMask", parameters: [
                kCIInputMaskImageKey: originalCI
            ])
        
        let outlineMask = try applyOutline(to: whiteDrawing)
        let foreground = originalCI
        let compositeImage = try composite(foreground: foreground, outline: outlineMask)
        
        return try render(compositeImage, extent: originalCI.extent)
    }
    
    func compose(
        original cgImage: CGImage,
        mask: CVPixelBuffer,
        handler: VNImageRequestHandler
    ) async throws -> UIImage {

        let maskCI = CIImage(cvPixelBuffer: mask)
        let originalCI = CIImage(cgImage: cgImage)
        let scaledMask = scale(mask: maskCI, to: originalCI)

        let foreground = try blendForeground(originalCI, mask: scaledMask)
        let outline = try applyOutline(to: scaledMask)
        let compositeImage = try composite(foreground: foreground, outline: outline)

        return try render(compositeImage, extent: originalCI.extent)
    }

    private func scale(mask: CIImage, to original: CIImage) -> CIImage {
        guard mask.extent.size != original.extent.size else { return mask }
        let scaleX = original.extent.width / mask.extent.width
        let scaleY = original.extent.height / mask.extent.height
        return mask.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
    }

    private func applyOutline(to mask: CIImage) throws -> CIImage {
        let filter = CIFilter.morphologyMaximum()
        filter.inputImage = mask
        filter.radius = Float(outlineThickness)
        guard let output = filter.outputImage else {
            throw ProcessingError.filterFailed
        }
        return output
    }

    private func blendForeground(_ image: CIImage, mask: CIImage) throws -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.clear
        guard let output = filter.outputImage else {
            throw ProcessingError.filterFailed
        }
        return output
    }

    private func composite(foreground: CIImage, outline: CIImage) throws -> CIImage {
        let white = CIImage(color: .white).cropped(to: outline.extent)
        let outlineBlend = CIFilter.blendWithMask()
        outlineBlend.inputImage = white
        outlineBlend.maskImage = outline
        outlineBlend.backgroundImage = CIImage.clear
        guard let outlineOutput = outlineBlend.outputImage else {
            throw ProcessingError.filterFailed
        }

        let comp = CIFilter.sourceOverCompositing()
        comp.inputImage = foreground
        comp.backgroundImage = outlineOutput
        guard let output = comp.outputImage else {
            throw ProcessingError.filterFailed
        }
        return output
    }

    private func render(_ image: CIImage, extent: CGRect) throws -> UIImage {
        guard let cgImage = context.createCGImage(image, from: extent) else {
            throw ProcessingError.renderFailed
        }
        return UIImage(cgImage: cgImage)
    }
}
