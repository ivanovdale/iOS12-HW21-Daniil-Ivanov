//
//  MagicCardCell.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 19.04.2024.
//

import UIKit
import SkeletonView

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
        setupSkeletonableViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        setupInsets()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        [image, title, typeRarity, setName].forEach { contentView.addSubview($0) }
    }

    private func setupLayout() {
        image.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(10)
            make.top.equalTo(contentView).inset(15)
            make.bottom.equalTo(contentView).inset(15)
            make.width.equalTo(100)
        }

        title.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(10)
            make.top.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-15)
        }

        typeRarity.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(10)
            make.top.equalTo(title.snp.bottom).offset(5)
            make.trailing.equalTo(contentView).offset(-15)
        }

        setName.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(10)
            make.top.equalTo(typeRarity.snp.bottom).offset(3)
            make.trailing.equalTo(contentView).offset(-15)
        }
    }

    private func setupContentView() {
        self.backgroundColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 1)

        let backgroundView = UIView()
        backgroundView.backgroundColor = .systemGray
        backgroundView.layer.cornerRadius = 20
        self.selectedBackgroundView = backgroundView
    }

    private func setupInsets() {
        let verticalPadding: CGFloat = 10

        let maskLayer = CALayer()
        maskLayer.cornerRadius = 20
        maskLayer.backgroundColor = UIColor(red: 22 / 255, green: 22 / 255, blue: 22 / 255, alpha: 1).cgColor
        maskLayer.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: bounds.height).insetBy(dx: 0, dy: verticalPadding / 2)
        layer.mask = maskLayer
    }

    private func setupSkeletonableViews() {
        self.isSkeletonable = true
        contentView.isSkeletonable = true

        image.isSkeletonable = true
        title.isSkeletonable = true

        title.skeletonTextNumberOfLines = 3
        title.linesCornerRadius = 5
        image.skeletonCornerRadius = 20
    }

    // MARK: - Configure

    func configure(with card: Card) {
        let placeholder = UIImage(systemName: "photo")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        if let imageUrl = card.imageUrl,
           let url = URL(string: imageUrl) {
            image.setImage(url: url, placeholder: placeholder)
        } else {
            image.image = placeholder
        }

        title.text = card.name

        if !card.type.isEmpty && !card.rarity.isEmpty {
            typeRarity.text = "\(card.type), \(card.rarity)"
        }

        if !card.setName.isEmpty {
            setName.text = "from set: \(card.setName)"
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        typeRarity.text = nil
        setName.text = nil
    }
}
