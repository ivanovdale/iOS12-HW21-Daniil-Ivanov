//
//  MagicCardDetailsViewController.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 22.04.2024.
//

import UIKit
import SnapKit

class MagicCardDetailsViewController: UIViewController {

    // MARK: - Outlets

    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var manaImage: UIImageView = {
        let image = UIImage(systemName: "wind.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.cyan)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private lazy var manaCost: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    private lazy var typeRarity: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    private lazy var setName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()

    private lazy var originalText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupView()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        [
            image,
            titleLabel,
            manaImage,
            manaCost,
            typeRarity,
            setName,
            originalText,
        ].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        image.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.top.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.5)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(25)
            make.top.equalTo(image.snp.bottom).offset(10)
        }

        manaImage.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(25)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }

        manaCost.snp.makeConstraints { make in
            make.leading.equalTo(manaImage.snp.trailing).offset(5)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }

        typeRarity.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(25)
            make.top.equalTo(manaImage.snp.bottom).offset(5)
        }

        setName.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(25)
            make.top.equalTo(typeRarity.snp.bottom).offset(5)
        }

        originalText.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(25)
            make.top.equalTo(setName.snp.bottom).offset(5)
            make.trailing.equalTo(view).offset(-25)
        }
    }

    private func setupView() {
        view.backgroundColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 1)
    }

    // MARK: - Configuration

    func configure(with card: Card) {
        let placeholder = UIImage(systemName: "photo")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        if let imageUrl = card.imageUrl, let url = URL(string: imageUrl) {
            image.setImage(url: url, placeholder: placeholder)
        } else {
            image.image = placeholder
        }

        titleLabel.text = card.name

        if let mana = card.manaCost {
            manaCost.text = "Mana cost: \(mana)"
        }

        typeRarity.text = "\(card.type), \(card.rarity)"
        setName.text = "From set: \(card.setName)"

        if let text = card.originalText {
            originalText.text = "Description:\n\n\(text)"
        }
    }
}
