//
//  FlowLayout.swift
//  MonKi
//
//  Created by Aretha Natalova Wahyudi on 30/10/25.
//
import SwiftUI

struct FlowLayout: Layout {
    var alignment: Alignment
    var spacing: CGFloat
    
    enum Alignment {
        case leading
        case center
    }
    
    init(alignment: Alignment = .leading, spacing: CGFloat = 8) {
        self.alignment = alignment
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return calculateLayout(proposal: proposal, sizes: sizes).totalSize
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let availableWidth = bounds.width
        let layout = calculateLayout(proposal: proposal, sizes: sizes, availableWidth: availableWidth)
        
        for (index, subview) in subviews.enumerated() {
            let offset = layout.offsets[index]
            subview.place(at: CGPoint(x: offset.x + bounds.minX, y: offset.y + bounds.minY), proposal: .unspecified)
        }
    }
    
    private func calculateLayout(proposal: ProposedViewSize, sizes: [CGSize], availableWidth: CGFloat? = nil) -> (offsets: [CGPoint], totalSize: CGSize) {
        var offsets: [CGPoint] = Array(repeating: .zero, count: sizes.count)
        var currentRowItems: [(index: Int, size: CGSize)] = []
        var currentRowWidth: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalSize: CGSize = .zero
        
        let layoutWidth = availableWidth ?? proposal.width ?? .infinity
        
        func layoutRow() {
            guard !currentRowItems.isEmpty else { return }
            
            let rowWidth = currentRowWidth - spacing
            
            let startingX: CGFloat
            switch alignment {
            case .leading:
                startingX = 0
            case .center:
                startingX = (layoutWidth - rowWidth) / 2
            }
            
            var currentX = startingX
            for (index, size) in currentRowItems {
                offsets[index] = CGPoint(x: currentX, y: currentY)
                currentX += size.width + spacing
            }
            
            currentY += lineHeight + spacing
            
            lineHeight = 0
            currentRowWidth = 0
            currentRowItems = []
        }
        
        for (index, size) in sizes.enumerated() {
            if (currentRowWidth + size.width) > layoutWidth && !currentRowItems.isEmpty {
                totalSize.width = max(totalSize.width, currentRowWidth - spacing) 
                layoutRow()
            }
            
            currentRowItems.append((index: index, size: size))
            currentRowWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        totalSize.width = max(totalSize.width, currentRowWidth - spacing)
        layoutRow()
        
        totalSize.height = max(0, currentY - spacing)
        
        return (offsets, totalSize)
    }
}
