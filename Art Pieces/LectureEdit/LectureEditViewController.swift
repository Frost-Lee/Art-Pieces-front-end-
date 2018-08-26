//
//  LectureViewController.swift
//  Art Pieces
//
//  Created by 李灿晨 on 2018/7/22.
//  Copyright © 2018 李灿晨. All rights reserved.
//
//  Abstract:
//  LecturePresentationViewController is the place where people can watch the lecture and try their ideas by
//  themselves.

import UIKit
import ChromaColorPicker

class LectureEditViewController: UIViewController {
    
    @IBOutlet weak var stepTableView: UITableView!
    @IBOutlet weak var artworkView: ArtworkView!
    @IBOutlet weak var toolBarView: ToolBarView!
    
    var selectedSteps: Set<Int> = []
    
    var artworkGuide: ArtworkGuide = ArtworkGuide() {
        didSet {
            stepTableView.reloadData()
        }
    }
    
    private var isEraserSelected: Bool = false
    private var previousRenderMechanism: RenderMechanism?
    
    private var penPickerIdentifier: String = ""
    private var palletIdentifier: String = ""
    private var interactingStep: (Int, Int)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artworkView.currentRenderMechanism = RenderMechanism(color: UIColor.lightGray, width: 1.5, texture: "PencilTexture")
        artworkView.createLayer()
        artworkView.delegate = self
        artworkView.isRecordingForLecture = false
        let toolBarNib = UINib(nibName: "ToolBarView", bundle: nil)
        toolBarView = toolBarNib.instantiate(withOwner: self, options: nil).first as? ToolBarView
        toolBarView.delegate = self
        toolBarView.palletButton.backgroundColor = artworkView.currentRenderMechanism.color
        self.view.addSubview(toolBarView)
        stepTableView.register(StepTableViewCell.self, forCellReuseIdentifier: "stepTableViewCell")
        stepTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        toolBarView.frame = CGRect(x: stepTableView.frame.width, y: self.view.frame.height - CGFloat(71),
                                   width: UIScreen.main.bounds.width - stepTableView.frame.width, height: 71)
    }
    
    @IBAction func addStepButtonTapped(_ sender: UIButton) {
        artworkView.addAnotherStep()
    }
    
    private func launchPallet(with identifier: String, at view: UIView, initialColor: UIColor) {
        palletIdentifier = identifier
        ChromaColorPicker.launch(in: self, sourceView: view, initialColor:
            initialColor, frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    }
    
    private func launchPenPicker(with identifier: String, at view: UIView, initialTool: Tool) {
        penPickerIdentifier = identifier
        let toolPickerController = ToolPickerTableViewController()
        toolPickerController.selectedTool = initialTool
        toolPickerController.delegate = self
        toolPickerController.preferredContentSize = CGSize(width: 150, height: 150)
        toolPickerController.prepareToLaunchAsPopover(source: view)
        self.present(toolPickerController, animated: true, completion: nil)
    }
    
}


extension LectureEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artworkGuide.steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stepTableViewCell = StepTableViewCell(step: artworkGuide.steps[indexPath.row], index: indexPath.row)
        stepTableViewCell.delegate = self
        if selectedSteps.contains(indexPath.row) {
            stepTableViewCell.setupDetailedInterface()
        } else {
            stepTableViewCell.setupTitleInterface()
        }
        return stepTableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedSteps.contains(indexPath.row) {
            let step = artworkGuide.steps[indexPath.row]
            let fullHeight = CGFloat(step.subSteps.count) * SubStepView.height + StepTitleView.height
            return fullHeight
        } else {
            let titleHeight = StepTitleView.height
            return titleHeight
        }
    }
}


extension LectureEditViewController: StepTableViewCellDelegate {
    func stepTitleBarDidTapped(at index: Int) {
        stepTableView.beginUpdates()
        if selectedSteps.contains(index) {
            selectedSteps.remove(index)
        } else {
            selectedSteps.insert(index)
        }
        stepTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        stepTableView.endUpdates()
    }
    
    func subStepInteractionButtonDidTapped(step: Int, subStep: Int) {
        interactingStep = (step, subStep)
        let cell = stepTableView.cellForRow(at: IndexPath(row: step, section: 0)) as! StepTableViewCell
        switch cell.step.subSteps[subStep].operationType {
        case .colorChange:
            launchPallet(with: "Record", at: cell.subStepViews[subStep].interactionButton, initialColor:
                cell.step.subSteps[subStep].renderMechanism.color)
        case .toolChange:
            launchPenPicker(with: "Record", at: cell.subStepViews[subStep].interactionButton, initialTool:
                Tool.toolOfTexture(cell.step.subSteps[subStep].renderMechanism.texture))
        }
    }
    
    func subDescriptionTextDieEditted(to text: String, step: Int, subStep: Int) {
        artworkView.guide.steps[step].subSteps[subStep].renderDescription = text
    }
}


extension LectureEditViewController: ArtworkViewDelegate {
    func artworkGuideDidUpdated(_ guide: ArtworkGuide) {
        artworkGuide = guide
    }
}


extension LectureEditViewController: ToolBarViewDelegate {
    func palletButtonDidTapped(_ sender: UIButton) {
        launchPallet(with: "ToolBar", at: toolBarView.palletButton, initialColor:
            artworkView.currentRenderMechanism.color)
    }
    
    func layerButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func thichnessButtonDidTapped(_ sender: UIButton) {
        let thicknessSliderController = ThicknessSliderViewController()
        thicknessSliderController.delegate = self
        thicknessSliderController.lowerBound = artworkView.currentRenderMechanism.minimumWidth
        thicknessSliderController.upperBound = artworkView.currentRenderMechanism.maximunWidth
        thicknessSliderController.slider.value = Float(artworkView.currentRenderMechanism.width)
        thicknessSliderController.preferredContentSize = CGSize(width: 300, height: 50)
        thicknessSliderController.prepareToLaunchAsPopover(source: toolBarView.thicknessButton)
        self.present(thicknessSliderController, animated: true, completion: nil)
    }
    
    func transparencyButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func eraserButtonDidTapped(_ sender: UIButton) {
        if isEraserSelected {
            artworkView.currentRenderMechanism = previousRenderMechanism
            isEraserSelected = false
        } else {
            isEraserSelected = true
            previousRenderMechanism = artworkView.currentRenderMechanism
            artworkView.currentRenderMechanism = getEraser(with: 5.0)
        }
    }
    
    func penButtonDidTapped(_ sender: UIButton) {
        launchPenPicker(with: "ToolBar", at: toolBarView.penButton, initialTool:
            Tool.toolOfTexture(artworkView.currentRenderMechanism.texture))
    }
}


extension LectureEditViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        switch palletIdentifier {
        case "ToolBar":
            artworkView.currentRenderMechanism.color = color
            toolBarView.palletButton.backgroundColor = color
        case "Record":
            artworkView.guide.steps[interactingStep!.0].subSteps[interactingStep!.1].renderMechanism.color = color
            artworkView.adjustAccordingTo(step: interactingStep!.0, subStep: interactingStep!.1)
            break
        default:
            break
        }
    }
}


extension LectureEditViewController: ToolPickerTableViewDelegate {
    func toolSelected(_ tool: Tool) {
        let textureName = tool.textureName()
        switch penPickerIdentifier {
        case "ToolBar":
            if artworkView.currentRenderMechanism.texture != textureName {
                artworkView.currentRenderMechanism.texture = textureName
            }
        case "Record":
            artworkView.guide.steps[interactingStep!.0].subSteps[interactingStep!.1].renderMechanism.texture = tool.textureName()
            artworkView.adjustAccordingTo(step: interactingStep!.0, subStep: interactingStep!.1)
        default:
            break
        }
    }
}


extension LectureEditViewController: ThicknessSliderDelegate {
    func thicknessDidSet(to value: Float) {
        artworkView.currentRenderMechanism.width = CGFloat(value)
    }
}
