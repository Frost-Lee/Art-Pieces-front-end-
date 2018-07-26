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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        artworkView.currentRenderMechanism = RenderMechanism(color: UIColor.lightGray, width: 2, texture: "PencilTexture")
        artworkView.switchLayer(to: 0)
        artworkView.delegate = self
        artworkView.isRecordingForLecture = true
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
        
    }
}


extension LectureEditViewController: ArtworkViewDelegate {
    func artworkGuideDidUpdated(_ guide: ArtworkGuide) {
        artworkGuide = guide
    }
}


extension LectureEditViewController: ToolBarViewDelegate {
    func palletButtonDidTapped(_ sender: UIButton) {
        ChromaColorPicker.launch(in: self, sourceView: toolBarView.palletButton, initialColor:
            artworkView.currentRenderMechanism.color, frame: CGRect(x: 0, y: 0, width: 300, height: 300))
    }
    
    func layerButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func thichnessButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func transparencyButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func eraserButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func penButtonDidTapped(_ sender: UIButton) {
        let toolPickerController = ToolPickerTableViewController()
        toolPickerController.selectedTool = Tool.toolOfTexture(artworkView.currentRenderMechanism.texture)
        toolPickerController.delegate = self
        toolPickerController.preferredContentSize = CGSize(width: 150, height: 150)
        toolPickerController.prepareToLaunchAsPopover(source: toolBarView.penButton)
        self.present(toolPickerController, animated: true, completion: nil)
    }
}


extension LectureEditViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        artworkView.currentRenderMechanism.color = color
        toolBarView.palletButton.backgroundColor = color
    }
}


extension LectureEditViewController: ToolPickerTableViewDelegate {
    func toolSelected(_ tool: Tool) {
        let textureName = tool.textureName()
        if artworkView.currentRenderMechanism.texture != textureName {
            artworkView.currentRenderMechanism.texture = textureName
        }
    }
}
