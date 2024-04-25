import Foundation

protocol MagicCardsServiceProtocol {
    init(client: HTTPClientProtocol)

    func getCards(completion: @escaping ObjectEndpointCompletion<Cards>)

    func getCardsByName(name: String,
                        completion: @escaping ObjectEndpointCompletion<Cards>)
}

final class MagicCardsService: MagicCardsServiceProtocol {
    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    private enum Endpoint {
        case cards(name: String? = nil)

        var urlRequest: String {
            var components = URLComponents()
            components.scheme = Constants.scheme
            components.host = Constants.host

            switch self {
            case .cards(let name):
                components.path = Constants.cardsResource
                if name != nil {
                    components.queryItems = buildQueryItems(name: name!)
                }
                return components.url?.absoluteString ?? ""
            }
        }

        private func buildQueryItems(name: String) -> [URLQueryItem] {
            [URLQueryItem(name: "name", value: name)]
        }
    }

    func getCards(completion: @escaping ObjectEndpointCompletion<Cards>) {
        let urlRequest = Endpoint.cards().urlRequest
        client.getData(urlRequest: urlRequest, encoding: .utf8, completion: completion)
    }

    func getCardsByName(name: String,
                        completion: @escaping ObjectEndpointCompletion<Cards>) {
        let urlRequest = Endpoint.cards(name: name).urlRequest
        client.getData(urlRequest: urlRequest, encoding: .utf8, completion: completion)
    }
}

// MARK: - Constants

fileprivate enum Constants {
    static let scheme = "https"
    static let host = "api.magicthegathering.io"
    static let cardsResource = "/v1/cards"
}
