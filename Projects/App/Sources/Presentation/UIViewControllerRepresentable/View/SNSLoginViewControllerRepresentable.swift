//
//  SNSLoginViewControllerRepresentable.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/21/24.
//

import Foundation
import SwiftUI

struct SNSLoginViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SNSLoginViewController {
        return SNSLoginViewController()
    }
    
    func updateUIViewController(_ uiViewController: SNSLoginViewController, context: Context) {
        // Update the view controller if needed
    }
}
