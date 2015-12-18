//
//  utilities.swift
//  swift_app
//
//  Created by cbcrouch on 11/8/14.
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

import Foundation

func greet(name: String, day: String) -> String {
    return "Hello \(name), today is \(day)"
}

func calculateStstistics(scores: [Int]) -> (min: Int, max: Int, sum: Int) {
    var min = scores[0]
    var max = scores[0]
    var sum = 0

    for score in scores {
        if score > max {
            max = score
        } else if score < min {
            min = score
        }
        sum += score
    }

    return (min, max, sum)
}

func sumOf(numbers: Int...) -> Int {
    var sum = 0

    for number in numbers {
        sum += number
    }

    return sum
}

func returnFifteen() -> Int {
    var y = 10
    func add() {
        y += 5
    }
    add()
    return y
}

func makeIncrementer() -> (Int -> Int) {
    func addOne(number: Int) -> Int {
        return 1 + number
    }
    return addOne
}

func hasAnyMatches(list: [Int], condition: Int -> Bool) -> Bool {
    for item in list {
        if condition(item) {
            return true
        }
    }
    return false
}

func lessThanTen(number: Int) -> Bool {
    return number < 10
}
