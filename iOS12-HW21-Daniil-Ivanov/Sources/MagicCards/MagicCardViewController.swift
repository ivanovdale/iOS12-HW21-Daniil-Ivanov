//
//  ViewController.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 17.04.2024.
//

import UIKit
import SkeletonView

final class MagicCardsViewController: UIViewController {

    // MARK: - Controller state

    private enum State {
        case initial, success, loading, failure
    }

    private var state: State = .initial {
        didSet {
            switch (state) {
            case .loading:
                DispatchQueue.main.async { [weak self] in
                    self?.startShimmerAnimation()
                }
                tableView.reloadData()
            case .success, .failure:
                stopShimmerAnimation()
                tableView.reloadData()
            case .initial:
                break
            }
        }
    }

    // MARK: - Data service

    private let magicCardsService: MagicCardsServiceProtocol

    // MARK: - Data

    private var cards: [Card] = [] {
        didSet {
            if cards.count > 0 {
                state = .success
            }
        }
    }

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
        tableView.isSkeletonable = true
        return tableView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupView()

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

    private func fetchCards(by name: String? = nil) {
        state = .loading

        let completion: ObjectEndpointCompletion<Cards> = { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let self else { return }
                    self.cards = result.cards
                }
            case .failure(_):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.state = .failure

                    let alert = configureErrorAlert()
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

    // MARK: - Error alert configuration

    private func configureErrorAlert() -> UIAlertController {
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

        return alert
    }

    // MARK: - Shimmer animation

    private func startShimmerAnimation() {
        let animation = SkeletonAnimationBuilder()
            .makeSlidingAnimation(withDirection: .leftRight)
        let color = UIColor(red: 0.882, green: 0.89, blue: 0.914, alpha: 1)
        let gradient = SkeletonGradient(baseColor: color, secondaryColor: .white)

        tableView.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
    }

    private func stopShimmerAnimation() {
        tableView.hideSkeleton()
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

    // MARK: Header

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear

        return headerView
    }

    // Spacing between sections.
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10
    }

    // MARK: Sections

    func numberOfSections(in tableView: UITableView) -> Int {
        switch (state) {
        case .loading: return 5
        case .success: return cards.count
        case .initial, .failure: return 0
        }
    }

    // MARK: Rows

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MagicCardCell.identifier,
                                                 for: indexPath) as? MagicCardCell
        guard let cell, state != .loading else { return MagicCardCell() }

        let card = cards[indexPath.section]
        cell.configure(with: card)

        return cell
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
