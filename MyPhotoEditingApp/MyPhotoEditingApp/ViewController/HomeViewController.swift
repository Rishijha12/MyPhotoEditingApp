//
//  ViewController.swift
//  MyPhotoEditingApp
//
//  Created by Rishi Jha on 11/04/24.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!{
        didSet{
            self.captureButton.setTitle("Capture", for: .normal)
            self.captureButton.backgroundColor = .green
        }
    }
    
    @IBOutlet weak var editButton: UIButton!

    var photo: Photo?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Configure UI elements
        self.navigationItem.title = "Home"
    }

    @IBAction func captureButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
        vc.photo = photo
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photo = Photo(image: image)
            imageView.image = photo?.image
        }
        dismiss(animated: true, completion: nil)
    }
}

