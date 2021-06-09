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
    var focusSquare = FocusSquare()
    let coachingOverlay = ARCoachingOverlayView()
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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        //sceneView.allowsCameraControl = true
        //sceneView.debugOptions = [.showFeaturePoints]
       
        addButton.isHidden = true
        //        let bottomNode = BottomNode()
        //        //y方向scale设置为零后，hitTest捕捉不到节点
        //        //bottomNode.scale = SCNVector3(1.5, 0, 1.5)
        //        bottomNode.position = SCNVector3(0, -0.2, -0.3)
        //        sceneView.scene.rootNode.addChildNode(bottomNode)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuratio
        
        // Run the view's session
        sceneView.session.run(self.arSessionConfiguration)
        sceneView.scene.rootNode.addChildNode(focusSquare)
        self.virtualObjectInteraction.current = nil
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
   
    @IBAction func addButton(_ sender: UIButton) {
        self.modelNode?.removeFromParentNode()
        
        //获取模型场景
        //SCNNode
        let cupScene = SCNScene(named: "art.scnassets/cup/cup.scn")
        //let cupScene = SCNScene(named: "art.scnassets/chair/chair.scn")
        //场景中第一个节点
        guard let cupNode = cupScene?.rootNode.childNodes.first else {
            return
        }
        self.nodeArray.append(cupNode)
        
        
        let modelNode = ModelNode()
        self.modelNode = modelNode
        //设置父节点的位置为捕捉锚点的位置中心
        modelNode.position = SCNVector3(planeAnchor!.center.x,0,planeAnchor!.center.z)
        print("modelNode",modelNode.worldPosition,self.planeNode?.worldPosition)
        self.planeNode!.addChildNode(modelNode)
        self.virtualObjectInteraction.currentAngleY = 0.0
        self.rotateCenter = self.modelNode
        //3d图上看节点plate宽度0.155，可以遍历节点找到plate节点，获取大小
        let plateWidth = cupNode.childNode(withName: "plate", recursively: false)?.width()
//        let plateWidth = cupNode.width()
//        let plateLength = cupNode.length()
        
        let bottomNodeWidth = plateWidth ?? 0.155
        let bottomNode = BottomNode(xwidth: (CGFloat(self.nodeArray.count) * bottomNodeWidth), zlength: bottomNodeWidth, segmentWidth: RotateNode.size)
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
    
    @IBAction func resetAction(_ sender: Any) {
        //所有参数置空
        self.planeNode?.removeFromParentNode()
        self.planeNode = nil
        self.planeAnchor = nil
        self.nodeArray.removeAll()
        self.modelNode = nil
        self.movedNode = nil
        self.rotateCenter = nil
        self.rotateNode = nil
        self.virtualObjectInteraction.currentAngleY = 0.0
        self.addButton.isHidden = true
        sceneView.session.run(self.arSessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    @IBAction func reduce(_ sender: Any) {
        if self.nodeArray.count > 0 {
            self.nodeArray.removeLast()
            //重新排列
            self.modelNode?.removeFromParentNode()
            
            
        }
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.virtualObjectInteraction.touchesBegan(touches, with: event)
        
    }
   
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
            return
        } else {
            focusSquare.unhide()
        }
        
        // 当ARKit出于良好检测状态时进行射线检测
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
            let query = sceneView.getRaycastQuery(),
            let result = sceneView.castRay(for: query).first {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera)
        } else {
         
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
        }
    }
    
    
}

extension SCNNode {
    func width() -> CGFloat {
        return CGFloat(boundingBox.max.x - boundingBox.min.x)
    }
    func length() -> CGFloat {
        return CGFloat(boundingBox.max.z - boundingBox.min.z)
    }
    
}
extension ARSCNView {
   
   func unprojectPoint(_ point: SIMD3<Float>) -> SIMD3<Float> {
       return SIMD3<Float>(unprojectPoint(SCNVector3(point)))
   }
   
   // - Tag: 发出射线
   func castRay(for query: ARRaycastQuery) -> [ARRaycastResult] {
       return session.raycast(query)
   }

   // - Tag: 得到射线返回信息
   func getRaycastQuery(for alignment: ARRaycastQuery.TargetAlignment = .any) -> ARRaycastQuery? {
       return raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: alignment)
   }
   
   var screenCenter: CGPoint {
       return CGPoint(x: bounds.midX, y: bounds.midY)
   }
}
