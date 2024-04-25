import Foundation

enum ServerError: Error {
    // problem with sending request like no internet and others
    case networkProblem
    // our server is fallen down, most of the time it's happening case 500th error
    case serverFail
    // no way to parse receipt from apple directory
    case noReceipt
    // server cannot execute your request cause bad parameters
    // first value code status
    // second value error message
    case invalidRequest((Int, String))
}
