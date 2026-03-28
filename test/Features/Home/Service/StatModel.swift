//
//  StatModel.swift
//  test
//
//  Created by Umar Momin on 25/03/26.
//


// test/Features/Home/Service/StatModel.swift
import SwiftUI

struct StatModel: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
}