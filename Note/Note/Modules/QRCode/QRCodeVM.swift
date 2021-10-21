
//
//  ___HEADERFILE___
//
import Foundation
import RxCocoa
import RxSwift
import Vision

class QRCodeVM {
    private let disposeBag = DisposeBag()
    init() {
        
    }
    
    //MARK: Utilities
    func imageExtraction(_ observation: VNRectangleObservation, from buffer: CVImageBuffer) -> UIImage {
        let ciImage = CIImage(cvImageBuffer: buffer)
        
//        let topLeft = observation.topLeft.scaled(to: ciImage.extent.size)
//        let topRight = observation.topRight.scaled(to: ciImage.extent.size)
//        let bottomLeft = observation.bottomLeft.scaled(to: ciImage.extent.size)
//        let bottomRight = observation.bottomRight.scaled(to: ciImage.extent.size)
        
//        // pass filters to extract/rectify the image
//        ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
//            "inputTopLeft": CIVector(cgPoint: topLeft),
//            "inputTopRight": CIVector(cgPoint: topRight),
//            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//            "inputBottomRight": CIVector(cgPoint: bottomRight),
//        ])
        
        let context = CIContext()
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
        let output = UIImage(cgImage: cgImage!)
        
        //return image
        return output
    }
}
