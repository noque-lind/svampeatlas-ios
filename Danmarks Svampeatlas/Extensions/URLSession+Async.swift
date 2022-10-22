//
//  URLSession+Async.swift
//  Danmarks Svampeatlas
//
//  Created by Emil Møller Lind on 10/10/2022.
//  Copyright © 2022 NaturhistoriskMuseum. All rights reserved.
//

import UIKit
extension URLSession {
    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func data(from request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                
                continuation.resume(returning: (data, response))
            }
            
            task.resume()
        }
    }
}
