//
//  SegmentNode.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/20.
//

import SceneKit
class SegmentNode: SCNNode {
    var segmentWidth: CGFloat
    //短边固定大小
    var segmentLength: CGFloat
    
    
    //默认值
    static let thickness: CGFloat = 0.1
    static let length: CGFloat = 0.02  // segment length

    let alignment: Alignment
    let plane: SCNBox
    
    init(name: String, alignment: Alignment,width: CGFloat,length: CGFloat) {
        self.segmentWidth = width
        self.segmentLength = length
        self.alignment = alignment
        switch alignment {
        case .vertical:
            
            plane = SCNBox(width: self.segmentLength, height: 0, length: self.segmentWidth - RotateNode.size, chamferRadius: 0)
        case .horizontal:
            plane = SCNBox(width: self.segmentWidth - RotateNode.size, height: 0, length: self.segmentLength, chamferRadius: 0)
        }
        super.init()
        self.name = name
        self.opacity = 0.7
        
        let material = plane.firstMaterial!
        material.diffuse.contents = BottomNode.primaryColor
        geometry = plane
    }
    
    init(name: String, alignment: Alignment) {
        self.segmentWidth = SegmentNode.thickness
        self.segmentLength = SegmentNode.length
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
