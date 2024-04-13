//
//  CameraViewController.swift
//  MyPhotoEditingApp
//
//  Created by Rishi Jha on 11/04/24.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var previewView: UIView!

    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        // Set up the capture session and preview layer
    }

    func captureImage() {
        // Capture an image from the camera
    }


}
