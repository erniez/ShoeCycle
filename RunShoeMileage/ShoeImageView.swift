//  ShoeImageView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/21/23.
//  
//

import SwiftUI

struct ShoeImageView: View {
    @ObservedObject var shoe: Shoe
    let width: CGFloat
    let height: CGFloat
    var shoeImage = Image("photo-placeholder")

    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                let pointerSquareSize: CGFloat = 16.0
                Rectangle()
                    .frame(width: pointerSquareSize, height: pointerSquareSize)
                    .border(Color.shoeCycleOrange)
                    .foregroundColor(Color.shoeCycleOrange)
                    .rotationEffect(Angle(degrees: 45))
                    .offset(x: 0, y: pointerSquareSize/2)
                ShoeImage(shoe: shoe, allowImageChange: false)
                    .frame(maxWidth: width)
            }
            Text(shoe.brand)
                .foregroundColor(Color.white)
                .padding(.top, 8)
                .lineLimit(1)
                .frame(width: width)
        }
    }
}

struct ShoeImageView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData()
    
    static var previews: some View {
        ShoeImageView(shoe: shoe, width: 200, height: 150)
            .background(.black)
    }
}
