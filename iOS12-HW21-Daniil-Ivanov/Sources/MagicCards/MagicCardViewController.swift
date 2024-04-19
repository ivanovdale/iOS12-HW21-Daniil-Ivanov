//
//  ViewController.swift
//  iOS12-HW21-Daniil-Ivanov
//
//  Created by Daniil (work) on 17.04.2024.
//

import UIKit

final class MagicCardsViewController: UIViewController {
    let magicCardsService: MagicCardsServiceProtocol

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

    private lazy var navigationBar = RoundedNavigationBar()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MagicCardCell.self,
                           forCellReuseIdentifier: MagicCardCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
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

        fetchCards()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        [navigationBar, tableView].forEach { view.addSubview($0) }
    }

    private func setupLayout() {
        navigationBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(130)
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
    }

    // MARK: - Data fetching

    private func fetchCards() {
        magicCardsService.getCards { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.cards = result.cards
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error)
                }
            }
        }
    }
}

// MARK: - Extensions

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
        cell.configure(with: card)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10
    }
}

// MARK: UITableViewDelegate

extension MagicCardsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}