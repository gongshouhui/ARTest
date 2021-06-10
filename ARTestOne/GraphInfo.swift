//
//  GraphInfo.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/6/10.
//

import Foundation
import SceneKit
import ARKit
class GraphInfo {
    
    var virtualObject: VirtualObject?
    //记录当前是否需要移动
    var movedNode: VirtualObject?
    
    
    var rotateNode: RotateNode?
    var planeNode: SCNNode?
    var planeAnchor: ARPlaneAnchor?
    var nodeArray = [SCNNode]()
    //旋转相关
   var currentAngleY: CGFloat = 0.0
    
    func addVirualObject() {
        
        //获取模型场景
        //SCNNode
        let cupScene = SCNScene(named: "art.scnassets/cup/cup.scn")
        //let cupScene = SCNScene(named: "art.scnassets/chair/chair.scn")
        //场景中第一个节点
        guard let cupNode = cupScene?.rootNode.childNodes.first else {
            return
        }
        self.nodeArray.append(cupNode)
        self.placeModel()
    }
    func reduceVirualObject()  {
        if self.nodeArray.count > 1 {
            self.nodeArray.removeLast()
        }
        self.placeModel()
    }
    func placeModel() {
        guard self.nodeArray.count > 0 else {
            return
        }
        
        self.virtualObject?.removeFromParentNode()
     
        let modelNode = VirtualObject()
        self.virtualObject = modelNode
        //设置父节点的位置为捕捉锚点的位置中心
        modelNode.position = SCNVector3(planeAnchor!.center.x,0,planeAnchor!.center.z)
        self.planeNode!.addChildNode(modelNode)
        self.currentAngleY = 0.0
        //3d图上看节点plate宽度0.155，可以遍历节点找到plate节点，获取大小
        let cupNode = self.nodeArray.first!
        let plateWidth = cupNode.childNode(withName: "plate", recursively: false)?.width()
//        let plateWidth = cupNode.width()
//        let plateLength = cupNode.length()
        
        let bottomNodeWidth = plateWidth ?? 0.155
        let bottomNode = BottomNode(xwidth: (CGFloat(self.nodeArray.count) * bottomNodeWidth), zlength: bottomNodeWidth, segmentWidth: RotateNode.size)
        bottomNode.isHidden = true
        bottomNode.position = SCNVector3(0, -0.03,0)
        modelNode.addChildNode(bottomNode)
        
        for (index,node) in self.nodeArray.enumerated() {
            if self.nodeArray.count % 2 == 1 {
                node.position = SCNVector3(CGFloat(index - self.nodeArray.count/2) * bottomNodeWidth, 0, 0)
            } else {
                node.position = SCNVector3(bottomNodeWidth/2 + CGFloat(index - self.nodeArray.count/2) * bottomNodeWidth, 0, 0)
            }
            
            
            modelNode.addChildNode(node)
        }
    }
}
