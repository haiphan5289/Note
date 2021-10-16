
//
//  
//  DrawVC.swift
//  Note
//
//  Created by haiphan on 16/10/2021.
//
//
import UIKit
import RxCocoa
import RxSwift
import PencilKit

class DrawVC: BaseNavigationOnlyHeader {
    
    struct Constant {
        static let canvasWidth: CGFloat = 768
        static let canvasOverScrollHeight: CGFloat = 500
    }
    
    enum ActionUndo: Int, CaseIterable {
        case undo, redo
    }
    
    var noteModel: NoteModel?
    
    // Add here outlets
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet var bts: [UIButton]!
    
    // Add here your view model
    private var viewModel: DrawVM = DrawVM()
    
    private let toolPicker = PKToolPicker.init()
    
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupRX()
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
}
extension DrawVC {
    
    private func setupUI() {
        // Add here the setup for the UI
        canvasView.delegate = self
        canvasView.alwaysBounceVertical = false
        canvasView.drawingPolicy = .default
        canvasView.becomeFirstResponder()
          
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.addObserver(self)
        canvasView.becomeFirstResponder()
        
        canvasView.layer.cornerRadius = ConstantApp.shared.radiusViewDialog
        
        if let note = self.noteModel, let model = note.noteDrawModel {
            self.updateValueNote(noteModel: model)
        }
        
        self.updateStatusButtonUndo()
        
    }
    
    private func setupRX() {
        // Add here the setup for the RX
        
        self.navigationItemView.actionItem = { [weak self] type in
            guard let wSelf = self else { return }
            switch type {
            case .close: wSelf.navigationController?.popViewController(animated: true)
                
            case .done:
                wSelf.navigationController?.popViewController(animated: true, {
                    let noteModel: NoteModel
                    let noteDraw = NoteDrawModel(data: wSelf.canvasView.drawing.dataRepresentation(), imageData: wSelf.converToImage())
                    if let note = wSelf.noteModel {
                        noteModel = NoteModel(noteType: .draw, text: nil, id: note.id, bgColorModel: nil,
                                              updateDate: Date.convertDateToLocalTime(), noteCheckList: nil, noteDrawModel: noteDraw)
                    } else {
                        noteModel = NoteModel(noteType: .draw, text: nil, id: Date.convertDateToLocalTime(), bgColorModel: nil,
                                              updateDate: Date.convertDateToLocalTime(), noteCheckList: nil, noteDrawModel: noteDraw)
                    }
                    RealmManager.shared.updateOrInsertConfig(model: noteModel)
                })
        
            default: break
            }
        }
        
        ActionUndo.allCases.forEach { [weak self] type in
            guard let wSelf = self else { return }
            let bt = wSelf.bts[type.rawValue]
            
            bt.rx.tap.bind { [weak self] _ in
                guard let wSelf = self else { return }
                
                switch type {
                case .undo:
                    wSelf.undoManager?.undo()
                case .redo:
                    wSelf.undoManager?.redo()
                }
                wSelf.updateStatusButtonUndo()
            }.disposed(by: disposeBag)
        }
    }
    
    private func updateStatusButtonUndo() {
        
        if let canUndo = self.undoManager?.canUndo, canUndo {
            self.bts[ActionUndo.undo.rawValue].setTitleColor(Asset.textColorApp.color, for: .normal)
        } else {
            self.bts[ActionUndo.undo.rawValue].setTitleColor(Asset.disableHome.color, for: .normal)
        }
        
        if let redo = self.undoManager?.canRedo, redo {
            self.bts[ActionUndo.redo.rawValue].setTitleColor(Asset.textColorApp.color, for: .normal)
        } else {
            self.bts[ActionUndo.redo.rawValue].setTitleColor(Asset.disableHome.color, for: .normal)
        }
        
    }
    
    private func converToImage() -> Data? {
        UIGraphicsBeginImageContextWithOptions(self.canvasView.bounds.size, false, UIScreen.main.scale)
        self.canvasView.drawHierarchy(in: self.canvasView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData()
    }
    
    private func updateValueNote(noteModel: NoteDrawModel) {
        guard let d = noteModel.data else {
            return
        }
        do {
            let data = try PKDrawing.init(data: d)
            self.canvasView.drawing = data
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateDrawWhenChangeLayou() {
        let canvasScale = self.canvasView.bounds.width / Constant.canvasWidth
        self.canvasView.minimumZoomScale = canvasScale
        self.canvasView.maximumZoomScale = canvasScale
        self.canvasView.zoomScale = canvasScale

        self.canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }

}
extension DrawVC: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        self.updateStatusButtonUndo()
    }
    
    func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
        
    }
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        
    }
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        
    }
}

extension DrawVC: PKToolPickerObserver {
    
    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        
        print("toolPickerSelectedToolDidChange")
    }
    
    func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerIsRulerActiveDidChange")
    }
    
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerVisibilityDidChange")
    }
    
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerFramesObscuredDidChange")
    }
}
