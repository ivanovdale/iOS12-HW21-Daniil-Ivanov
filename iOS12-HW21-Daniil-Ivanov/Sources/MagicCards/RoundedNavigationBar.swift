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

    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 40 / 2
        textField.backgroundColor = UIColor(red: 49 / 255, green: 49 / 255, blue: 49 / 255, alpha: 1)

        let color = UIColor(red: 188 / 255, green: 188 / 255, blue: 188 / 255, alpha: 1)
        textField.textColor = color

        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        let placeHolderAttributes = [NSAttributedString.Key.foregroundColor: color,
                                     .paragraphStyle: centeredParagraphStyle]
        textField.attributedPlaceholder = NSAttributedString(string: "Find a magic card",
                                                             attributes: placeHolderAttributes)

        let leftAlignedParagraphStyle = NSMutableParagraphStyle()
        leftAlignedParagraphStyle.alignment = .left
        let textAttributes = [NSAttributedString.Key.paragraphStyle: leftAlignedParagraphStyle]

        textField.setLeftPaddingPoints(10)

        textField.addTarget(self, 
                            action: #selector(textFieldDidChange(_:)),
                            for: .editingChanged)

        textField.delegate = self

        return textField
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
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
        [titleLabel, searchTextField, cancelButton].forEach { addSubview($0) }
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(26)
        }

        searchTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(25)
//            make.trailing.equalToSuperview().offset(-25)
            make.height.equalTo(40)
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(searchTextField.snp.trailing).offset(10)
            make.centerY.equalTo(searchTextField.snp.centerY)
            make.trailing.equalToSuperview().offset(-20)
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
    private func textFieldDidChange(_ textField: UITextField) {
        self.searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { [weak self] timer in
            self?.onSearchTextFieldChanged?(textField.text)
        })
    }

    @objc
    private func cancelButtonTapped() {
        searchTextField.text = nil
        onSearchTextFieldChanged?(nil)
        cancelButton.isHidden = true
    }
}

// MARK: - Extension

// MARK: UITextFieldDelegate

extension RoundedNavigationBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelButton.isHidden = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextField.text = nil
        onSearchTextFieldChanged?(nil)
        cancelButton.isHidden = true
    }
}
