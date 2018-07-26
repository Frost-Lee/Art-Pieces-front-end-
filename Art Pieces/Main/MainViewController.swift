//
//  MainViewController.swift
//  Art Pieces
//
//  Created by 李灿晨 on 2018/7/26.
//  Copyright © 2018 李灿晨. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var masterNavigationView: MasterNavigationView!
    
    var galleryView: GalleryView!
    var lectureView: LectureView!
    
    var onSightLockFrame: CGRect!
    var offSightLockFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.lightGray
        let masterNavigationNib = UINib(nibName: "MasterNavigationView", bundle: nil)
        masterNavigationView = masterNavigationNib.instantiate(withOwner: self, options: nil).first
            as? MasterNavigationView
        masterNavigationView.delegate = self
        self.view.addSubview(masterNavigationView)
        
        setupGalleryView()
        setupLectureView()
        let selfFrame = self.view.frame
        onSightLockFrame = CGRect(x: 0, y: 110, width: selfFrame.width, height: selfFrame.height - 110)
        offSightLockFrame = CGRect(x: selfFrame.width, y: 110, width: selfFrame.width, height: selfFrame.height - 110)
        setGalleryOnSight()
        self.view.addSubview(galleryView)
        self.view.addSubview(lectureView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let screenWidth = UIScreen.main.bounds.width
        masterNavigationView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 110)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupGalleryView() {
        let nib = UINib(nibName: "Gallery", bundle: nil)
        galleryView = nib.instantiate(withOwner: self, options: nil).first as? GalleryView
    }
    
    private func setupLectureView() {
        let nib = UINib(nibName: "Lecture", bundle: nil)
        lectureView = nib.instantiate(withOwner: self, options: nil).first as? LectureView
    }
    
    private func setGalleryOnSight() {
        galleryView.frame = onSightLockFrame
        lectureView.frame = offSightLockFrame
    }
    
    private func setLectureOnSight() {
        lectureView.frame = onSightLockFrame
        galleryView.frame = offSightLockFrame
    }

}


extension MainViewController: MasterNavigationDelegate {
    func galleryButtonDidTapped(_ sender: UIButton) {
        setGalleryOnSight()
    }
    
    func lectureButtonDidTapped(_ sender: UIButton) {
        setLectureOnSight()
    }
    
    func searchButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func settingButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func notificationButtonDidTapped(_ sendr: UIButton) {
        
    }
    
    func meButtonDidTapped(_ sender: UIButton) {
        
    }
    
    func artworkButtonDidTapped(_ sender: UIButton) {
        
    }
}
