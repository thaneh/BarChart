//
//  Figures.swift
//  BarChart
//
//  Created by Thane Heninger on 10/13/20.
//

import Foundation

final class Figures: ObservableObject {
    @Published var numbers = [30,70,80,90,60,40,20]
    static var shared = Figures()
    
    func randomize() {
        numbers = []
        let quantity = Int.random(in: 2...10)
        for _ in 0..<quantity {
            numbers.append(Int.random(in: 1...100))
        }
    }
}
