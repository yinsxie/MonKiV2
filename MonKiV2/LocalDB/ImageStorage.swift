//
//  ImageStorage.swift
//  MonKiV2
//
//  Created by Aretha Natalova Wahyudi on 19/11/25.
//
import SwiftUI

struct ImageStorage {
    
    static func saveImage(_ image: UIImage) -> String? {
        guard let data = image.pngData() else { return nil }
        
        let fileName = UUID().uuidString + ".png"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName 
        } catch {
            print("Error saving image to disk: \(error)")
            return nil
        }
    }
    
    static func loadImage(from fileName: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private static func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
