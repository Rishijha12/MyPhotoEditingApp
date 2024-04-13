//
//  EditViewController.swift
//  MyPhotoEditingApp
//
//  Created by Rishi Jha on 11/04/24.
//

import UIKit
import CoreImage
import PhotosUI
import FMPhotoPicker

class EditViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate,FMPhotoPickerViewControllerDelegate, FMImageEditorViewControllerDelegate {
    func fmImageEditorViewController(_ editor: FMPhotoPicker.FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        self.dismiss(animated: true, completion: nil)
        imagePreviewView.image = photo
    }
    
    
    @IBOutlet weak var imagePreviewView: UIImageView!
    @IBOutlet weak var filterCollectionView: UICollectionView!{
        didSet{
            self.filterCollectionView.delegate = self
            self.filterCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var addBackgroundButton: UIButton!
    @IBOutlet weak var overlayImagesButton: UIButton!
    @IBOutlet weak var addFilterButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var photo: Photo?
    var filters: [CIFilter] = []
    var overlayImages: [UIImage] = []
    var overlayImage: UIImage?
    var capturedImage: UIImage?
    var backgroundImage: UIImage?
    private var maxImage: Int = 5
    private var maxVideo: Int = 5
    
//    init(photo: Photo) {
//          self.photo = photo
//          super.init(nibName: nil, bundle: nil)
//      }
//      
//      required init?(coder: NSCoder) {
//          fatalError("init(coder:) has not been implemented")
//      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFilters()
    }
    
    private func setupUI() {
        imagePreviewView.image = photo?.image
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        
        addBackgroundButton.addTarget(self, action: #selector(addBackgroundButtonTapped), for: .touchUpInside)
        overlayImagesButton.addTarget(self, action: #selector(overlayImagesButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        addFilterButton.addTarget(self, action: #selector(loadFilters), for: .touchUpInside)
    }
    
    func setupFilters() {
           // Add your filters to the `filters` array
           let sepiaTone = CIFilter(name: "CISepiaTone")
           filters.append(sepiaTone!)
           
           let vignette = CIFilter(name: "CIVignette")
           filters.append(vignette!)
//        self.filterCollectionView.reloadData()
           
           // Add more filters as needed
        
       }
    
    @objc private func loadFilters() {
        // Load available filters and populate the `filters` array
        let vc = FMImageEditorViewController(config: config(), sourceImage: imagePreviewView.image!)
        vc.delegate = self
        
        self.present(vc, animated: true)
    }
    
    @objc private func addBackgroundButtonTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func overlayImagesButtonTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // Set to 0 for unlimited selection
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        // Save the edited image to the user's photo library
        guard let combinedImage = combineImages() else { return }
        UIImageWriteToSavedPhotosAlbum(combinedImage, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func combineImages() -> UIImage? {
        guard let capturedImage = capturedImage else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: capturedImage.size)
        let combinedImage = renderer.image { context in
            capturedImage.draw(at: .zero)
            
            if let backgroundImage = backgroundImage {
                backgroundImage.draw(in: CGRect(origin: .zero, size: capturedImage.size))
            }
            
            if let overlayImage = overlayImage {
                overlayImage.draw(in: CGRect(origin: .zero, size: capturedImage.size))
            }
            
            if let caption = captionTextField.text, !caption.isEmpty {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24),
                    .foregroundColor: UIColor.white
                ]
                let captionRect = CGRect(x: 10, y: capturedImage.size.height - 50, width: capturedImage.size.width - 20, height: 40)
                caption.draw(with: captionRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            }
        }
        
        return combinedImage
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
          if let error = error {
              let alert = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              present(alert, animated: true)
          } else {
              let alert = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              present(alert, animated: true)
          }
      }
    
    @objc private func shareButtonTapped() {
        guard let image = imagePreviewView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if picker.configuration.selectionLimit == 0 {
            // Multiple image selection for overlays
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    if let image = object as? UIImage {
                        self?.overlayImages.append(image)
                    }
                }
            }
        } else {
            // Single image selection for background
            guard let result = results.first else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.photo?.backgroundImage = image
                        self?.imagePreviewView.image = self?.photo?.image
                    }
                }
            }
        }
    }
    
    func config() -> FMPhotoPickerConfig {

        var config = FMPhotoPickerConfig()
        // in force crop mode, only the first crop option is available
        config.availableCrops = [
            FMCrop.ratioSquare,
            FMCrop.ratioCustom,
            FMCrop.ratio4x3,
            FMCrop.ratio16x9,
            FMCrop.ratio9x16,
            FMCrop.ratioOrigin,
        ]
        
        // all available filters will be used
        config.availableFilters = []
        
        return config
    }

}

extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2//filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
//        let filter = filters[indexPath.row]
//        cell.configure(with: filter)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]
        applyFilter(selectedFilter)
    }
    
    
    
    private func applyFilter(_ filter: CIFilter) {
        // Apply the selected filter to the photo
    }
}

extension EditViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: 50, height: 50)
       }
}
