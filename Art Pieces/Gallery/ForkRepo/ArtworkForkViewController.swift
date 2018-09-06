//
//  ArtworkForkViewController.swift
//  Art Pieces
//
//  Created by 李灿晨 on 2018/8/30.
//  Copyright © 2018 李灿晨. All rights reserved.
//

import UIKit

class ArtworkForkViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    
    var pickArtworkView: PickArtworkView!
    var addArtworkDescriptionView: AddArtworkDescriptionView!
    
    var isAddingDescriptions: Bool = false
    
    var currentRepoID: UUID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickArtworkView()
        setupAddArtworkDescriptionView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let viewFrame = self.view.frame
        if isAddingDescriptions {
            pickArtworkView.frame = CGRect(x: -viewFrame.width, y: 20, width:
                viewFrame.width, height: viewFrame.height - 20)
            addArtworkDescriptionView.frame = CGRect(x: 0, y:
                20, width: viewFrame.width, height: viewFrame.height - 20)
        } else {
            pickArtworkView.frame = CGRect(x: 0, y: 20, width:
                viewFrame.width, height: viewFrame.height - 20)
            addArtworkDescriptionView.frame = CGRect(x: viewFrame.width, y:
                20, width: viewFrame.width, height: viewFrame.height - 20)
        }
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupPickArtworkView() {
        let nib = UINib(nibName: "PickArtworkView", bundle: Bundle.main)
        pickArtworkView = nib.instantiate(withOwner: self,
            options: nil).first as? PickArtworkView
        self.view.insertSubview(pickArtworkView, belowSubview: closeButton)
        pickArtworkView.delegate = self
        let lectures = DataManager.defaultManager.getAllArtboards()
        for lecture in lectures {
            let keyPhoto = DataManager.defaultManager.getImage(path: lecture.keyPhotoPath!)
            let forkPreview = ForkPreview(uuid: lecture.uuid!, title: lecture.title!, keyPhoto: keyPhoto)
            pickArtworkView.forkPreviews.append(forkPreview)
        }
    }
    
    private func setupAddArtworkDescriptionView() {
        let nib = UINib(nibName: "AddArtworkDescriptionView", bundle: Bundle.main)
        addArtworkDescriptionView = nib.instantiate(withOwner: self,
            options: nil).first as? AddArtworkDescriptionView
        self.view.insertSubview(addArtworkDescriptionView, belowSubview: closeButton)
        addArtworkDescriptionView.delegate = self
    }
    
}


extension ArtworkForkViewController: PickArtworkDelegate {
    func nextButtonDidTapped() {
        isAddingDescriptions = true
        UIView.animate(withDuration: 0.2, delay: 0, options:
            UIView.AnimationOptions.curveLinear, animations: {
            self.viewWillLayoutSubviews()
        }, completion: nil)
    }
    
    func artworkSelectionDidChanged() {
    }
    
    func shouldLaunch(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}


extension ArtworkForkViewController: AddArtworkDescriptionDelegate {
    func shareButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
