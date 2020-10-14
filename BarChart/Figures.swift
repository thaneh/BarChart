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
        for index in 0...6 {
            numbers[index] = Int.random(in: 10...90)
        }
    }
}
