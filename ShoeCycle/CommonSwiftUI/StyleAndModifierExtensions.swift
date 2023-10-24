//  StyleAndModifierExtensions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/17/23.
//  
//

import SwiftUI


struct NumberEntryStyle: TextFieldStyle {
  public func _body(
    configuration: TextField<Self._Label>) -> some View {
      return configuration
            .keyboardType(.decimalPad)
            .lineLimit(1)
            .foregroundColor(.oppositeBlack)
            .accentColor(.oppositeBlack)
            .textFieldStyle(.roundedBorder)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(8)
  }
}

struct TextEntryStyle: TextFieldStyle {
  public func _body(
    configuration: TextField<Self._Label>) -> some View {
      return configuration
            .lineLimit(1)
            .foregroundColor(.oppositeBlack)
            .accentColor(.oppositeBlack)
            .textFieldStyle(.roundedBorder)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(8)
  }
}

extension TextFieldStyle where Self == NumberEntryStyle {
    static var numberEntry: NumberEntryStyle { NumberEntryStyle() }
}

struct ShoeCycleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .white.opacity(0.4) : .white)
            .padding(8)
            .background(configuration.isPressed ? .gray.opacity(0.4) : .gray)
            .cornerRadius(8)
            .shadow(color: .black, radius: 2, x: 1, y: 2)
    }
}

extension ButtonStyle where Self == ShoeCycleButtonStyle {
    static var shoeCycle: ShoeCycleButtonStyle { ShoeCycleButtonStyle() }
}

extension View {
    func shoeCycleSection(title: String, color: Color, image: Image) -> some View {
        modifier(ShoeCycleSection(title: title, color: color, image: image))
    }
}

extension Shape where Self == RoundedRectangle {
    static var shoeCycleRoundedRectangle: some Shape {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
    }
}

