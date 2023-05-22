//  ShoeImageView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/21/23.
//  
//

import SwiftUI

struct ShoeImageView: View {
    let width: CGFloat
    let height: CGFloat
    var shoeImage = Image("photo-placeholder")
    var shoeName = "Unnamed"

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
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.shoeCycleOrange, lineWidth: 2)
                    .frame(width: width, height: height)
                    .background(.black)
                shoeImage
                    .resizable()
                    .padding(24)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height, alignment: .center)
            }
            Text(shoeName)
                .foregroundColor(Color.white)
                .padding(.top, 8)
                .lineLimit(1)
                .frame(width: width)
        }
    }
}

struct ShoeImageView_Previews: PreviewProvider {
    static var previews: some View {
        ShoeImageView(width: 200, height: 150)
            .background(.black)
    }
}
