//
//  RotateNode.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/20.
//

import SceneKit
class RotateNode: SCNNode {
    static let radius: CGFloat = 0.03
    
    init(name: String) {
        
        let box = SCNBox(width: RotateNode.radius, height: 0, length: RotateNode.radius, chamferRadius: 0)
        super.init()
        self.name = name
        let material = box.firstMaterial!
        material.diffuse.contents = UIImage.init(named:"arrow")
        geometry = box
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
