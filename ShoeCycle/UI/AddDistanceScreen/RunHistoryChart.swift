//  RunHistoryChart.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import SwiftUI
import Charts


struct RunHistoryChart: View {
    @EnvironmentObject var settings: UserSettings
    let collatedHistory: [WeeklyCollatedNew]
    @Binding var graphAllShoes: Bool
    
    @State private var state = RunHistoryChartState()
    private let interactor: RunHistoryChartInteractor
    
    private let formatter = NumberFormatter.decimal
    private let distanceUtility = DistanceUtility()
    private let pointsPerGraphData = 50

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }
    
    init(collatedHistory: [WeeklyCollatedNew], graphAllShoes: Binding<Bool>) {
        self.collatedHistory = collatedHistory
        self._graphAllShoes = graphAllShoes
        self.interactor = RunHistoryChartInteractor()
    }
    
    private func weekOfYear(from date: Date) -> Int {
        calendar.component(.weekOfYear, from: date)
    }
    
    var body: some View {
        VStack(spacing: 0){
            ZStack {
                // Fixed Chart to have fixed Y-axis and RuleMark.
                Chart {
                    ForEach(state.chartData) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value(settings.distanceUnit.displayString(), distanceUtility.distance(from: item.runDistance)),
                            series: .value("Weekly Distance", "A")
                        )
                        .foregroundStyle(Color.clear)
                    }
                    RuleMark(
                        y: .value("Max Mileage", distanceUtility.distance(from: state.maxDistance))
                    )
                    .foregroundStyle(Color.shoeCycleBlue)
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [10, 10]))
                    .annotation(position: .overlay, alignment: .bottomTrailing) {
                        Text(formatter.string(from: NSNumber(value: distanceUtility.distance(from: state.maxDistance))) ?? "")
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
                if state.chartData.count > 0 {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal) {
                            ZStack {
                                HStack(spacing: 0) {
                                    // Create an invisible rectangle for each data point, with zero space
                                    // between them. This will match the rectangle to a datapoint's location
                                    // in the ScrollView. Assign the datapoint's id to each rectangle so
                                    // that we can scroll to it later on.
                                    ForEach(state.chartData) { item in
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(maxWidth: .infinity, maxHeight: 0)
                                            .id(item.id)
                                    }
                                }
                                Chart {
                                    ForEach(state.chartData) { item in
                                        LineMark(
                                            x: .value("Date", item.date),
                                            y: .value(settings.distanceUnit.displayString(), distanceUtility.distance(from: item.runDistance)),
                                            series: .value("Weekly Distance", "A")
                                        )
                                        .foregroundStyle(Color.shoeCycleOrange)
                                        .symbol {
                                            Circle()
                                                .fill(Color.shoeCycleGreen)
                                                .frame(width: 7)
                                        }
                                    }
                                    // The RuleMark can mess with the Y-axis scaling, so we need to add an invisible one here so that the
                                    // Y-axis scales the same as the fixed chart above.
                                    RuleMark(
                                        y: .value("Max Mileage", distanceUtility.distance(from: state.maxDistance))
                                    )
                                    .foregroundStyle(Color.clear)
                                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [10, 10]))
                                    .annotation(position: .overlay, alignment: .bottomTrailing) {
                                        Text(formatter.string(from: NSNumber(value: distanceUtility.distance(from: state.maxDistance))) ?? "")
                                            .foregroundColor(Color.clear)
                                    }
                                }
                                .onAppear {
                                    if let lastItem = state.chartData.last {
                                        proxy.scrollTo(lastItem.id)
                                    }
                                }
                                .onChange(of: state.graphAllShoes) {
                                    if let lastItem = state.chartData.last {
                                        proxy.scrollTo(lastItem.id)
                                    }
                                }
                                .onChange(of: state.chartData) {
                                    if let lastItem = state.chartData.last {
                                        proxy.scrollTo(lastItem.id)
                                    }
                                }
                                .frame(width: CGFloat(state.chartData.count * pointsPerGraphData))
                                .chartXAxis() {
                                    AxisMarks(preset: .aligned, values: state.xValues) { value in
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
                                .animation(.easeOut(duration: 0.5), value: state.chartData)
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
                Button  {
                    interactor.handle(state: &state, action: .toggleGraphAllShoes)
                } label: {
                    Text(graphAllShoesToggleText())
                        .font(.callout)
                }
            }
        }
        .onAppear {
            interactor.handle(state: &state, action: .viewAppeared)
            interactor.handle(state: &state, action: .dataUpdated(collatedHistory))
        }
        .onChange(of: collatedHistory) { _, newData in
            interactor.handle(state: &state, action: .dataUpdated(newData))
        }
        .onChange(of: state.graphAllShoes) { _, newValue in
            graphAllShoes = newValue
        }
    }
    
    func graphAllShoesToggleText() -> String {
        if state.graphAllShoes == true {
            return "Graph Current Shoe"
        }
        else {
            return "Graph All Active Shoes"
        }
    }
}
