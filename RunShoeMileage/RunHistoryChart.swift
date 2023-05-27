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
//    var history: [History] {
//        Array(shoe.history)
//    }
    private var xValues: [Date] {
        var dates = [Date]()
        collatedHistory.forEach { weeklyCollated in
            dates.append(weeklyCollated.date)
        }
        return dates
    }
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }
    func weekOfYear(from date: Date) -> Int {
        calendar.component(.weekOfYear, from: date)
    }
    
    var body: some View {
        ZStack {
            Chart {
                ForEach(collatedHistory, id: \.date) { item in
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
            
            ScrollView(.horizontal) {
                Chart {
                    ForEach(collatedHistory, id: \.date) { item in
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
                        y: .value("Max Mileage", 15)
                    )
                    .foregroundStyle(Color.shoeCycleBlue)
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [10, 10]))
                }
                .frame(width: 500)
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
                    AxisMarks(preset:.extended)
                }
                .animation(.easeOut(duration: 0.5), value: collatedHistory)
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
