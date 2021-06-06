//
//  ViewController.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/19.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, viewController: self)
    
    //取hitTest命中的节点
    var modelNode: ModelNode?
    
    //记录当前是否需要移动
    var movedNode: ModelNode?
    //旋转时获取中心的的节点,计算角度用
    var rotateCenter: ModelNode?
    
    var rotateNode: RotateNode?
    var planeNode: SCNNode?
    var planeAnchor: ARPlaneAnchor?
    var nodeArray = [SCNNode]()
    
    
    
    lazy var arSessionConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        return configuration
    }()
   
    
    @IBAction func addButton(_ sender: UIButton) {
        self.modelNode?.removeFromParentNode()
        
        //获取模型场景
        //SCNNode
        let cupScene = SCNScene(named: "art.scnassets/cup/cup.scn")
        //场景中第一个节点
        let cupNode = cupScene?.rootNode.childNodes.first
        self.nodeArray.append(cupNode!)
        
        
        let modelNode = ModelNode()
        self.modelNode = modelNode
        //设置父节点的位置为捕捉锚点的位置中心
        modelNode.position = SCNVector3(planeAnchor!.center.x,0,planeAnchor!.center.z)
        self.planeNode!.addChildNode(modelNode)
        self.virtualObjectInteraction.currentAngleY = 0.0
        self.rotateCenter = self.modelNode
        //3d图上看节点plate宽度0.155，可以遍历节点找到plate节点，获取大小
        let plateWidth: CGFloat = 0.155
        let bottomNode = BottomNode(xwidth: (CGFloat(self.nodeArray.count) * plateWidth), zlength: plateWidth, segmentWidth: RotateNode.size)
       // bottomNode.scale = SCNVector3(3, 1, 3)
        bottomNode.position = SCNVector3(0, -0.03,0)
        
        modelNode.addChildNode(bottomNode)
        
        for (index,node) in self.nodeArray.enumerated() {
            if self.nodeArray.count % 2 == 1 {
                node.position = SCNVector3(CGFloat(index - self.nodeArray.count/2) * plateWidth, 0, 0)
            } else {
                node.position = SCNVector3(plateWidth/2 + CGFloat(index - self.nodeArray.count/2) * plateWidth, 0, 0)
            }
            
            
            modelNode.addChildNode(node)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        //sceneView.allowsCameraControl = true
        addButton.isHidden = true
        //        let bottomNode = BottomNode()
        //        //y方向scale设置为零后，hitTest捕捉不到节点
        //        //bottomNode.scale = SCNVector3(1.5, 0, 1.5)
        //        bottomNode.position = SCNVector3(0, -0.2, -0.3)
        //        sceneView.scene.rootNode.addChildNode(bottomNode)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuratio
        
        // Run the view's session
        sceneView.session.run(self.arSessionConfiguration)
        self.virtualObjectInteraction.current = nil
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.virtualObjectInteraction.touchesBegan(touches, with: event)
        
    }
   

}

extension SCNNode {
    func width() -> Float {
        return boundingBox.max.x - boundingBox.min.x
    }
    func length() -> Float {
        return boundingBox.max.z - boundingBox.min.z
    }
    
}
