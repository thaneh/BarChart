//
//  BarChart.swift
//  BarChart
//
//  Created by Thane Heninger on 10/13/20.
//

import SwiftUI

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart()
    }
}

struct BarChart: View {
    @ObservedObject var values = Figures.shared
    @State var redraw = false
    @State var visibleBars = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            ForEach(0 ..< visibleBars, id: \.self) { index in
                BarView(width: 20, height: CGFloat(values.numbers[index]),
                        barIndex: index, animationTime: 1)
            }
        }
        .id(redraw)
        .font(Fonts.avenirNextCondensedMedium(size: 20))
        .padding()
        .frame(width: 205, height: 160, alignment: .leading)
        .border(Color.black)
        .onTapGesture {
            values.randomize()
            visibleBars = 0
            redraw.toggle()
        }
        .onReceive(timer) { _ in
            if visibleBars < 7 {
                visibleBars += 1
            }
        }
    }
}

struct BarView: View {
    let width: CGFloat
    let height: CGFloat
    let barIndex: Int
    let animationTime: TimeInterval
    @State private var interimHeight = CGFloat(0)
    @State private var labelOpacity = 0.0
    
    var color: Color {
        let hue2U = 360.0 / 14.0 * Double(barIndex)
        let color = Color(hue: hue2U/255, saturation: 0.66,
                          brightness: 0.66, opacity: 1.0)
        return color
    }
    
    var body: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(color)
                .frame(width: width, height: interimHeight)
            Text(String(Int(height)))
                .opacity(labelOpacity)
        }
        .onAppear {
            withAnimation(.linear(duration: animationTime)) {
                labelOpacity = 1
                interimHeight = height
            }
        }
    }
}
