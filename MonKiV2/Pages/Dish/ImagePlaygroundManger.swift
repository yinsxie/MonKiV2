//
//  ImagePlaygroundManger.swift
//  MonKiV2
//
//  Created by Yonathan Handoyo on 13/11/25.
//

import Foundation
import UIKit
import ImagePlayground
import OSLog

final class ImagePlaygroundManager {
    static let shared = ImagePlaygroundManager()
    
    private let logger = Logger(subsystem: "ImagePlaygroundTest", category: "Manager")
    private var imageCreator: ImageCreator?
    
    private init() {}
    
    func generateDish(from ingredients: String) async throws -> CGImage {
        if imageCreator == nil {
            print("Creating new ImageCreator...")
            imageCreator = try await ImageCreator()
        }
        
        guard let creator = imageCreator else {
            throw NSError(domain: "ImagePlayground", code: -1, userInfo: [NSLocalizedDescriptionKey: "Creator not ready"])
        }
        
        let prompt = "Single gourmet dish with \(ingredients) without utensils and cutlery"
        
        print("Prompt: \(prompt)")
        
        let concepts: [ImagePlaygroundConcept] = [.text(prompt)]
        let style: ImagePlaygroundStyle = .illustration
        
        let images = creator.images(for: concepts, style: style, limit: 1)
        
        for try await result in images {
            let cgImage = result.cgImage
            print("Image generated (\(cgImage.width)×\(cgImage.height))")
            return cgImage
        }
        
        throw NSError(domain: "ImagePlayground", code: -2, userInfo: [NSLocalizedDescriptionKey: "No image returned"])
    }
}
