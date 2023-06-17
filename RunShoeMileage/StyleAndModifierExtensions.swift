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

extension TextFieldStyle where Self == NumberEntryStyle {
    static var numberEntry: NumberEntryStyle { NumberEntryStyle() }
}

