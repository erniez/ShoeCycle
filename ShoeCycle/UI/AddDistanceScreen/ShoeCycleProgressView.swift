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
    let progressBarValue: Double
    let value: Double
    let units: String
    let startValue: String
    let endValue: String
    @Binding var shouldBounce: Bool
    
    @State private var state = ShoeCycleProgressState()
    private let interactor: ShoeCycleProgressInteractor
    
    private let animationDuration: TimeInterval = 0.25
    
    init(progressWidth: CGFloat, progressColor: Color, progressBarValue: Double, value: Double, units: String, startValue: String, endValue: String, shouldBounce: Binding<Bool>) {
        self.progressWidth = progressWidth
        self.progressColor = progressColor
        self.progressBarValue = progressBarValue
        self.value = value
        self.units = units
        self.startValue = startValue
        self.endValue = endValue
        self._shouldBounce = shouldBounce
        self.interactor = ShoeCycleProgressInteractor()
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                ProgressView(value: progressBarValue)
                    .scaleEffect(x: 1, y: 2, anchor: .bottom)
                    .frame(width: progressWidth, height: 5)
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
            .offset(CGSize(width: 0, height: 8))
            Spacer()
            VStack(spacing: 0) {
                Text(formatNumberForDisplay(value: value))
                    .font(.title)
                Text(units)
                    .font(.headline)
                    .padding(.top, -4)
            }
            .scaleEffect(state.bounceState ? 1.75 : 1.0)
            .foregroundColor(progressColor)
            Spacer()
        }
        .onChange(of: value) {
            if shouldBounce {
                interactor.handle(state: &state, action: .bounceTriggered)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animationDuration) {
                    interactor.handle(state: &state, action: .bounceStateChanged(false))
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
                shouldBounce = false
            }
        }
        .animation(.bouncy(duration: animationDuration, extraBounce: 0.3), value: state.bounceState)
    }
    
    private func formatNumberForDisplay(value: Double) -> String {
        let number = NSNumber(value: value)
        return NumberFormatter.decimal.string(from: number) ?? ""
    }
    
}

struct ShoeCycleDistanceProgressView: View {
    @EnvironmentObject var settings: UserSettings
    let progressWidth: CGFloat
    let value: Double
    let endvalue: Int
    @Binding var shouldBounce: Bool
    
    private var progressBarValue: Double {
        min(1, value / Double(endvalue))
    }
    private let distanceUtility = DistanceUtility()
    
    var body: some View {
        ShoeCycleProgressView(
            progressWidth: progressWidth, 
            progressColor: .shoeCycleGreen, 
            progressBarValue: progressBarValue, 
            value: distanceUtility.distance(from: value), 
            units: settings.distanceUnit.displayString().capitalized, 
            startValue: "0", 
            endValue: String(Int(distanceUtility.distance(from: Double(endvalue)))), 
            shouldBounce: $shouldBounce
        )
    }
}

struct ShoeCycleDateProgressView: View {
    let progressWidth: CGFloat
    let viewModel: DateProgressViewModel
    
    var body: some View {
        ShoeCycleProgressView(
            progressWidth: progressWidth, 
            progressColor: .shoeCycleBlue, 
            progressBarValue: viewModel.progressBarValue, 
            value: Double(viewModel.daysToGo), 
            units: "Days Left", 
            startValue: DateFormatter.shortDate.string(from: viewModel.startDate), 
            endValue: DateFormatter.shortDate.string(from: viewModel.endDate), 
            shouldBounce: viewModel.$shouldBounce
        )
    }
}

struct ShoeCycleProgressView_Previews: PreviewProvider {
    @State static var shouldBounce = false
    static var previews: some View {
        VStack {
            Spacer()
            ShoeCycleProgressView(progressWidth: 200, progressColor: .shoeCycleGreen, progressBarValue: 0.3, value: 20, units: "miles", startValue: "0", endValue: "350", shouldBounce: $shouldBounce)
            ShoeCycleDateProgressView(progressWidth: 200, viewModel: DateProgressViewModel(startDate: Date(timeIntervalSinceNow: -100 * TimeInterval.secondsInDay), endDate: Date(timeIntervalSinceNow: 50 * TimeInterval.secondsInDay), shouldBounce: $shouldBounce))
            Spacer()
        }
        .background(.black)
    }
}
