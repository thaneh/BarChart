//
//  BarChart.swift
//  BarChart
//
//  Created by Thane Heninger on 10/13/20.
//

import SwiftUI

struct BarView: View {
    let width: CGFloat
    let height: CGFloat
    let graphHeight: CGFloat
    let barIndex: Int
    let animationTime: TimeInterval
    @State private var interimHeight = CGFloat(0)
    @State private var labelOpacity = 0.0
    let textHeight = CGFloat(20)
    
    var color: Color {
        let hue2U = 360.0 / 14.0 * Double(barIndex)
        let color = Color(hue: hue2U/255, saturation: 0.66,
                          brightness: 0.66, opacity: 1.0)
        return color
    }
    
    var finalHeight: CGFloat {
        (graphHeight - textHeight) * height / 100
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(width: width, height: interimHeight)
            Text(String(Int(height)))
                .padding(.top, -5)
                .frame(height: textHeight)
                .opacity(labelOpacity)
        }
        .offset(y: (graphHeight - textHeight - interimHeight) / 2)
        .onAppear {
            withAnimation(.linear(duration: animationTime)) {
                labelOpacity = 1
                interimHeight = finalHeight
            }
        }
        .onChange(of: graphHeight, perform: { _ in
            print("graphHeight \(graphHeight)")
            interimHeight = finalHeight
        })
    }
}

struct BarChart: View {
    @ObservedObject var values = Figures.shared
    @State var visibleBars = 0
    let timer = Timer.publish(every: 0.6, on: .main,
                              in: .common).autoconnect()
    let sideSpacing = CGFloat(10)
    let betweenSpacing = CGFloat(5)
    
    func barWidth(forSize size: CGFloat) -> CGFloat {
        let count = CGFloat(values.numbers.count)
        let barSpace = size - 2 * sideSpacing - (count - 1) * betweenSpacing
        return barSpace / count
    }
    
    func barPosition(forSize size: CGFloat, index: Int) -> CGFloat {
        let barWidth = self.barWidth(forSize: size)
        let barAndSpace = barWidth + betweenSpacing
        let position = sideSpacing + CGFloat(index) * barAndSpace + barWidth / 2
        return position
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .stroke(Color.black)
                
                ForEach(0 ..< visibleBars, id: \.self) { index in
                    BarView(width: barWidth(forSize: geo.size.width),
                            height: CGFloat(values.numbers[index]),
                            graphHeight: geo.size.height,
                            barIndex: index, animationTime: 0.6)
                        .position(x: barPosition(forSize: geo.size.width, index: index),
                                  y: geo.size.height / 2)
                }
                .font(Fonts.avenirNextCondensedMedium(size: 20))
                .onTapGesture {
                    values.randomize()
                    visibleBars = 0
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onReceive(timer) { _ in
            if visibleBars < 7 {
                visibleBars += 1
            }
        }
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart()
            .previewLayout(.fixed(width: 205, height: 160))
    }
}
