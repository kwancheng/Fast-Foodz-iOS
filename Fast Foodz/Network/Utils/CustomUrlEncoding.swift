//
//  CustomUrlEncoding.swift
//  Fast Foodz
//
//  Created by Kwan Cheng on 4/23/20.
//

import Alamofire

struct CustomUrlEncoding : ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters else { return urlRequest }

            guard let url = urlRequest.url else {
                throw AFError.parameterEncodingFailed(reason: .missingURL)
            }

            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters: parameters)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                urlRequest.url = urlComponents.url
            }

        return urlRequest
    }

    private func query(parameters: Parameters) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let array = value as? [Any] {
            components.append((key, encode(array: array, separatedBy: ",")))
        } else {
            components.append((key, "\(value)"))
        }

        return components
    }

    private func encode(array: [Any], separatedBy separator: String) -> String {
        return array.map({"\($0)"}).joined(separator: separator)
    }
}
