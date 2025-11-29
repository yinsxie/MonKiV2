//
//  Font+ext.swift
//  MonKi
//
//  Created by Aretha Natalova Wahyudi on 27/10/25.
//

import SwiftUI

extension Font {
    
    static func wendyOne(size: CGFloat) -> Font {
        return Font.custom("WendyOne-Regular", size: size)
    }
    
    static func wendyOne(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        return Font.custom("WendyOne-Regular", size: size, relativeTo: style)
    }
    
    static func VT323(size: CGFloat) -> Font {
        return Font.custom("VT323-Regular", size: size)
    }
    
    static func VT323(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        return Font.custom("VT323-Regular", size: size, relativeTo: style)
    }
    
    static func fredokaOne(size: CGFloat) -> Font {
        return Font.custom("FredokaOne-Regular", size: size)
    }
    
    static func fredokaOne(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        return Font.custom("FredokaOne-Regular", size: size, relativeTo: style)
    }
    
    static func fredokaLight(size: CGFloat) -> Font {
        return Font.custom("Fredoka-Light", size: size)
    }

    static func fredokaLight(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        return Font.custom("Fredoka-Light", size: size, relativeTo: style)
    }
    
    static func fredokaMedium(size: CGFloat) -> Font {
        return Font.custom("Fredoka-Medium", size: size)
    }

    static func fredokaMedium(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        return Font.custom("Fredoka-Medium", size: size, relativeTo: style)
    }
    
    static func fredokaRegular(size: CGFloat) -> Font {
        return Font.custom("Fredoka-Regular", size: size)
    }

    static func fredokaRegular(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        return Font.custom("Fredoka-Regular", size: size, relativeTo: style)
    }
    
    static func fredokaSemiBold(size: CGFloat) -> Font {
        return Font.custom("Fredoka-SemiBold", size: size)
    }

    static func fredokaSemiBold(size: CGFloat, relativeTo style: Font.TextStyle) -> Font {
        return Font.custom("Fredoka-SemiBold", size: size, relativeTo: style)
    }
}

extension Font {
    
    // MARK: - Helper Function
    
    private static func systemRounded(size: CGFloat, weight: Font.Weight) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }
    
    // MARK: - Typography Styles (Matching Figma)
    
    // --- Large Title ---
    static var largeTitleRegular: Font {
        return .systemRounded(size: 34, weight: .regular)
    }
    
    static var largeTitleMedium: Font {
        return .systemRounded(size: 34, weight: .medium)
    }
    
    static var largeTitleSemibold: Font {
        return .systemRounded(size: 34, weight: .semibold)
    }
    
    static var largeTitleEmphasized: Font {
        return .systemRounded(size: 34, weight: .bold)
    }
    
    // --- Title 1 ---
    static var title1Regular: Font {
        return .systemRounded(size: 28, weight: .regular)
    }
    
    static var title1Medium: Font {
        return .systemRounded(size: 28, weight: .medium)
    }
    
    static var title1Semibold: Font {
        return .systemRounded(size: 28, weight: .semibold)
    }
    
    static var title1Emphasized: Font {
        return .systemRounded(size: 28, weight: .bold)
    }
    
    // --- Title 2 ---
    static var title2Regular: Font {
        return .systemRounded(size: 22, weight: .regular)
    }
    
    static var title2Medium: Font {
        return .systemRounded(size: 22, weight: .medium)
    }
    
    static var title2Semibold: Font {
        return .systemRounded(size: 22, weight: .semibold)
    }
    
    static var title2Emphasized: Font {
        return .systemRounded(size: 22, weight: .bold)
    }
    
    // --- Title 3 ---
    static var title3Regular: Font {
        return .systemRounded(size: 20, weight: .regular)
    }
    
    static var title3Medium: Font {
        return .systemRounded(size: 20, weight: .medium)
    }
    
    static var title3Semibold: Font {
        return .systemRounded(size: 20, weight: .semibold)
    }
    
    static var title3Emphasized: Font {
        return .systemRounded(size: 20, weight: .bold)
    }
    
    // --- Headline ---
    static var headlineRegular: Font {
        return .systemRounded(size: 17, weight: .regular)
    }
    
    static var headlineMedium: Font {
        return .systemRounded(size: 17, weight: .medium)
    }
    
    static var headlineSemibold: Font {
        return .systemRounded(size: 17, weight: .semibold)
    }
    
    static var headlineEmphasized: Font {
        return .systemRounded(size: 17, weight: .bold)
    }
    
    // --- Body ---
    static var bodyRegular: Font {
        return .systemRounded(size: 17, weight: .regular)
    }
    
    static var bodyMedium: Font {
        return .systemRounded(size: 17, weight: .medium)
    }
    
    static var bodySemibold: Font {
        return .systemRounded(size: 17, weight: .semibold)
    }
    
    static var bodyEmphasized: Font {
        return .systemRounded(size: 17, weight: .bold)
    }
    
    // --- Callout ---
    static var calloutRegular: Font {
        return .systemRounded(size: 16, weight: .regular)
    }
    
    static var calloutMedium: Font {
        return .systemRounded(size: 16, weight: .medium)
    }
    
    static var calloutSemibold: Font {
        return .systemRounded(size: 16, weight: .semibold)
    }
    
    static var calloutEmphasized: Font {
        return .systemRounded(size: 16, weight: .bold)
    }
    
    // --- Subheadline ---
    static var subheadlineRegular: Font {
        return .systemRounded(size: 15, weight: .regular)
    }
    
    static var subheadlineMedium: Font {
        return .systemRounded(size: 15, weight: .medium)
    }
    
    static var subheadlineSemibold: Font {
        return .systemRounded(size: 15, weight: .semibold)
    }
    
    static var subheadlineEmphasized: Font {
        return .systemRounded(size: 15, weight: .bold)
    }
    
    // --- Footnote ---
    static var footnoteRegular: Font {
        return .systemRounded(size: 13, weight: .regular)
    }
    
    static var footnoteMedium: Font {
        return .systemRounded(size: 13, weight: .medium)
    }
    
    static var footnoteSemibold: Font {
        return .systemRounded(size: 13, weight: .semibold)
    }
    
    static var footnoteEmphasized: Font {
        return .systemRounded(size: 13, weight: .bold)
    }
    
    // --- Caption1 ---
    static var caption1Regular: Font {
        return .systemRounded(size: 12, weight: .regular)
    }
    
    static var caption1Medium: Font {
        return .systemRounded(size: 12, weight: .medium)
    }
    
    static var caption1Semibold: Font {
        return .systemRounded(size: 12, weight: .semibold)
    }
    
    static var caption1Emphasized: Font {
        return .systemRounded(size: 12, weight: .bold)
    }
    
    // --- Caption2 ---
    static var caption2Regular: Font {
        return .systemRounded(size: 11, weight: .regular)
    }
    
    static var caption2Medium: Font {
        return .systemRounded(size: 11, weight: .medium)
    }
    
    static var caption2Semibold: Font {
        return .systemRounded(size: 11, weight: .semibold)
    }
    
    static var caption2Emphasized: Font {
        return .systemRounded(size: 11, weight: .bold)
    }
}
