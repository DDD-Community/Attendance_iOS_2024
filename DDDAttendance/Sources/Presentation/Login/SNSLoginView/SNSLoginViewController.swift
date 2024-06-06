//
//  SNSLoginViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import UIKit

final class SNSLoginViewController: UIViewController {
    // MARK: - UI properties
    private var mainView: SNSLoginView { view as! SNSLoginView }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func loadView() {
        view = SNSLoginView()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
}
