//
//  NewRepositoryViewController.swift
//  Art Pieces
//
//  Created by 李灿晨 on 2018/9/4.
//  Copyright © 2018 李灿晨. All rights reserved.
//

import UIKit

class NewRepositoryViewController: APFormSheetViewController {
    
    var newRepoView: NewRepoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNewRepoView()
        launchImagePicker()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        newRepoView.frame = CGRect(x: 0, y: 20, width: self.view.frame.width,
                                   height: self.view.frame.height - 20)
    }
    
    private func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.navigationBar.tintColor = APTheme.purpleHighLightColor
        imagePicker.modalPresentationStyle = .overCurrentContext
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func setupNewRepoView() {
        let nib = UINib(nibName: "NewRepoView", bundle: Bundle.main)
        newRepoView = nib.instantiate(withOwner: self, options: nil).first as? NewRepoView
        self.view.insertSubview(newRepoView, belowSubview: closeButton)
        newRepoView.delegate = self
    }
    
}


extension NewRepositoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [String: Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
         newRepoView.keyPhoto = selectedImage
        picker.dismiss(animated: true, completion: nil)
    }
}


extension NewRepositoryViewController: NewRepoDelegate {
    func shareButtonDidTapped() {
        newRepoView.beginAnimatingSpinner()
        let user = AccountManager.defaultManager.currentUser!
        let newArtworkID = UUID()
        let newRepoID = UUID()
        let title = newRepoView.title
        let description = newRepoView.repoDescription
        let keyPhoto = newRepoView.keyPhoto!
        APWebService.defaultManager.uploadArtwork(creatorEmail: user.email, creatorPassword:
            user.password, title: title, description: description, keyPhoto:
        keyPhoto, belongingRepo: nil, selfID: newArtworkID) {
            APWebService.defaultManager.createRepo(creatorEmail: user.email, creatorPassword:
                user.password, title: title, description: description, selfID: newRepoID,
                               keyArtworkID: newArtworkID) {
                                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
