//
//  ViewController.swift
//  coreMLVision
//
//  Created by Mac on 2019/1/25.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import CoreML
import Vision

// 這邊我們讓 ViewController 繼承 UIViewController
// Delegate 在這邊會類似 interface 的概念，會先定義我們有什麼 inferface，但不一定需要現在實做
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    private var imagePicker = UIImagePickerController()
    private var model = GoogLeNetPlaces()
    
    
    override func viewDidLoad() {
        // super 代表我們雖然 override viewDidLoad，但還是會用上 UIViewController 裡面原本的定義，因此使用 super 來呼叫原本的內容
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.delegate = self
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        self.photoImage.image = pickedImage
        
        processImage(image: pickedImage)
    }
    
    private func processImage(image: UIImage) {
        
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to creat ciImage Objects")
        }
        
        guard let visionModel = try? VNCoreMLModel(for: self.model.model) else {
            fatalError("Unable to create vision model")
        }
        
        let visionRequest = VNCoreMLRequest(model: visionModel) { request, error in
            
            if error != nil {
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            let classfications = results.map { observation in
                "\(observation.identifier) \(observation.confidence * 100)"
            }
            
            DispatchQueue.main.sync {
                self.descriptionTextView.text = classfications.joined(separator: "\n")
            }
            
            
            
            
        }
        
        let visionRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        DispatchQueue.global(qos: .userInteractive).async {
            try! visionRequestHandler.perform([visionRequest])
        }
    }
    
    @IBAction func openPhotoLibraryPressed(_ sender: Any) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
}

