//
//  ViewController.swift
//  metalVideoFilter
//
//  Created by dt on 14/03/2022.
//

import Foundation
import UIKit
import MetalKit
import AVFoundation
import CoreImage.CIFilterBuiltins
import Vision

class ViewController: UIViewController, MTKViewDelegate{
    
    private let requestHandler = VNSequenceRequestHandler()
    var altitude = 0.4
    var darkness = 1.8
    var scattering = 0.1
    var incer = 0.00001
    
    var sunDim =  0.1
    
    @IBOutlet weak var cameraView: MTKView!{
        
        didSet {
            guard metalDevice == nil else { return }
            setupMetal()
            setupCoreImage()
         
            
        }
    }
    
    
    
    // The Metal pipeline.
    public var metalDevice: MTLDevice!
    public var metalCommandQueue: MTLCommandQueue!
    
    // The Core Image pipeline.
    public var ciContext: CIContext!
    public var currentCIImage: CIImage? {
        didSet {
            cameraView.draw()
        }
    }
    
    public var session: AVCaptureSession?
    
    func resetVar(){
        altitude = 0.4
        darkness = 1.8
        scattering = 0.1
        incer = 0.00001
        
        sunDim =  0.1
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .common)
    }
    
    @objc func update(){
       // print("updated")
        processFrame()
        
        
    }
    
    func processFrame(){
        let filter = SunVisualizerFilter()
        filter.inputWidth = self.cameraView.frame.width
        filter.inputHeight = self.cameraView.frame.height
        filter.inputSunAlitude = altitude
        filter.inputSkyDarkness = darkness
        filter.inputSunDiameter = sunDim
//        let fil = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey:filter.outputImage!, kCIInputRadiusKey: 15])
        //filter.inputAlbedo = scattering
        let fc = CIFilter(name: "CIHueAdjust")
        fc?.setValue(filter.outputImage, forKey: "inputImage")
        fc?.setValue(100, forKey: "inputAngle")
//        //fc?.setValue(CIColor.yellow, forKey: "inputColor0")
//        fc?.setValue(CIColor(red: 0.9, green: 0.1, blue: 0.3, alpha: 0.5), forKey: "inputColor1")
        currentCIImage = fc?.outputImage
        altitude += incer
        incer = incer * 1.01
       // print(altitude)
        if(altitude > 1.3){
            if(darkness > 0.005){
            darkness = darkness - 0.003
            }
            scattering = scattering - 0.005
            sunDim -= 0.0005
            print(sunDim)
            if(sunDim < -0.5){
                resetVar()
            }
        }
        
    }
        
    
    
    private func processVideoFrame(sample:CIImage){
        let ciFilter = OpticalFlowVisualizerFilter()
        ciFilter.inputImage = sample
       // let fil = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey:ciFilter.outputImage!, kCIInputRadiusKey: 15])
        //currentCIImage = fil?.outputImage?.cropped(to: sample.extent)
        let filter = SunVisualizerFilter()
        filter.inputHeight = sample.extent.width
        filter.inputHeight = sample.extent.height
        filter.inputSunAlitude = altitude
        filter.inputSkyDarkness = darkness
        filter.inputSunDiameter = sunDim
        let fil = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputImageKey:filter.outputImage!, kCIInputRadiusKey: 15])
        //filter.inputAlbedo = scattering
        currentCIImage = fil?.outputImage
        altitude += incer
        incer = incer * 1.01
        print(altitude)
        if(altitude > 1.3){
            if(darkness > 0.1){
            darkness = darkness - 0.005
            }
            scattering = scattering - 0.0001
            sunDim -= 0.0005
        }
        
    }
}




