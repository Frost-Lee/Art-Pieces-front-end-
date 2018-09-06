//
//  PersonalViewController.swift
//  Art Pieces
//
//  Created by 李灿晨 on 2018/8/31.
//  Copyright © 2018 李灿晨. All rights reserved.
//

import UIKit

class PersonalViewController: UIViewController {
    
    @IBOutlet weak var largePortraitImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    @IBOutlet weak var starNumberLabel: UILabel!
    @IBOutlet weak var personalCollectionView: UICollectionView! {
        didSet {
            personalCollectionView.register(UINib(nibName: "GalleryCollectionViewCell",
                bundle: Bundle.main), forCellWithReuseIdentifier: "personalCollectionViewCell")
        }
    }
    @IBOutlet weak var userBackgroundImageView: UIImageView! {
        didSet {
            userBackgroundImageView.clipsToBounds = true
        }
    }
    
    var addArtworkView: AddArtworkView!
    
    private var projects: [ProjectPreview] = []
    private var localUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.sendSubviewToBack((self.navigationController?.navigationBar)!)
        self.navigationController?.navigationBar.tintColor = .white
        setupAddArtworkView()
        loadLocalUser()
        loadProjects()
        personalCollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.view.bringSubviewToFront((self.navigationController?.navigationBar)!)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        addArtworkView.activate()
    }
    
    @IBAction func modifyUserButtonTapped(_ sender: UIButton) {
        if localUser == nil {
            let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let viewController = storyboard.instantiateInitialViewController() as! LoginViewController
            viewController.dismissBlock = {self.loadLocalUser()}
            present(viewController, animated: true)
        }
    }
    
    @IBAction func notificationButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func projectsButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func favoritesButtonTapped(_ sender: UIButton) {
    }
    
    private func setupAddArtworkView() {
        let nib = UINib(nibName: "AddArtworkView", bundle: Bundle.main)
        addArtworkView = nib.instantiate(withOwner: self, options: nil).first as? AddArtworkView
        addArtworkView.useNavigationBarIncludedLayout = true
        self.view.addSubview(addArtworkView)
    }
    
    private func loadLocalUser() {
        if AccountManager.defaultManager.isUserExist() {
            localUser = AccountManager.defaultManager.currentUser
            let portrait = getPersonalPortrait()
            userNameLabel.text = localUser!.name
            largePortraitImageView.image = portrait
        } else {
            let portrait = getPersonalPortrait()
            userNameLabel.text = "Login / Register"
            largePortraitImageView.image = portrait
        }
    }
    
    private func loadProjects() {
        let creatorPortrait = getPersonalPortrait(useGrayPortrait: true)
        let lectures = DataManager.defaultManager.getAllLectures()
        let artworks = DataManager.defaultManager.getAllArtworks()
        for lecture in lectures {
            let lectureKeyPhoto = DataManager.defaultManager.getImage(path: lecture.previewPhotoPath!)
            let project = ProjectPreview(isLecture: true, uuid: lecture.uuid!, keyPhoto: lectureKeyPhoto, title: lecture.title!,
                                  creatorName: localUser?.name ?? "Login", creatorPortrait: creatorPortrait,
                                  numberOfForks: 0, numberOfStars: 0)
            projects.append(project)
        }
        for artwork in artworks {
            let artworkKeyPhoto = DataManager.defaultManager.getImage(path: artwork.keyPhotoPath!)
            let project = ProjectPreview(isLecture: false, uuid: artwork.uuid!, keyPhoto: artworkKeyPhoto, title: artwork.title!,
                                  creatorName: localUser?.name ?? "Login", creatorPortrait: creatorPortrait,
                                  numberOfForks: 0, numberOfStars: 0)
            projects.append(project)
        }
    }
    
    private func getPersonalPortrait(useGrayPortrait: Bool = false) -> UIImage {
        var portrait: UIImage!
        if localUser == nil {
            portrait = UIImage(named: (useGrayPortrait ? "" : "White") + "QuestionMark")
        } else if localUser!.portraitPath != nil && localUser!.portraitPath?.count != 0 {
            portrait = DataManager.defaultManager.getImage(path: localUser!.portraitPath!)
        } else {
            portrait = UIImage(named: (useGrayPortrait ? "" : "White") + "User")
        }
        return portrait
    }
    
}


extension PersonalViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
            "personalCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        cell.project = projects[indexPath.row]
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 20 * 2 - 36 * 2) / 3
        let height = width / 0.967
        return CGSize(width: width, height: height)
    }
}


extension PersonalViewController: GalleryCollectionDelegate {
    func moreButtonDidTapped(index: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deletion = UIAlertAction(title: "Delete", style: .destructive) { action in
            if self.projects[index].isLecture {
                DataManager.defaultManager.removeLecture(uuid: self.projects[index].uuid)
            } else {
                DataManager.defaultManager.removeArtwork(uuid: self.projects[index].uuid)
            }
            self.projects.remove(at: index)
            self.personalCollectionView.reloadData()
        }
        alert.addAction(deletion)
        let anchor = personalCollectionView.cellForItem(at: IndexPath(row: index, section: 0))
            as! GalleryCollectionViewCell
        alert.popoverPresentationController?.sourceView = anchor.moreButton
        alert.popoverPresentationController?.sourceRect = anchor.moreButton.bounds
        present(alert, animated: true, completion: nil)
    }
}