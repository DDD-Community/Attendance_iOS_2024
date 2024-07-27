//
//  MemberAttendanceHistoryView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/27/24.
//

import FlexLayout
import PinLayout
import Then

import DesignSystem

import UIKit

final class MemberAttendanceHistoryView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private lazy var navigationBar: UICustomNavigationBar = .init().then {
        $0.addLeftButton(self.backButton)
    }
    
    var backButton: UIButton = .init().then {
        $0.setImage(.init(named: "icon_back"), for: .normal)
    }
    
    private let titleLabel: UILabel = .init().then {
        $0.text = "김디디의 출석 기록"
        $0.textColor = .basicWhite
        $0.font = .pretendardFontFamily(family: .SemiBold, size: 24)
    }
    
    private let attendanceStatusView: AttendanceStatusView = .init()
    
    lazy var collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: self.getCollectionViewLayout()
    ).then {
        $0.register(
            MemberAttendanceHistoryCell.self,
            forCellWithReuseIdentifier: MemberAttendanceHistoryCell.identifier
        )
        $0.backgroundColor = .clear
    }
    
    private var datasource: UICollectionViewDiffableDataSource<Int, Attendance>?
    
    // MARK: - Properties
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = .basicBlack
        addSubview(rootView)
        configureDatasource()
        
        rootView.flex.define { flex in
            flex.addItem(navigationBar)
            
            flex.addItem(titleLabel)
                .marginTop(8)
                .marginHorizontal(24)
                .marginBottom(24)
            
            flex.addItem(attendanceStatusView)
                .height(80)
                .marginHorizontal(24)
            
            flex.addItem(collectionView)
                .grow(1)
            
        }
    }
    
    // MARK: - Public helpers
    func bind(profile: Member) {
        titleLabel.text = "\(profile.name)님의 출석 기록"
        layout()
    }
    
    func bind(attendances: [Attendance]) {
        attendanceStatusView.bind(attendances: attendances)
        bindAttendanceCollectionView(attendances)
    }
    
    // MARK: - Private helpers
    private func bindAttendanceCollectionView(_ attendances: [Attendance]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Attendance>()
        snapshot.appendSections([0])
        snapshot.appendItems(attendances)
        datasource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureDatasource() {
        datasource = UICollectionViewDiffableDataSource<Int, Attendance>(
            collectionView: collectionView
        ) { collectionView, indexPath, attendance in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MemberAttendanceHistoryCell.identifier,
                for: indexPath
            ) as? MemberAttendanceHistoryCell else {
                return UICollectionViewCell()
            }
            cell.bind(attendance: attendance)
            return cell
        }
        collectionView.dataSource = datasource
    }
    
    private func getCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(56)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(56)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 24, bottom: 16, trailing: 24)
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func layout() {
        rootView.pin
            .top(pin.safeArea.top)
            .left(pin.safeArea.left)
            .right(pin.safeArea.right)
            .bottom()
        rootView.flex.layout()
    }
}
