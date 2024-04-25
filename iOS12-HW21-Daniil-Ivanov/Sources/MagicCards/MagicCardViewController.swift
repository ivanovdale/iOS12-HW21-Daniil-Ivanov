//
//  ViewController.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 17.04.2024.
//

import UIKit
import SkeletonView

final class MagicCardsViewController: UIViewController {
    let magicCardsService: MagicCardsServiceProtocol

    // MARK: - Loading state

    var isLoading: Bool = true

    // MARK: - Data

    private var cards: [Card] = []

    // MARK: - Init

    init(magicCardsService: MagicCardsServiceProtocol) {
        self.magicCardsService = magicCardsService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Outlets

    private lazy var navigationBar: RoundedNavigationBar = {
        let navigationBar = RoundedNavigationBar()
        navigationBar.onSearchTextFieldChanged = onSearchTextFieldChanged(text:)
        return navigationBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MagicCardCell.self,
                           forCellReuseIdentifier: MagicCardCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 170
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupView()

        generateFakeCards()
        fetchCards()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        [navigationBar, tableView].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        navigationBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.17)
        }

        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(navigationBar.snp.bottom)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
        }
    }

    private func setupView() {
        view.backgroundColor = UIColor(red: 49 / 255, green: 49 / 255, blue: 49 / 255, alpha: 1)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }

    @objc
    func viewTapped(sender: UITapGestureRecognizer){
        view.endEditing(true)
    }

    // MARK: - Data fetching

    // Need for shimmer animation.
    private func generateFakeCards() {
        let fakeCard = Card(name: UUID().uuidString,
                            manaCost: "",
                            type: UUID().uuidString,
                            rarity: UUID().uuidString,
                            setName: UUID().uuidString,
                            originalText: "",
                            imageUrl: "")
        cards = Array(repeating: fakeCard, count: 20)
    }

    private func fetchCards(by name: String? = nil) {
        isLoading = true
        let completion: ObjectEndpointCompletion<Cards> = { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                    self.cards = result.cards
                    self.tableView.reloadData()
                }
            case .failure(_):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                    let alert = UIAlertController(title: "Alert",
                                                  message: "Error occured while loading cards",
                                                  preferredStyle: .alert)
                    let alertActionHandler = { (action: UIAlertAction) in
                        switch action.style {
                            case .default:
                            self.fetchCards()
                        case .cancel, .destructive:
                            fatalError()
                        @unknown default:
                            fatalError()
                        }
                    }
                    let alertAction = UIAlertAction(title: "Reload",
                                                    style: .default,
                                                    handler: alertActionHandler)
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

        if let name, !name.isEmpty {
            magicCardsService.getCardsByName(name: name, completion: completion)
        } else {
            magicCardsService.getCards(completion: completion)
        }
    }
}

// MARK: - Extensions

// MARK: SearchTextField change handler

extension MagicCardsViewController {
    func onSearchTextFieldChanged(text: String?) {
        fetchCards(by: text)
    }
}

// MARK: UITableViewDataSource

extension MagicCardsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagicCardCell.identifier, 
                                                 for: indexPath) as? MagicCardCell
        guard let cell else { return MagicCardCell() }
        let card = cards[indexPath.section]

        if isLoading {
            let animation = SkeletonAnimationBuilder()
                .makeSlidingAnimation(withDirection: .leftRight)
            let color = UIColor(red: 0.882, green: 0.89, blue: 0.914, alpha: 1)
            let gradient = SkeletonGradient(baseColor: color, secondaryColor: .white)
            cell.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        } else {
            cell.hideSkeleton()
        }

        cell.configure(with: card)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10
    }
}

extension MagicCardsViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        MagicCardCell.identifier
    }
}

// MARK: UITableViewDelegate

extension MagicCardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let magicCardDetailsViewController = MagicCardDetailsViewController()
        let card = cards[indexPath.section]
        magicCardDetailsViewController.configure(with: card)
        present(magicCardDetailsViewController, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
