//
//  MagicCardCell.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 19.04.2024.
//

import UIKit

final class MagicCardCell: UITableViewCell {
    static let identifier = "MagicCardCell"

    // MARK: - Outlets

    private lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()

    private lazy var extraInfoStack: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [typeRarity, setName, spacer])
        stackView.setCustomSpacing(3, after: typeRarity)
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var typeRarity: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()

    private lazy var setName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()

    // MARK: - Init

    convenience init() {
        self.init(style: .default, reuseIdentifier: Self.identifier)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupLayout()
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupHierarchy() {
        [image, title, extraInfoStack].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        image.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).inset(10)
            make.bottom.equalTo(contentView).inset(10)
            make.width.equalTo(100)
        }

        title.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(10)
            make.top.equalTo(contentView).offset(15)
            make.trailing.equalTo(contentView).offset(-10)
        }

        extraInfoStack.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(10)
            make.top.equalTo(title.snp.bottom).offset(5)
            make.trailing.equalTo(contentView).offset(-10)
            make.bottom.equalTo(contentView).offset(-10)
        }
    }

    private func setupContentView() {
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 1)

        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemGray
        backgroundView.layer.cornerRadius = 20
        self.selectedBackgroundView = backgroundView
    }

    // MARK: - Configure

    func configure(with card: Card) {
        let placeholder = UIImage(systemName: "photo")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        if let imageUrl = card.imageUrl, let url = URL(string: imageUrl) {
            image.setImage(url: url, placeholder: placeholder)
        } else {
            image.image = placeholder
        }

        title.text = card.name

        typeRarity.text = "\(card.type), \(card.rarity)"
        setName.text = "from set: \(card.setName)"
    }
}
