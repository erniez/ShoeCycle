//  RunHistoryChart.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import SwiftUI
import Charts


struct RunHistoryChart: View {
    let collatedHistory: [WeeklyCollatedNew]
    
    private let formatter = NumberFormatter.decimal

    private var xValues: [Date] {
        collatedHistory.map { $0.date }
    }
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }
    private func weekOfYear(from date: Date) -> Int {
        calendar.component(.weekOfYear, from: date)
    }
    var maxDistance: Float {
        let maxDistance = collatedHistory.reduce(Float(0)) { return max($0, $1.runDistance) }
        return maxDistance
    }
    
    var body: some View {
        VStack(spacing: 0){
            ZStack {
                // Fixed Chart to have fixed Y-axis and RuleMark.
                Chart {
                    ForEach(collatedHistory) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Miles", item.runDistance),
                            series: .value("Weekly Distance", "A")
                        )
                        .foregroundStyle(Color.clear)
                    }
                    RuleMark(
                        y: .value("Max Mileage", maxDistance)
                    )
                    .foregroundStyle(Color.shoeCycleBlue)
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [10, 10]))
                    .annotation(position: .overlay, alignment: .bottomTrailing) {
                        Text(formatter.string(from: NSNumber(value: maxDistance)) ?? "")
                            .foregroundColor(.shoeCycleBlue)
                    }
                }
                .chartYAxis() {
                    AxisMarks(preset:.extended, position: .leading)
                }
                .chartXAxis() {
                    AxisMarks {
                        AxisGridLine()
                              .foregroundStyle(Color.clear)
                    }
                    AxisMarks() {
                        AxisValueLabel() {
                            Text("Invisible")
                                .foregroundColor(.clear)
                        }
                    }
                }
                .foregroundColor(.clear)
                .padding([.bottom], 8)
                
                // TODO: Better handle zero history case
                // Scrollable Chart for X-axis
                if collatedHistory.count > 0 {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal) {
                            ZStack {
                                HStack(spacing: 0) {
                                    // Create an invisible rectangle for each data point, with zero space
                                    // between them. This will match the rectangle to a datapoint's location
                                    // in the ScrollView. Assign the datapoint's id to each rectangle so
                                    // that we can scroll to it later on.
                                    ForEach(collatedHistory) { item in
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(maxWidth: .infinity, maxHeight: 0)
                                            .id(item.id)
                                    }
                                }
                                Chart {
                                    ForEach(collatedHistory) { item in
                                        LineMark(
                                            x: .value("Date", item.date),
                                            y: .value("Miles", item.runDistance),
                                            series: .value("Weekly Distance", "A")
                                        )
                                        .foregroundStyle(Color.shoeCycleOrange)
                                        .symbol {
                                            Circle()
                                                .fill(Color.shoeCycleGreen)
                                                .frame(width: 7)
                                        }
                                    }
                                }
                                .onAppear {
                                    proxy.scrollTo(collatedHistory.last!.id)
                                }
                                .frame(width: 1000)
                                .chartXAxis() {
                                    AxisMarks(preset: .aligned, values: xValues) { value in
                                        if let date = value.as(Date.self) {
                                            // Show every other date
                                            if weekOfYear(from: date) % 2 == 0 {
                                                AxisValueLabel() {
                                                    VStack(alignment: .trailing) {
                                                        Text(DateFormatter.shortDate.string(from: date))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .chartYAxis() {
                                    AxisMarks(preset:.extended, position: .leading) {
                                        AxisValueLabel()
                                            .foregroundStyle(Color.clear)
                                    }
                                }
                                .animation(.easeOut(duration: 0.5), value: collatedHistory)
                                .padding([.bottom], 8)
                            }
                        }
                        // Add insets so that dates don't get cutoff at the edges of the graph
                        .safeAreaInset(edge: .trailing) {
                            Text("   ")
                                .foregroundColor(.clear)
                        }
                        .safeAreaInset(edge: .leading) {
                            Text("  ")
                                .foregroundColor(.clear)
                        }
                    }
                }

            }
            // Have to add legend manually because of all the hacky stuff I had to do to make this a
            // a scrolling chart.
            // Legend:
            HStack (spacing: 8) {
                Rectangle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.shoeCycleOrange)
                Text("Weekly Distance")
                    .font(.footnote)
                    .dynamicTypeSize(.medium)
                Spacer()
            }
        }
    }
}
