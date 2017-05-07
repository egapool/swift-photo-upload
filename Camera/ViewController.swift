//
//  ViewController.swift
//  Camera
//
//  Created by 恵上裕介 on 2017/05/05.
//  Copyright © 2017年 yusuke egami. All rights reserved.
//

import Alamofire
import UIKit
import Fusuma

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FusumaDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func launchCamera(_ sender: UIBarButtonItem) {
        
//        let camera = UIImagePickerControllerSourceType.savedPhotosAlbum
//        if UIImagePickerController.isSourceTypeAvailable(camera) {
//            let picker = UIImagePickerController()
//            picker.sourceType = camera
//            picker.delegate = self
//            self.present(picker, animated:true)
//        }
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
//        fusuma.hasVideo = true // If you want to let the users allow to use video.
        self.present(fusuma, animated: true, completion: nil)
    }
    
    // MARK: FusumaDelegate Protocol
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Image captured from Camera")
        case .library:
            print("Image selected from Camera Roll")
        default:
            print("Image selected")
        }
        
        imageView.image = image
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        print("Called just after FusumaViewController is dismissed.")
        self.uploadFile(image)
    }
    
    func fusumaClosed() {
        print("Called fusuma closed.")
    }
    
    func fusumaWillClosed() {
        print("Called fusuma will closed.")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func uploadFile(_ cameraImage: UIImage) {
        let imageData = UIImageJPEGRepresentation(cameraImage, 0.9)
        
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: "camera_img",fileName: "camera_img", mimeType: "image/jpeg")
            },
            to: "http://192.168.0.107/",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        print("Request: \(response.request)")
                        print("Response: \(response.response)")
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                            print("Data: \(utf8Text)")
                        }
                        print("Error: \(response.error)")
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
        

    }

}

