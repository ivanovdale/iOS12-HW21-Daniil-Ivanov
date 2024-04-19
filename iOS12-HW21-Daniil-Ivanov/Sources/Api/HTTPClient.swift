import Foundation
import Alamofire

typealias ObjectEndpointCompletion<Object: Decodable> = (Result<Object, Error>) -> ()

protocol HTTPClientProtocol {
    func getData<Object: Decodable>(urlRequest: String,
                                    encoding: String.Encoding,
                                    completion: @escaping ObjectEndpointCompletion<Object>)
}

final class HTTPClient: HTTPClientProtocol {
    func getData<Object: Decodable>(urlRequest: String,
                                    encoding: String.Encoding = .utf8,
                                    completion: @escaping ObjectEndpointCompletion<Object>) {

        let urlRequest = URL(string: urlRequest)
        guard let url = urlRequest else { return }

        print("GET Request: \(url)\n")

        let request = AF.request(url)
        request.responseDecodable { (response: AFDataResponse<Object>) in
            switch response.result {
            case let .success(result):
                completion(.success(result))
            case let .failure(error):

                // MARK: - Error handling

                if let statusCode = request.response?.statusCode {
                    switch statusCode {
                    case 404:
                        completion(.failure(HTTPClientError.wrongURL))
                        return
                    case 400...500:
                        completion(.failure(HTTPClientError.serverError(ServerError.serverFail)))
                        return
                    default:
                        break
                    }
                }

                if let urlError = error.underlyingError as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        completion(.failure(HTTPClientError.serverError(ServerError.networkProblem)))
                        return
                    case .cannotFindHost:
                        completion(.failure(HTTPClientError.wrongURL))
                        return
                    default:
                        completion(.failure(HTTPClientError.serverError(ServerError.serverFail)))
                        return
                    }
                }

                completion(.failure(HTTPClientError.serverError(ServerError.serverFail)))
            }
        }
    }
}
