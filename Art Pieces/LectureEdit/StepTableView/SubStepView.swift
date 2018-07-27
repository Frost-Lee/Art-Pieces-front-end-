//
//  SubStepView.swift
//  Art Pieces
//
//  Created by 李灿晨 on 2018/7/21.
//  Copyright © 2018 李灿晨. All rights reserved.
//

import UIKit

protocol SubStepViewDelegate {
    func subStepInteractionButtonDidTapped(_ index: Int)
}

class SubStepView: UIView {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subDescriptionLabel: UILabel!
    @IBOutlet weak var interactionButton: UIButton!
    
    var delegate: SubStepViewDelegate?
    var index: Int!
    
    var subStep: SubStep! {
        didSet {
            descriptionLabel.text = subStep.description()
            subDescriptionLabel.text = subStep.renderDescription
            switch subStep.operationType {
            case .colorChange:
                interactionButton.backgroundColor = subStep.renderMechanism.color
                interactionButton.setTitle("", for: .normal)
            case .toolChange:
                interactionButton.backgroundColor = APTheme.grayBackgroundColor
                interactionButton.setTitle((Tool.toolOfTexture(subStep.renderMechanism.texture)).toolName(),
                                           for: .normal)
            }
        }
    }
    
    static var height: CGFloat = 72
    
    var isToolInteractive: Bool! {
        didSet {
            if interactionButton != nil {
                interactionButton.isEnabled = isToolInteractive
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        interactionButton.layer.cornerRadius = 5
        interactionButton.layer.masksToBounds = true
        interactionButton.layer.borderColor = UIColor.gray.cgColor
        interactionButton.layer.borderWidth = 0.5
    }
    
    @IBAction func interactiveButtonTapped(_ sender: UIButton) {
        delegate?.subStepInteractionButtonDidTapped(index)
    }
    
}
