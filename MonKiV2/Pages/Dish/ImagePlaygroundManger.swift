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

// MARK: - Main Manager
final class ImagePlaygroundManager {
    static let shared = ImagePlaygroundManager()
    
    private let logger = Logger(subsystem: "ImagePlaygroundTest", category: "Manager")
    private var imageCreator: ImageCreator?
    
    private init() {}
    
    private struct IngredientDetail {
        let name: String
        let quantity: Int
    }
    
    private func parseIngredientDetails(from ingredients: String) -> [IngredientDetail] {
        let components = ingredients.split(separator: ",")
        return components.compactMap { component -> IngredientDetail? in
            let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let spaceIndex = trimmed.firstIndex(of: " ") else {
                return IngredientDetail(name: trimmed.lowercased(), quantity: 1)
            }
            let qtyPart = String(trimmed[..<spaceIndex])
            let namePart = String(trimmed[trimmed.index(after: spaceIndex)...]).lowercased()
            return IngredientDetail(name: namePart, quantity: Int(qtyPart) ?? 1)
        }
    }
    
    // MARK: - ULTRA MINIMALIST PROMPT BUILDER
    private func buildIllustrationPrompt(from ingredients: String) -> String {
        let parsed = parseIngredientDetails(from: ingredients)
        let nameSet = Set(parsed.map { $0.name })
        
        let base = getBaseIngredient(from: nameSet)
        let baseName = base?.name ?? ""
        
        let milkSide = getMilkString(from: parsed)
        
        let otherIngredients = parsed.filter { $0.name != "milk" && $0.name != baseName }
        let meatNames: Set<String> = ["fish", "beef", "chicken"]
        
        let meatStrings = otherIngredients
            .filter { meatNames.contains($0.name) }
            .map { getCookedIngredientString(for: $0) }
        
        let otherStrings = otherIngredients
            .filter { !meatNames.contains($0.name) }
            .map { getCookedIngredientString(for: $0) }
        
        let allIngredientStrings = meatStrings + otherStrings
        let ingredientsList = allIngredientStrings.joined(separator: ", ")
        
        if let baseDisplay = base?.display {
            if !ingredientsList.isEmpty {
                return "Made a gourmet dish of \(baseDisplay) with only \(ingredientsList), \(milkSide), nothing else is allowed. Pure white background, clean composition, no utensils, no cutlery, no tableware of any kind, no garnish, no sauce, no herbs, no extra items, no decoration, top-down view, vibrant illustration style."
            } else {
                return "Made a gourmet dish of \(baseDisplay), \(milkSide), nothing else is allowed. Pure white background, clean composition, no utensils, no cutlery, no tableware of any kind, no garnish, no sauce, no herbs, no extra items, no decoration, top-down view, vibrant illustration style."
            }
            
        }
        
        if !ingredientsList.isEmpty {
            return "Made a gourmet dish that containing only \(ingredientsList), \(milkSide), absolutely nothing else is allowed in the image. No extra ingredients, no garnish, no sauce, no herbs, no background objects. Pure white background, clean and simple composition, top-down view, vibrant food illustration style."
        }
        
        return "\(milkSide), absolutely nothing else is allowed in the image. No background objects. Pure white background, clean and simple composition, top-down view, vibrant food illustration style."
    }
    
    // MARK: - Generate Function
    func generateDish(from ingredients: String) async throws -> CGImage {
        for attempt in 1...2 {
            do {
                if imageCreator == nil || attempt > 1 {
                    logger.info("Creating ImageCreator... (attempt \(attempt))")
                    imageCreator = try await ImageCreator()
                }
                
                guard let creator = imageCreator else {
                    throw NSError(domain: "MonKiV2", code: -1, userInfo: [NSLocalizedDescriptionKey: "Creator not ready"])
                }
                
                let prompt = buildIllustrationPrompt(from: ingredients)
                logger.info("Prompt → \(prompt)")
                
                let concepts: [ImagePlaygroundConcept] = [.text(prompt)]
                let style: ImagePlaygroundStyle = .illustration
                
                let images = creator.images(for: concepts, style: style, limit: 1)
                
                for try await result in images {
                    let cgImage = result.cgImage
                    logger.info("Success: \(cgImage.width)×\(cgImage.height)")
                    return cgImage
                }
                
                throw NSError(domain: "MonKiV2", code: -2, userInfo: [NSLocalizedDescriptionKey: "No image returned"])
                
            } catch {
                logger.error("Attempt \(attempt) failed: \(error.localizedDescription)")
                imageCreator = nil
                
                if attempt == 2 {
                    throw NSError(
                        domain: "MonKiV2.ImageError",
                        code: 1001,
                        userInfo: [NSLocalizedDescriptionKey: "Gagal generate gambar"]
                    )
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
        
        throw NSError(domain: "ImagePlayground", code: -2, userInfo: [NSLocalizedDescriptionKey: "No image returned"])
    }
    
    // MARK: - Prompt Building Helpers
    private struct BaseIngredient {
        let name: String
        let display: String
    }
    
    private func getBaseIngredient(from nameSet: Set<String>) -> BaseIngredient? {
        if nameSet.contains("rice") {
            return BaseIngredient(name: "rice", display: ["fried rice", "sushi", "white rice"].randomElement() ?? "white rice")
        }
        if nameSet.contains("pasta") {
            return BaseIngredient(name: "pasta", display: "plain cooked pasta")
        }
        if nameSet.contains("bread") {
            return BaseIngredient(name: "bread", display: "plain bread")
        }
        if nameSet.contains("egg") {
            let display = ["a plain fried egg", "a fluffy omelette", "a boiled egg"].randomElement() ?? "boiled egg"
            return BaseIngredient(name: "egg", display: display)
        }
        return nil
    }
    
    private func getMilkString(from parsed: [IngredientDetail]) -> String {
        guard let milk = parsed.first(where: { $0.name == "milk" }) else { return "" }
        
        switch milk.quantity {
        case 1:
            return "with one glass of fresh milk on the side"
        case 2:
            return "with two glasses of fresh milk on the side"
        default: // 3 or more
            return "with a lot of glasses of fresh milk on the side"
        }
    }
    
    private func getCookedIngredientString(for detail: IngredientDetail) -> String {
        let cookedName: String
        
        switch detail.name.lowercased() {
        case "egg":
            cookedName = ["fried egg", "omelette", "boiled egg"].randomElement() ?? detail.name
        case "tomato", "broccoli", "carrot":
            cookedName = ["small chopped \(detail.name)", "small sliced \(detail.name)"].randomElement() ?? detail.name
        case "corn":
            cookedName = "small chopped \(detail.name) kernels"
        case "beef", "fish":
            cookedName = ["grilled \(detail.name)", "steamed \(detail.name)", "breaded \(detail.name)", "deep-fried \(detail.name)"].randomElement() ?? detail.name
        case "chicken":
            cookedName = ["grilled poultry", "steamed poultry", "breaded poultry", "deep-fried poultry"].randomElement() ?? detail.name
        default:
            cookedName = detail.name
        }
        
        if detail.quantity > 3 {
            let pluralName = cookedName.hasSuffix("s") ? cookedName : cookedName + "s"
            return "a lot of \(pluralName)"
        }
        if detail.quantity > 1 {
            let pluralName = cookedName.hasSuffix("s") ? cookedName : cookedName + "s"
            return "\(detail.quantity) \(pluralName)"
        }
        return cookedName
    }
}
