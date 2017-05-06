//
//  ViewController.swift
//  Camera
//
//  Created by 恵上裕介 on 2017/05/05.
//  Copyright © 2017年 yusuke egami. All rights reserved.
//

import Alamofire
import UIKit
import AVFoundation


class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    @IBAction func takeIt2(_ sender: Any) {
    
        // フラッシュとかカメラの細かな設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        // シャッターを切る
        stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        captureSesssion = AVCaptureSession()
        stillImageOutput = AVCapturePhotoOutput()
        
        captureSesssion.sessionPreset = AVCaptureSessionPreset1920x1080 // 解像度の設定
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            // 入力
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                
                // 出力
                if (captureSesssion.canAddOutput(stillImageOutput)) {
                    captureSesssion.addOutput(stillImageOutput)
                    captureSesssion.startRunning() // カメラ起動
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect // アスペクトフィット
                    previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait // カメラの向き
                    
                    imageView.layer.addSublayer(previewLayer!)
                    
                    // ビューのサイズの調整
                    previewLayer?.position = CGPoint(x: self.imageView.frame.width / 2, y: self.imageView.frame.height / 2)
                    previewLayer?.bounds = imageView.frame
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    // デリゲート。カメラで撮影が完了した後呼ばれる。JPEG形式でフォトライブラリに保存。
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            // JPEG形式で画像データを取得
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            
            // フォトライブラリに保存
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.uploadFile(image)
        
        self.imageView.image = image
        //        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
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

