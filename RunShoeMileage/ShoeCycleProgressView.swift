//  ShoeCycleProgressView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/17/23.
//  
//

import SwiftUI

fileprivate struct ShoeCycleProgressView: View {
    let progressWidth: CGFloat
    let progressColor: Color
    let progressBarValue: Float
    let value: Float
    let units: String
    let startValue: String
    let endValue: String
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ProgressView(value: progressBarValue)
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                    .frame(width: progressWidth, height: 10)
                    .padding(0)
                    .accentColor(progressColor)
                Image("tickmarks")
                    .resizable()
                    .frame(width: progressWidth, height: 16)
                    .aspectRatio(contentMode: .fit)
                HStack {
                    Text(startValue)
                    Spacer()
                    Text(endValue)
                }
                .foregroundColor(progressColor)
                .font(.callout)
                .frame(width: progressWidth)
            }
            Spacer()
            VStack(spacing: 0) {
                Text(formatNumberForDisplay(value: value))
                    .font(.largeTitle)
                Text(units)
                    .font(.headline)
                    .padding(.top, -4)
            }
            .foregroundColor(progressColor)
            Spacer()
        }
        .padding(16)
    }
    
    private func formatNumberForDisplay(value: Float) -> String {
        let number = NSNumber(value: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: number) ?? ""
    }
}

struct ShoeCycleDistanceProgressView: View {
    let progressWidth: CGFloat
    let value: Float
    let endvalue: Int
    private var progressBarValue: Float {
        min(1, value / Float(endvalue))
    }
    
    var body: some View {
        ShoeCycleProgressView(progressWidth: progressWidth, progressColor: .shoeCycleGreen, progressBarValue: progressBarValue, value: value, units: "miles", startValue: "0", endValue: String(endvalue))
    }
}

struct ShoeCycleDateProgressView: View {
    let progressWidth: CGFloat
    let startDate: Date
    let endDate: Date
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    private let secondsInDay: TimeInterval = 60 * 60 * 24
    private var progressBarValue: Double {
        let shoeDateDifference = endDate.timeIntervalSince(startDate) / secondsInDay
        let currentDateDifference = Date().timeIntervalSince(startDate) / secondsInDay
        let progressBarValue = min(1, currentDateDifference / shoeDateDifference)
        return progressBarValue
    }
    private var daysToGo: Int {
        let currentDateDifference = -Date().timeIntervalSince(endDate) / secondsInDay
        return max(0, Int(currentDateDifference))
    }
    
    var body: some View {
        ShoeCycleProgressView(progressWidth: progressWidth, progressColor: .shoeCycleBlue, progressBarValue: Float(progressBarValue), value: Float(daysToGo), units: "Days Left", startValue: Self.dateFormatter.string(from: startDate), endValue: Self.dateFormatter.string(from: endDate))
    }
}

struct ShoeCycleProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ShoeCycleProgressView(progressWidth: 200, progressColor: .shoeCycleGreen, progressBarValue: 0.3, value: 20, units: "miles", startValue: "0", endValue: "350")
            Spacer()
        }
        .background(.black)
    }
}
