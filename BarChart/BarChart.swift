//
//  BarChart.swift
//  BarChart
//
//  Created by Thane Heninger on 10/13/20.
//

import SwiftUI

//struct BarChart: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct BarChart_Previews: PreviewProvider {
//    static var previews: some View {
//        BarChart()
//    }
//}

struct Fonts {
    static func avenirNextCondensedBold (size: CGFloat) -> Font {
        return Font.custom("AvenirNextCondensed-Bold", size: size)
    }
    
    static func avenirNextCondensedMedium (size: CGFloat) -> Font {
        return Font.custom("AvenirNextCondensed-Medium", size: size)
    }
}

final class Figures: ObservableObject {
    @Published var numbers = [30,70,80,90,60,40,20]
    static var shared = Figures()
}

struct SwiftUIView: View {
    @ObservedObject var values = Figures.shared
    @State var colors:[Color] = [.red,.orange,.yellow,.blue,.green,.pink,.purple]
    @State var barHeight:CGFloat = 0
    @State var jump:Double = 0
    @State var gate:String
    @State var redraw = false
    var body: some View {
        
        HStack(alignment: .bottom, spacing: 5){
            ForEach((0...Int(jump)), id: \.self) { value in
                drawBar(barHeight: CGFloat(values.numbers[Int(value)]), jump: jump)
            }
            .onAppear {
                gate = "open"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if Int(jump) < values.numbers.count - 1 {
                        if gate == "open" {
                            jump += 1
                            gate = "close"
                        }
                    }
                }
            }
            .font(Fonts.avenirNextCondensedMedium(size: 20))
        }
        .padding()
        .id(redraw)
        .frame(width: 205, height: 160, alignment: .leading)
        .border(Color.black)
        .onTapGesture {
            values.numbers.removeAll()
            for _ in 0...6 {
                values.numbers.append(Int.random(in: 10...90))
            }
            jump = 0
            redraw.toggle()
        }
    }
}

struct drawBar:View {
    @State var barHeight: CGFloat
    @State var growMore: CGFloat = 0
    @State var showMore: Double = 0
    @State var jump:Double
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 1, height: 100 - barHeight, alignment: .leading)
                .opacity(0)
            Rectangle()
                .fill(doColor2(shade: jump))
                .frame(width: 20, height: growMore)
            Text(String(Int(barHeight)))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.linear(duration: 0.5)) {
                            growMore = barHeight
                            showMore = 1
                        }
                    }
                }.opacity(showMore)
        }
    }
    
    func doColor(shade: CGFloat) -> Color {
        let hue2U:Double = Double((shade / 90 * 360))
        let color = Color.init(hue: hue2U/255, saturation: 0.66, brightness: 0.66, opacity: 1.0)
        return color
    }
    
    func doColor2(shade: Double) -> Color {
        let hue2U:Double = Double( 360 / 14 ) * jump
        let color = Color.init(hue: hue2U/255, saturation: 0.66, brightness: 0.66, opacity: 1.0)
        return color
    }
}
