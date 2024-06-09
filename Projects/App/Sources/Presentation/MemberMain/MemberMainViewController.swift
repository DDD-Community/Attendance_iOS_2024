//
//  MemberMainViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import ReactorKit

import UIKit

final class MemberMainViewController: UIViewController {
    // MARK: - UI properties
    private var mainView: MemberMainView { view as! MemberMainView }
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func loadView() {
        view = MemberMainView()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
}
