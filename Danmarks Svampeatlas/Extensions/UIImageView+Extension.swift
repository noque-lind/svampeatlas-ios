//
//  UIImageView+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DownloadableImageView: UIImageView {
    private var url: String?
    
    func downloadImage(size: DataService.ImageSize, urlString: String?, fade: Bool = false) {
        url = urlString
        
        guard let urlString = urlString else {return}
        DataService.instance.getImage(forUrl: urlString, size: size) { (image, url) in
            DispatchQueue.main.async { [weak self] in
                //                debugPrint("Downloaded an image where self.urlString == downloaded URl is:  \(urlString == url)")
                //                debugPrint(urlString)
                //                debugPrint(url)
                
                if self?.url == url {
                    if fade {
                         self?.fadeToNewImage(image: image)
                    } else {
                        self?.image = image
                    }
                   
                }
                if true {
                    if url == "https://graph.facebook.com/10206479571848603/picture?width=70&height=70" {
                        debugPrint("THOMAS LÆSSØE")
                    }
                }
            }
        }
    }
}

extension UIImageView {
    func fadeToNewImage(image: UIImage) {
        let crossFade: CABasicAnimation = CABasicAnimation(keyPath: "contents")
        crossFade.duration = 0.2
        crossFade.fromValue = self.image
        crossFade.toValue = image
        self.image = image
        self.layer.add(crossFade, forKey: "animateContents")
    }
    
    func loadImage(url: URL) {
        DispatchQueue.main.async {
            self.image = UIImage(url: url)
        }
    }
    

//    func downloadImage(size: DataService.ImageSize, urlString: String?) {
//        guard let urlString = urlString else {return}
//        DataService.instance.getImage(forUrl: urlString, size: size) { (image, url) in
//            DispatchQueue.main.async { [weak self] in
////                debugPrint("Downloaded an image where self.urlString == downloaded URl is:  \(urlString == url)")
////                debugPrint(urlString)
////                debugPrint(url)
//                if true {
//                    if url == "https://graph.facebook.com/10206479571848603/picture?width=70&height=70" {
//                        debugPrint("THOMAS LÆSSØE")
//                    }
//
//
//                    self?.fadeToNewImage(image: image)
//                }
//            }
//        }
//    }
}
