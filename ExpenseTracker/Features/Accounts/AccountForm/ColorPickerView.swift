//
//  ColorPickerView.swift
//  ExpenseTracker
//
//  Created by Didar on 25.01.2026.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColor: String
    let onSelect: (String) -> Void
    
    private struct ColorOption: Identifiable {
        let id: String
        let name: String
        let color: Color
        
        init(_ name: String, _ color: Color) {
            self.id = name
            self.name = name
            self.color = color
        }
    }
    
    private let colors: [ColorOption] = [
        ColorOption("blue", .blue),
        ColorOption("green", .green),
        ColorOption("orange", .orange),
        ColorOption("red", .red),
        ColorOption("purple", .purple),
        ColorOption("pink", .pink)
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(colors) { colorOption in
                    colorButton(for: colorOption)
                }
            }
        }
    }
    
    private func colorButton(for colorOption: ColorOption) -> some View {
        Button {
            selectedColor = colorOption.name
            onSelect(colorOption.name)
        } label: {
            ZStack {
                Circle()
                    .fill(colorOption.color)
                    .frame(width: 36, height: 36)
                
                if selectedColor == colorOption.name {
                    Circle()
                        .strokeBorder(.white, lineWidth: 2.5)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
