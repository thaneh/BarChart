//
//  MarksBarChartRace.swift
//  BarChart
//
//  Created by Thane Heninger on 10/25/20.
//  Copied from Mark Lucking's article: https://medium.com/better-programming/a-bar-chart-race-using-swiftui-2-0-ef84dc68b678
//

import SwiftUI
import Combine

let updateBar = PassthroughSubject<BarData, Never>()

final class MarksFigures {
    static var shared = MarksFigures()
    var bars = [BarData]()
    
    var activityTimer: Timer?
    
    init() {
        bars.append(BarData(text: "Apples", numbers: 90, position: 0))
        bars.append(BarData(text: "Bananas", numbers: 50, position: bars.count))
        bars.append(BarData(text: "Blueberry", numbers: 80, position: bars.count))
        bars.append(BarData(text: "Figs", numbers: 40, position: bars.count))
        bars.append(BarData(text: "Papaya", numbers: 30, position: bars.count))
        bars.append(BarData(text: "Pears", numbers: 10, position: bars.count))
        bars.append(BarData(text: "Pineapples", numbers: 70, position: bars.count))
        bars.append(BarData(text: "Plums", numbers: 20, position: bars.count))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.activityTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
                self?.doActivity()
            }
        }
    }
    
    func doActivity() {
        addRandomIncrements()
        newOrder()
        
        sendUpdates()
        
        reduce()
    }
    
    func sendUpdates() {
        bars.forEach {
            updateBar.send($0)
        }
    }
    
    func reduce() {
        bars.enumerated().forEach { index, bar in
            if bar.numbers > 100 {
                bars[index].numbers = Int.random(in: 10...30)
            }
        }
    }
    
    func newOrder() {
        let sortedBars = bars.sorted { $0.numbers > $1.numbers }
        sortedBars.enumerated().forEach { index, bar in
            if let barIndex = bars.firstIndex(where: { $0.text == bar.text }) {
                bars[barIndex].position = index
            }
        }
    }
    
    func addRandomIncrements() {
        for index in 0 ..< bars.count {
            bars[index].numbers += Int.random(in: 1...10)
        }
    }
}

struct BarData {
    let text: String
    var numbers: Int
    var position: Int
    let color: Color
    
    init(text: String, numbers: Int, position: Int) {
        self.text = text
        self.numbers = numbers
        self.position = position
        self.color = BarData.doColor(shade: CGFloat(numbers))
    }
    
    static func doColor(shade: CGFloat) -> Color {
        let hue2U:Double = Double((shade / 90 * 360))
        let color = Color.init(hue: hue2U/360, saturation: 0.66, brightness: 0.66, opacity: 1.0)
        return color
    }
}

struct SwiftUIViewB: View {
    let values = MarksFigures.shared
    let colors: [Color] = [.red,.orange,.yellow,.blue,.green,.pink,.purple]
    @State private var visibleBars = 1
    
    let nextBar = Timer.publish(every: 0.8, on: .main,
                                in: .common).autoconnect()
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            ForEach(0...visibleBars - 1, id: \.self) { value in
                BarRow(barData: values.bars[value])
            }
            .onReceive(nextBar) { _ in
                visibleBars += 1
                if visibleBars == values.bars.count {
                    nextBar.upstream.connect().cancel()
                }
            }
            .font(Fonts.avenirNextCondensedMedium(size: 20))
        }
        .padding()
        .frame(width: 236, height: 256, alignment: .leading)
        .border(Color.black)
    }
}

struct BarRow: View {
    let barWidth = 24
    let barData: BarData
    @State private var barHeight = CGFloat(0)
    @State private var growMore = CGFloat(0)
    @State private var showMore = 0.0
    @State private var fader = Double(1)
    @State private var offset = CGFloat(0)
    
    var body: some View {
        HStack {
            Text(barData.text)
                .frame(width: 80, alignment: .topTrailing)
                .onAppear {
                    offset = CGFloat(barData.position * barWidth)
                    barHeight = CGFloat(barData.numbers)
                }
            Rectangle()
                .fill(barData.color)
                .frame(width: growMore, height: 20)
            Rectangle()
                .frame(width: 110 - growMore, height: 1)
                .opacity(0)
            Text(String(Int(barHeight)))
                .font(Fonts.avenirNextCondensedMedium(size: 16))
                .frame(width: 24, alignment: .topTrailing)
                .background(Color.yellow)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.linear(duration: 0.5)) {
                            growMore = CGFloat(barData.numbers)
                            showMore = 1
                        }
                    }
                }.opacity(showMore)
                .onReceive(updateBar) { bar in
                    guard bar.text == barData.text else { return }
                    let animationTime = growMore > CGFloat(bar.numbers) ? 0.9 : 0.5
                    withAnimation(.linear(duration: animationTime)) {
                        barHeight = CGFloat(bar.numbers)
                        growMore = CGFloat(bar.numbers)
                        offset = CGFloat(bar.position * barWidth)
                    }
                }
        }.opacity(fader)
        .offset(y: offset - 84)
    }
}

struct MarksBarChartRace: View {
    var body: some View {
        SwiftUIViewB()
    }
}

struct MarksBarChartRace_Previews: PreviewProvider {
    static var previews: some View {
        MarksBarChartRace()
            .previewLayout(.sizeThatFits)
    }
}
