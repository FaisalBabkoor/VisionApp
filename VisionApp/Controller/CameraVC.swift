//
//  ViewController.swift
//  VisionApp
//
//  Created by Faisal Babkoor on 9/17/18.
//  Copyright © 2018 Faisal Babkoor. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

enum FlashControl {
    case off
    case on
}

class CameraVC: UIViewController {
    //MARK:- IBOutlet
    @IBOutlet var captureImageView: UIImageView!
    @IBOutlet var roundedLblView: RoundedShadowView!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var flashBtn: UIButton!
    @IBOutlet var identificationLbl: UILabel!
    @IBOutlet var confidenceLbl: UILabel!
    //MARK:- Variable
    var photoData: Data?
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var flashControl: FlashControl = .off
    var speechSynthesizer = AVSpeechSynthesizer()
    //MARK:- functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.frame
        speechSynthesizer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .hd1920x1080
        let tap = UITapGestureRecognizer(target: self, action: #selector(CameraVC.didTapCameraView))
        tap.numberOfTapsRequired = 1
        guard let backCamera = AVCaptureDevice.default(for: .video) else {return}
        guard let input = try? AVCaptureDeviceInput(device: backCamera) else {return}
        if captureSession.canAddInput(input){
            captureSession.addInput(input)
        }
        cameraOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(cameraOutput){
            captureSession.addOutput(cameraOutput)
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraView.layer.addSublayer(previewLayer)
        cameraView.addGestureRecognizer(tap)
        captureSession.startRunning()
    }
    

    @objc func didTapCameraView(){
        if self.speechSynthesizer.isSpeaking{
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        let settings = AVCapturePhotoSettings()
        
        if flashControl == .off{
            settings.flashMode = .off
        }else{
            settings.flashMode = .on
        }
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    @IBAction func flashButtonWasPressed(_ sender: RoundedShadowButton) {
        switch flashControl {
        case .off:
            flashBtn.setTitle("Flash ON", for: .normal)
            flashControl = .on
        case .on:
            flashBtn.setTitle("Flash OFF", for: .normal)
            flashControl = .off
        }
    }
    func synthesizerSpeech(fromString string: String){
        let speechUtterence = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterence)
    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            debugPrint(String(describing: error))
            return
        }
        guard let photoDataRepresentation = photo.fileDataRepresentation() else {return}
        photoData = photoDataRepresentation
        guard let photoData = photoData else { return }
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        let request = VNCoreMLRequest(model: model) { (finisedRequest, error) in
           guard let results = finisedRequest.results as? [VNClassificationObservation] else {return}
            for result in results{
                if result.confidence < 0.5{
           
                    let unkounObjectMessage = "I'm not sure what this is. Please try again."
                    self.identificationLbl.text = unkounObjectMessage
                    self.synthesizerSpeech(fromString: unkounObjectMessage)
                    if self.speechSynthesizer.isSpeaking{
                        
                    }
                    self.confidenceLbl.isHidden = true
                    break
                }else{
              
                    let identification = result.identifier
                    let confidence = Int(ceil(result.confidence * 100))
                    self.identificationLbl.text = identification
                    self.confidenceLbl.text = "confidence: \(confidence)%"
                    let completeSentence = "This is looks like a \(identification) and I'm \(confidence) persent sure"
                    self.synthesizerSpeech(fromString: completeSentence)
                    self.confidenceLbl.isHidden = false

                    break
                }
            }
        }
        try? VNImageRequestHandler(data: photoData, options: [:]).perform([request])

       

       let image = UIImage(data: photoData)
        self.captureImageView.image = image
        
    }
}
extension CameraVC: AVSpeechSynthesizerDelegate{
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //speechSynthesizer.s
    }
    
}
