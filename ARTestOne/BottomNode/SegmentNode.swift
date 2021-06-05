//
//  SegmentNode.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/20.
//

import SceneKit
class SegmentNode: SCNNode {
    var width: CGFloat
    var length: CGFloat
    
    
    //默认值
    static let thickness: CGFloat = 0.1
    static let length: CGFloat = 0.02  // segment length

    let alignment: Alignment
    let plane: SCNBox
    
    init(name: String, alignment: Alignment,width: CGFloat,length: CGFloat) {
        self.width = width
        self.length = length
        self.alignment = alignment
        switch alignment {
        case .vertical:
            
            plane = SCNBox(width: self.length, height: 0, length: self.width - RotateNode.size, chamferRadius: 0)
        case .horizontal:
            plane = SCNBox(width: self.width - RotateNode.size, height: 0, length: self.length, chamferRadius: 0)
        }
        super.init()
        self.name = name
        self.opacity = 0.7
        
        let material = plane.firstMaterial!
        material.diffuse.contents = BottomNode.primaryColor
        geometry = plane
    }
    
    init(name: String, alignment: Alignment) {
        self.width = SegmentNode.thickness
        self.length = SegmentNode.length
        self.alignment = alignment
        switch alignment {
        case .vertical:
            
            plane = SCNBox(width: SegmentNode.length, height: 0, length: SegmentNode.thickness - RotateNode.size, chamferRadius: 0)
        case .horizontal:
            plane = SCNBox(width: SegmentNode.thickness - RotateNode.size, height: 0, length: SegmentNode.length, chamferRadius: 0)
        }
        super.init()
        self.name = name
        self.opacity = 0.7
        
        let material = plane.firstMaterial!
        material.diffuse.contents = BottomNode.primaryColor
        geometry = plane
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
