//
//  ExportFile.swift
//  Audio
//
//  Created by paxcreation on 3/29/21.
//

import UIKit
import RxSwift
import RxCocoa
import Photos
import AVKit
import MediaPlayer

enum ExportFileAV: Int, CaseIterable {
    case mp3, m4a, wav, m4r, caf, aiff, aifc, aac, flac, mp4
    
    var typeExport: AVFileType {
        switch self {
        case .m4a:
            return .m4a
        case .caf:
            return .caf
        default:
            return .mp4
        }
    }
    
    var nameExport: String {
        switch self {
        case .m4a:
            return ".m4a"
        case .m4r:
            return ".m4r"
        case .wav:
            return ".wav"
        case .caf:
            return ".caf"
        case .aiff:
            return ".aiff"
        case .aifc:
            return ".aifc"
        case .flac:
            return ".flac"
        default:
            return ".mp4"
        }
    }
    
    var presentName: String {
        switch self {
        case .m4a:
            return AVAssetExportPresetAppleM4A
        case .caf:
            return AVAssetExportPresetPassthrough
        default:
            return AVAssetExportPresetHighestQuality
            
        }
    }
    
    //Export 9
    var defaultExport: String {
        return ".m4a"
    }
    
    var nameUrl: String {
        return "\(self)"
    }
}

enum TypeExportFile: Int, CaseIterable {
    case ExporttoMp3
    case ExporttoM4A
    case ExorttoM4R
    
    var text: String {
        return "\(self)"
    }
    
}

class ExportFile: UIViewController {

    @IBOutlet var tapOutSide: UITapGestureRecognizer!
    @IBOutlet var bts: [UIButton]!
    
    var url: [URL] = []
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapOutSide.rx.event.bind { _ in
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        TypeExportFile.allCases.forEach { (type) in
            let bt = self.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard  let wSelf = self else {
                    return
                }
                
//                let export = AudioExportFile()
//                export.delegate = self
//                switch type {
//                case .ExporttoM4A:
//                    wSelf.covertToAudio(listUrl: wSelf.url, type: .m4a)
//                case .ExorttoM4R:
//                    wSelf.covertToAudio(listUrl: wSelf.url, type: .m4r)
//                case .ExporttoMp3:
//                    wSelf.covertToAudio(listUrl: wSelf.url, type: .mp3)
//                }
                
//                let message = "Dayshee...."
//                let url = "https://dayshee.com/san-pham/.html"
//                if let link = NSURL(string: url)
//                {
//                    let objectsToShare: [Any] = [message,link]
//                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//                    activityVC.excludedActivityTypes = [.airDrop, .addToReadingList, .assignToContact,
//                                                        .mail, .message, .postToFacebook, .postToWhatsApp]
//                    wSelf.present(activityVC, animated: true, completion: nil)
//                }
            }.disposed(by: disposeBag)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showExportFile()
        }
        
    }
    
    private func showExportFile() {
        self.showAlert(type: .actionSheet,
                       title: nil, message: nil, buttonTitles: [TypeExportFile.ExporttoMp3.text,
                                                                TypeExportFile.ExorttoM4R.text,
                                                                TypeExportFile.ExorttoM4R.text],
                       highlightedButtonIndex: nil) { (idx) in
            guard let type = TypeExportFile.init(rawValue: idx) else { return }
            switch type {
            case .ExporttoM4A:
                self.covertToAudio(listUrl: self.url, type: .m4a)
            case .ExorttoM4R:
                self.covertToAudio(listUrl: self.url, type: .m4r)
            case .ExporttoMp3:
                self.covertToAudio(listUrl: self.url, type: .mp3)
            }
        }
    }

    
    func covertToAudio(listUrl: [URL], type: ExportFileAV)  {
        let composition = AVMutableComposition()
        do {
            let asset = AVURLAsset(url: url[0])
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { fatalError("Không co URL") }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { fatalError("Không co URL") }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
        }
        
        // Get url for output
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
//        let year =  components.year
//        let month = components.month
//        let day = components.day
//        let second = components.second
//        let randomInt = Int.random(in: 0..<1000000)
        let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\(LINK_FOLDER_AUDIOEFFECT)/Export\(type.nameExport)\(type.defaultExport)")
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(atPath: outputURL.path)
        }
        
        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: type.presentName)!
        exportSession.outputFileType = type.typeExport
        exportSession.outputURL = outputURL
        
        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }
            guard let outPut = exportSession.outputURL else { return }
            DispatchQueue.main.async {
                self.presentActivty(url: outPut)
            }
        }
    }
}
