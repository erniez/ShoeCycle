//  AddDistanceView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/6/23.
//  
//

import SwiftUI


// For testing purposes only. So I can launch from Obj-C
@objc class AddDistanceViewFactory: NSObject {
    
    @objc static func create() -> UIViewController {
        let addDistanceView = AddDistanceView()
        let hostingController = UIHostingController(rootView: addDistanceView)
        return hostingController
    }
    
}

struct AddDistanceView: View {
    @State private var runDate = Date()
    @State private var runDistance = ""
    // This is not dynamic, yet.
    var shoe = ShoeStore.default().getCurrentlyActiveShoe()
    
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
                        ShoeImageView(width: width * 0.40, height: height * 0.20, shoeName: shoe.brand)
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
                    ShoeCycleDistanceProgressView(progressWidth: progressBarWidth, value: shoe.totalDistance.floatValue, endvalue: shoe.maxDistance.intValue)
                    ShoeCycleDateProgressView(progressWidth: progressBarWidth, interactor: DateProgressViewInteractor(startDate: shoe.startDate, endDate: shoe.expirationDate))
                    Spacer()
                }
            }
        }
    }
}

struct AddDistanceView_Previews: PreviewProvider {
    static var shoe = MockShoeGenerator().generateNewShoeWithData()
    
    static var previews: some View {
        AddDistanceView(shoe: shoe)
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
