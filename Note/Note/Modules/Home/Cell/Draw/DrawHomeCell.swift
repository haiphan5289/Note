//
//  DrawHomeCell.swift
//  Note
//
//  Created by haiphan on 16/10/2021.
//

import UIKit
import PencilKit

class DrawHomeCell: UICollectionViewCell {

    @IBOutlet weak var canvasView: PKCanvasView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateValueNote(noteModel: NoteDrawModel) {
        guard let d = noteModel.data else {
            return
        }
        do {
            let data = try PKDrawing.init(data: d)
            self.canvasView.drawing = data
            self.canvasView.isHidden = false
            
        } catch {
            print(error.localizedDescription)
        }
    }

}
