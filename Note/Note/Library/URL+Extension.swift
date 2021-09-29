//
//  URL+Extension.swift
//  Audio
//
//  Created by paxcreation on 4/12/21.
//

import Foundation
import UIKit
import MediaPlayer

extension URL {
    func getNameAudio() -> String {
//        let lastPath = self.lastPathComponent
//        let endIndex = lastPath.index(lastPath.endIndex, offsetBy: -4)
//        let name = String(lastPath.prefix(upTo: endIndex))
        return self.deletingPathExtension().lastPathComponent
    }
    
    func getThumbnailImage() -> UIImage? {
        let asset: AVAsset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
    
    func getDuration() -> Double {
        let asset = AVURLAsset(url: self)
        let durationInSeconds = asset.duration.seconds
        return durationInSeconds
    }
}
