//
//  ViewController.swift
//  Happy520
//
//  Created by 钟镇阳 on 20/05/2016.
//  Copyright © 2016 钟镇阳. All rights reserved.
//

import UIKit
import AVFoundation
import LTMorphingLabel
import SDAutoLayout

class ViewController: UIViewController, GLNPianoViewDelegate {
    
    @IBOutlet weak var image: UIImageView!
    
    var success_count = 0
    var fontType = "qisi"
    
    var engine: AVAudioEngine!
    var sampler: AVAudioUnitSampler!
    
    var allowStroke = true
    var effArr = [LTMorphingEffect.anvil, LTMorphingEffect.burn,
                LTMorphingEffect.evaporate, LTMorphingEffect.fall,
                LTMorphingEffect.scale, LTMorphingEffect.sparkle,
                LTMorphingEffect.pixelate]
    var effIndex = 0
    
    var prevKey = -1
    var validArr = [2,2,1,2,2,2,1]
    var index = -1{
        didSet{
            if (index < textArr.count && index >= 0){
                label.text = textArr[index]
            }
            label.morphingEffect = effArr[effIndex]
            effIndex += 1
            if effIndex >= 7 {
                effIndex = 0
            }
        }
    }
    var label:LTMorphingLabel!
    
    @IBOutlet weak var keyboardView3: GLNPianoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label = LTMorphingLabel()
        view.addSubview(label)
        label.sd_layout()
            .topSpaceToView(view, 0)?
            .leftSpaceToView(view, 0)?
            .rightSpaceToView(view, 0)?
            .heightIs(500)
        label.morphingDuration = 0.2
        label.textAlignment = .center
        label.font = UIFont(name: fontType, size: 256)
        label.text = ""
        
        view.backgroundColor = UIColor.lightGray
        keyboardView3.delegate = self;
        startAudioEngine()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeImage), userInfo: nil, repeats: true)
    }
    
    var imageIndex = 0
    
    @objc func changeImage(){
        imageIndex += 1
        if imageIndex >= 16 {
            imageIndex = 0
        }
        let name = String(imageIndex)
        let ani = CABasicAnimation(keyPath: "contents")
        ani.duration = 0.8
        image.layer.contents = UIImage(named: name)?.cgImage
        image.layer.add(ani, forKey: "aniContent")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func endFinal(){
        label.text = ""
        label.font = UIFont(name: fontType, size: 256)
        allowStroke = true
    }
    
    func success(){
        allowStroke = false
        success_count+=1
        if success_count>=5 {
            success_count = 0
            label.font = UIFont(name: fontType, size: 40)
            label.text = code
            Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(endFinal), userInfo: nil, repeats: false)
        }
        else {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(first), userInfo: nil, repeats: false)
        }
    }
    
    @objc func first(){
        label.text = comb[0]
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(second), userInfo: nil, repeats: false)
    }
    
    @objc func second(){
        label.text = comb[1]
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(third), userInfo: nil, repeats: false)
    }
    
    @objc func third(){
        label.text = comb[2]
        allowStroke = true
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(disappear), userInfo: nil, repeats: false)
    }
    
    @objc func disappear(){
        label.text = ""
    }
    
    func isValid(_ keyNumber:Int)->Bool{
        if prevKey + validArr[index] == keyNumber {
            return true
        }
        else {
            return false
        }
    }
    
    func next(){
        prevKey+=validArr[index]
        index+=1
        if index >= validArr.count {
            index = -1
            prevKey = -1
            success()
        }
    }
    
    func checkKey(_ keyNumber:Int){
        if prevKey == -1 {
            prevKey = keyNumber
            label.text = ""
            index = 0
        }
        else if isValid(keyNumber){
            next()
        }
        else {
            prevKey = keyNumber
            label.text = ""
            index = 0
        }
    }
    
    func pianoKeyDown(_ keyNumber:Int) {
        if allowStroke {
            sampler.startNote(UInt8(60 + keyNumber), withVelocity: 64, onChannel: 0)
            checkKey(keyNumber)
        }
    }
    
    func pianoKeyUp(_ keyNumber:Int) {
        sampler.stopNote(UInt8(60 + keyNumber), onChannel: 0)
    }
    
    func startAudioEngine() {
        engine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        if engine.isRunning {
            print("audio engine already running")
            return
        }
        do {
            try engine.start()
            print("audio engine started")
        } catch {
            print("could not start audio engine")
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try
                audioSession.setCategory(.playback, options:AVAudioSession.CategoryOptions.mixWithOthers)
        } catch {
            print("audioSession: couldn't set category \(error)")
            return
        }
        do {
            try audioSession.setActive(true)
        } catch {
            print("audioSession: couldn't set category active \(error)")
            return
        }
    }
}

