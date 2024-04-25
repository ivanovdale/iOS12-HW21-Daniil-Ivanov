//
//  RoundedNavigationBar.swift
//  practive_table_ivanov_d
//
//  Created by Daniil (work) on 19.04.2024.
//

import UIKit
import SnapKit

typealias OptionalStringClosure = (String?) -> Void

final class RoundedNavigationBar: UIView {

    // Для реализации отложенного поиска.
    private var searchTimer: Timer?

    var onSearchTextFieldChanged: OptionalStringClosure?

    // MARK: - Outlets

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Magic Cards"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self

        let backgroundColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 1)
        let textColor = UIColor(red: 188 / 255, green: 188 / 255, blue: 188 / 255, alpha: 1)
        let textFieldBackgroundColor = UIColor(red: 49 / 255, green: 49 / 255, blue: 49 / 255, alpha: 1)

        // MARK: TextField styling

        let textField = searchBar.searchTextField
        let placeHolderAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        textField.attributedPlaceholder = NSAttributedString(string: "Find a magic card",
                                                             attributes: placeHolderAttributes)

        textField.textColor = textColor
        textField.backgroundColor = textFieldBackgroundColor

        textField.leftView?.tintColor = .white
        if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
            let image = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(image, for: .normal)
            clearButton.tintColor = UIColor.white
        }

        // MARK: SearchBar styling

        searchBar.backgroundColor = backgroundColor
        searchBar.barTintColor = backgroundColor
        searchBar.tintColor = .white

        // Красим _UISearchBarSearchContainerView, иначе появляются странные чёрные полосы.
        searchBar.subviews.first?.subviews.last?.backgroundColor = backgroundColor

        // MARK: Add handler for editing changed

        textField.addTarget(self,
                            action: #selector(searchBarTextFieldDidChange(_:)),
                            for: .editingChanged)

        return searchBar
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupHierarchy()
        setupLayout()
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupHierarchy() {
        [titleLabel, searchBar].forEach { addSubview($0) }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).offset(5)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }

    private func setupView() {
        backgroundColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 1)

        layer.cornerRadius = 25
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    // MARK: - Actions

    @objc 
    private func searchBarTextFieldDidChange(_ textField: UITextField) {
        self.searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { [weak self] timer in
            self?.onSearchTextFieldChanged?(textField.text)
        })
    }
}

// MARK: - Extension

// MARK: UISearchBarDelegate

extension RoundedNavigationBar: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        onSearchTextFieldChanged?(searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = nil
        searchBar.searchTextField.endEditing(true)
        onSearchTextFieldChanged?(nil)
        searchBar.showsCancelButton = false
    }
}
