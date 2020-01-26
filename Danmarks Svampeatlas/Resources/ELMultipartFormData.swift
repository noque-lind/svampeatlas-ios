//
//  ELMultipartFormData.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 07/02/2019.
//  Copyright © 2019 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

struct ELMultipartFormData {
    
    private init() {}
    
    struct Media {
        let key: String
        let filename: String
        let data: Data
        let mimeType: String
        
        init?(withImage imageURL: URL, forKey key: String) {
            self.key = key
            self.mimeType = "image/jpeg"
            self.filename = "photo-\(Date().convert(into: DateFormatter.Style.full)).jpg"
            guard let image = UIImage.init(url: imageURL) else {return nil}
            guard let data = image.rotate().jpegData(sizeInMB: 0.6) else {return nil}
            self.data = data
        }
    }
    
    static func createDataBody(withParameters params: [String: String]?, media: Media?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)".data(using: String.Encoding.utf8)!)
                body.append("\(value + lineBreak)".data(using: String.Encoding.utf8)!)
            }
        }
        
        if let media = media {
            body.append("--\(boundary + lineBreak)".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename=\"\(media.filename)\"\(lineBreak)".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)".data(using: .utf8)!)
            body.append(media.data)
            body.append(lineBreak.data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        
        
        return body
    }
    
    static func createDataBody(withParameters params: [String: String]?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)".data(using: String.Encoding.utf8)!)
                body.append("\(value + lineBreak)".data(using: String.Encoding.utf8)!)
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)".data(using: .utf8)!)
                body.append(photo.data)
                body.append(lineBreak.data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        
        return body
    }
    
    
}
