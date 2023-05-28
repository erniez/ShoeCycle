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

    private var xValues: [Date] {
        var dates = [Date]()
        collatedHistory.forEach { weeklyCollated in
            dates.append(weeklyCollated.date)
        }
        return dates
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
        var runDistances = [Float]()
        collatedHistory.forEach { runDistances.append($0.runDistance) }
        return runDistances.max() ?? 0
    }
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(collatedHistory) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Miles", item.runDistance),
                        series: .value("Weekly Distance", "A")
                    )
                    .foregroundStyle(Color.clear)
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
                            RuleMark(
                                y: .value("Max Mileage", maxDistance)
                            )
                            .foregroundStyle(Color.shoeCycleBlue)
                            .lineStyle(StrokeStyle(lineWidth: 3, dash: [10, 10]))
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
                        }
                        .animation(.easeOut(duration: 0.5), value: collatedHistory)
                    }
                }
            }

        }
    }
}

struct RunHistoryChart_Previews: PreviewProvider {
    static var shoe = MockShoeGenerator().generateNewShoeWithData()
    static var collated = Shoe.collateRunHistories(Array(shoe.history), ascending: true)

    static var previews: some View {
        RunHistoryChart(collatedHistory: collated)
    }
}
