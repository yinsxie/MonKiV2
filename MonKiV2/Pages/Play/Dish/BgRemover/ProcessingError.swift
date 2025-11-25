//
//  ProcessingError.swift
//  MonKi
//
//  Created by Yonathan Handoyo on 28/10/25.
//

import Foundation

enum ProcessingError: LocalizedError {
    case invalidImage, noForeground, noForegroundDetected
    case tooMuchForeground, filterFailed, renderFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage: "Gambar Tidak Valid"
        case .noForeground: "Gagal Membuat Mask Objek"
        case .noForegroundDetected: "Tidak Ada Objek yang Terdeteksi"
        case .tooMuchForeground: "Objek Terdeteksi Terlalu Besar"
        case .filterFailed: "Gagal Menerapkan Filter"
        case .renderFailed: "Gagal Membuat Gambar Akhir"
        }
    }
}
