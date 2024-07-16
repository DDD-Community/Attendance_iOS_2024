//
//  MemberAttendanceHistoryView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/27/24.
//

import FlexLayout
import PinLayout
import Then

import UIKit

final class MemberAttendanceHistoryView: BaseView {
    // MARK: - UI properties
    lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: self.getCollectionViewLayout()
    ).then {
        $0.register(
            MemberAttendanceHistoryCell.self,
            forCellWithReuseIdentifier: MemberAttendanceHistoryCell.identifier
        )
    }
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
    private func getCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
