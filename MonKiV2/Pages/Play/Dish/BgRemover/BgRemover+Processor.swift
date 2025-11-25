//
//  BgRemover+Processor.swift
//  MonKi
//
//  Created by Yonathan Handoyo on 28/10/25.
//

import UIKit

struct BackgroundRemoverProcessor {
    private let maskGenerator = BackgroundRemoverMaskGenerator()
    private let validator = BackgroundRemoverValidator()
    private let composer = BackgroundRemoverImageComposer()

    func process(_ image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw ProcessingError.invalidImage
        }

        let (mask, handler) = try await maskGenerator.generate(from: cgImage)
        try await validator.validate(mask)

        return try await composer.compose(
            original: cgImage,
            mask: mask,
            handler: handler
        )
    }
}
