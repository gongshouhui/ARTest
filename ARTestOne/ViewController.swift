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
    
    @IBOutlet weak var reduceOne: UIButton!
    @IBOutlet weak var addone: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var focusSquare = FocusSquare()
    let coachingOverlay = ARCoachingOverlayView()
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, viewController: self)
    
    //取hitTest命中的节点
    //当前可操作场景
    var currentGraph: GraphInfo?
    
    //当前空间存在的场景
    var virtualObjectArray = [GraphInfo]()
    
    //随着相机移动更新新节点
    var currentPlaneNode: SCNNode?
    //随着相机移动更新的新平面锚点
    var currentPlaneAnchor: ARPlaneAnchor?
    
    
    
    
    
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
        //sceneView.debugOptions
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
    
    //添加新的地方
    @IBAction func addButton(_ sender: UIButton) {
        let tapLocation = sceneView.screenCenter
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if !hitTest.isEmpty {
            let hitTestResult = hitTest.first!
            
            let graph = GraphInfo()
            let rayPlaneNode = SCNNode()
            rayPlaneNode.position = SCNVector3(x: hitTestResult.worldTransform.columns.3.x,
                                               y: hitTestResult.worldTransform.columns.3.y,
                                               z: hitTestResult.worldTransform.columns.3.z)
            self.sceneView.scene.rootNode.addChildNode(rayPlaneNode)
            graph.planeNode = rayPlaneNode
            graph.planeAnchor = hitTestResult.anchor as? ARPlaneAnchor
            graph.addVirualObject()
            self.virtualObjectArray.append(graph)
            self.currentGraph = graph
            
            
            
        } else {
            let alertView = UIAlertController.init(title: "提示", message: "未识别平面请等待", preferredStyle: .alert)

                let alert = UIAlertAction.init(title: "确定", style: .destructive) { (UIAlertAction) in
                              print("确定按钮点击")
                }
                let cancleAlert = UIAlertAction.init(title: "取消", style: .cancel) { (UIAlertAction) in
                    
                    print("点击取消按钮")
                }
                alertView.addAction(cancleAlert)

                alertView.addAction(alert);

                self.present(alertView, animated: true, completion: nil)
        }
        
        //
        //        guard let query = sceneView.getRaycastQuery() else {
        //            return
        //        }
        //
        //        guard let result = sceneView.castRay(for: query).first else {
        //            return
        //        }
        //        guard let rayplaneAnchor = result.anchor as? ARPlaneAnchor  else {
        //            return
        //        }
        //       print("rayplaneAnchor",rayplaneAnchor)
        //        if self.currentPlaneAnchor != nil {
        //            let graph = GraphInfo()
        //            //let rayPlaneNode = SCNNode()
        //            //rayPlaneNode.position = SCNVector3(rayplaneAnchor.center.x, rayplaneAnchor.center.y, rayplaneAnchor.center.z)
        //            //self.sceneView.scene.rootNode.addChildNode(rayPlaneNode)
        //            currentPlaneNode?.position = SCNVector3(rayplaneAnchor.center.x, 0, rayplaneAnchor.center.y)
        //            graph.planeNode = currentPlaneNode
        //            graph.planeAnchor = rayplaneAnchor
        //            graph.addVirualObject()
        //            self.virtualObjectArray.append(graph)
        //            self.currentGraph = graph
        //
        //        }
        
        
    }
    @IBAction func addOne() {
        
        
        self.currentGraph?.addVirualObject()
        
        
    }
    @IBAction func reduce(_ sender: Any) {
        self.currentGraph?.reduceVirualObject()
    }
    
    
    @IBAction func resetAction(_ sender: Any) {
        //所有参数置空
        self.currentGraph = nil
        self.virtualObjectArray.removeAll()
        sceneView.session.run(self.arSessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
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
