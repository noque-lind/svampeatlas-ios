//
//  UIImageView+Extension.swift
//  SvampeAtlas
//
//  Created by Emil Lind on 02/10/2018.
//  Copyright © 2018 NaturhistoriskMuseum. All rights reserved.
//

import UIKit

class DownloadableImageView: UIImageView {
    
    private let spinner = UIActivityIndicatorView().then({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
    })
    
    
   var url: String?
    
    func loadImage(url: URL) {
        self.url = url.absoluteString
        
        if url.isFileURL {
            DispatchQueue.main.async {
                guard self.url == url.absoluteString else {return}
                self.image = UIImage(url: url)
            }
        } else {
            addSpinnerIfNecessary(spinnerNeeded: true)
            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard self?.url == url.absoluteString, let data = data, let image = UIImage.init(data: data) else {return}
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.image = image
                }
            }.resume()
        }
    }
    
    func downloadImage(size: DataService.ImageSize, urlString: String?, fade: Bool = false) {
        url = urlString
        
        guard let urlString = urlString else {return}
        DataService.instance.getImage(forUrl: urlString, size: size) { [weak self] (image, url) in
            DispatchQueue.main.async {
                if self?.url == url {
                    if fade {
                         self?.fadeToNewImage(image: image)
                    } else {
                        self?.image = image
                    }
                   
                }
            }
        }
    }
    
    private func addSpinnerIfNecessary(spinnerNeeded: Bool) {
        if spinnerNeeded {
            spinner.startAnimating()
            if spinner.superview == nil {
                addSubview(spinner)
                spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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
