//
//  RotateNode.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/20.
//

import SceneKit
class RotateNode: SCNNode {
    static let size: CGFloat = 0.03
    
    init(name: String) {
        
        let box = SCNBox(width: RotateNode.size, height: 0, length: RotateNode.size, chamferRadius: 0)
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
