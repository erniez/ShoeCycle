//  AddDistanceView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/6/23.
//  
//

import SwiftUI

struct AddDistanceView: View {
    @State var runDate = Date()
    @State var runDistance = ""
    let secondsInSixMonths: TimeInterval = 6 * 30.4 * 24 * 60 * 60
    var testStartDate: Date {
        Date() - secondsInSixMonths
    }
    var testEndDate: Date {
        Date() + 20 * 24 * 60 * 60
    }
    
    var body: some View {
        GeometryReader { screenGeometry in
            let height = screenGeometry.size.height
            let width = screenGeometry.size.width
            let progressBarWidth = screenGeometry.size.width * 0.6

            var dateFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter
            }

            ZStack {
                PatternedBackground()
                VStack {
                    HStack {
                        Image("logo")
                        Spacer()
                        ShoeImageView(width: width * 0.40, height: height * 0.20)
                            .offset(x: 0, y: 16)
                        Image("scroll-arrows")
                            .padding(.leading, 8)
                    }
                    .padding(16)
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(white: 1.0, opacity: 0.20))
                        DateDistanceEntryView(runDate: $runDate, runDistance: $runDistance)
                    }
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                    ShoeCycleDistanceProgressView(progressWidth: progressBarWidth, value: 35, endvalue: 350)
                    ShoeCycleDateProgressView(progressWidth: progressBarWidth, startDate: testStartDate, endDate: testEndDate)
                    Spacer()
                }
            }
        }
    }
}

struct AddDistanceView_Previews: PreviewProvider {
    static var previews: some View {
        AddDistanceView()
    }
}

struct ShoeImageView: View {
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
            Text("Shoe Name Big")
                .foregroundColor(Color.white)
                .padding(.top, 8)
                .lineLimit(1)
                .frame(width: width)
        }
    }
}

struct PatternedBackground: View {
    var body: some View {
        Image("perfTile")
            .resizable(resizingMode: .tile)
            .ignoresSafeArea()
    }
}

struct DateDistanceEntryView: View {
    @State private var buttonMaxHeight: CGFloat?
    @Binding var runDate: Date
    @Binding var runDistance: String
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Date:")
                    .padding(.bottom, -8)
                    .foregroundColor(.white)
                
                DatePicker("runDate",
                           selection: $runDate,
                           displayedComponents: [.date])
                .accentColor(.shoeCycleOrange)
                .foregroundColor(.white)
                .labelsHidden()
                .datePickerStyle(.compact)
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: RowHeightPreferenceKey.self,
                        value: geometry.size.height
                    )
                })
                .frame(height: buttonMaxHeight)
                .background(.black)
                .preferredColorScheme(.dark) // Need this to get white text in the field
                .cornerRadius(8)
                
                Button {
                    print("button tapped")
                } label: {
                    Label("History", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(.gray)
                        .cornerRadius(8)
                        .shadow(color: .black, radius: 2, x: 1, y:2)
                }
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            
            VStack(alignment: .leading) {
                Text("Distance:")
                    .padding(.bottom, -8)
                    .foregroundColor(.white)
                
                TextField(" Distance  ", text: $runDistance, prompt: Text(" Distance ").foregroundColor(.gray.opacity(0.60)))
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: RowHeightPreferenceKey.self,
                            value: geometry.size.height
                        )
                    })
                    .frame(height: buttonMaxHeight)
                    .frame(minWidth: 50)
                    .background(.black)
                    .cornerRadius(8)
                    .fixedSize()
                
                Button {
                    print("button tapped")
                } label: {
                    Label("Distances", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(.gray)
                        .cornerRadius(8)
                        .shadow(color: .black, radius: 2, x: 1, y: 2)
                }
            }
            .padding(.vertical, 8)
            .padding(.leading, 8)
            
            Spacer()
            
            Button {
                print(runDate)
            } label: {
                Image("button-add-run")
            }
            .padding(8)
        }
        .onPreferenceChange(RowHeightPreferenceKey.self) {
            buttonMaxHeight = $0
        }
    }
}

private extension DateDistanceEntryView {
    struct RowHeightPreferenceKey: PreferenceKey {
        static let defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat,
                           nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
}
