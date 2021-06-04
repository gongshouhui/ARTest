//
//  ViewController.swift
//  ARTestOne
//
//  Created by gongshouhui on 2021/5/19.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    var planeAnchor: ARPlaneAnchor?
    var planeNode: SCNNode?
    var nodeArray = [SCNNode]()
    
    
    var c1: SCNVector3?
    var p1: SCNVector3?
    var current: SCNVector3?
    var lastPoint: SCNVector3?
    
    
    
    
    
    //取hitTest命中的节点
    var movedNode: SCNNode?
    var rotateNode: RotateNode?
    private var newAngleY: CGFloat = 0.0
    private var currentAngleY: CGFloat = 0.0
    
    
    
    lazy var arSessionConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        return configuration
    }()
    lazy var cupScene: SCNScene? = {
        let cupScene = SCNScene(named: "art.scnassets/cup/cup.scn")
        return cupScene
    }()
    lazy var bottomNode: BottomNode = {
        let bottomNode = BottomNode()
        return bottomNode
    }()
    
    
    @IBAction func addButton(_ sender: UIButton) {
        
        //获取模型场景
        SCNNode
        let cupNode = self.cupScene?.rootNode.childNodes.first
        cupNode?.position = SCNVector3(self.planeAnchor!.center.x, 0, self.planeAnchor!.center.z)
        //创建底座，添加到cup节点上面
        self.nodeArray.append(cupNode!)
        
        
        self.bottomNode.scale = SCNVector3(3, 1, 3)
        self.bottomNode.position = SCNVector3(0, -0.03,0)
        let modelNode = ModelNode()
        modelNode.position = SCNVector3(0,0,0)
        modelNode.addChildNode(cupNode!)
        modelNode.addChildNode(self.bottomNode)
        self.planeNode!.addChildNode(modelNode)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        //sceneView.allowsCameraControl = true
        addButton.isHidden = true
        
        
        //scnview 添加手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(gesture:)))
        sceneView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(gesture:)))
        sceneView.addGestureRecognizer(tap)
        
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
    
    //点击添加节点
    @objc func tapHandle(gesture: UITapGestureRecognizer)  {
        
        //        let hitTest = self.sceneView.hitTest(gesture.location(in: self.sceneView), types: .estimatedHorizontalPlane)
        //
        //        guard results.count > 0 else{
        //               return
        //           }
        //        for result in results {
        //            if let node = result.node as? BottomNode {
        //                print(node.name ?? "rr")
        //            }
        //            print(result.node.name!)
        //        }
    }
    @objc func panHandle(gesture: UIPanGestureRecognizer)  {
        
        switch gesture.state {
        case .began:
            let arResults = self.sceneView.hitTest(gesture.location(in: sceneView), types: .existingPlane)
            //获取点的世界坐标
            let currentSimd4 = arResults.last?.worldTransform
            
            let currentVector = SCNVector3(currentSimd4!.columns.3.x, currentSimd4!.columns.3.y, currentSimd4!.columns.3.z)
            p1 = currentVector
            
            
            let SCNHitResults:[SCNHitTestResult] = (self.sceneView?.hitTest(gesture.location(in: self.sceneView), options: nil))!
            guard SCNHitResults.count > 0 else{
                return
            }
            if let node = SCNHitResults.first?.node as? RotateNode {//命中旋转小节点,做旋转
                
                if self.rotateNode == nil {//一次拖动只取第一次命中的节点
                    self.rotateNode = node
                }
                
                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow_red")
            } else {
                if let node = SCNHitResults.first?.node {
                    movedNode = getModelNode(node: node)
                }
            }
            break
        case .changed:
            //旋转 ,首先选中旋转小节点
            if self.rotateNode != nil { //根据坐标计算角度
                
                //旋转
                
                let arResults = self.sceneView.hitTest(gesture.location(in: sceneView), types: .existingPlane)
                //获取点的世界坐标
                let currentSimd4 = arResults.last?.worldTransform
                
                let currentVector = SCNVector3(currentSimd4!.columns.3.x, currentSimd4!.columns.3.y, currentSimd4!.columns.3.z)
                current = currentVector
                if lastPoint != nil {
                    let angel = getAngle(from: lastPoint!, to: current!, yuandian: planeNode?.worldPosition ?? SCNVector3(0.0, 0.0, 0.0))
                    print("angleg",angel)
                    let parentNode = self.getModelNode(node: self.rotateNode!)
                    //let transtion = gesture.translation(in: gesture.view)
                    let clockwise = isClockwise(yuandian: planeNode?.worldPosition ?? SCNVector3(0.0, 0.0, 0.0), from: lastPoint!, to: current!)
                    print("clockwise",clockwise)
                    if  !clockwise {
                        self.newAngleY =  angel
                        self.newAngleY += self.currentAngleY
                        
                        
                        let rotationAcrion =  SCNAction.rotateBy(x: 0, y: angel, z: 0, duration: 0)
                        parentNode!.runAction(rotationAcrion)
                        
                        
                    } else {
                        self.newAngleY =  -angel
                        self.newAngleY += self.currentAngleY
                        //                        let rotationAcrion =  SCNAction.rotateBy(x: 0, y: -angel, z: 0, duration: 0)
                        //                        parentNode!.runAction(rotationAcrion)
                    }
                    parentNode?.eulerAngles.y = Float(self.newAngleY)
                }
                
                lastPoint = current
                self.currentAngleY = self.newAngleY
                //旋转和移动只有一个生效
                return
            }
            
            //            //旋转 ,首先选中旋转小节点
            //                if self.rotateNode != nil { //可根据拖动距离旋转
            //                    let parentNode = self.rotateNode?.parent?.parent;
            //                    let transtion = gesture.translation(in: gesture.view)
            //                    self.newAngleY =  CGFloat(transtion.x) * (CGFloat) (Double.pi)/180
            //                    self.newAngleY += self.currentAngleY
            //                    parentNode?.eulerAngles.y = Float(self.newAngleY)
            //                    //旋转和移动只有一个生效
            //                    return
            //                }
            if self.movedNode != nil {//做移动动作
                
                let ARHitResults: [ARHitTestResult] = self.sceneView.hitTest(gesture.location(in: self.sceneView), types: .existingPlane)
                
                let lastResult = ARHitResults.last
                let simd4 = lastResult!.worldTransform
                let vector = SCNVector3(simd4.columns.3.x, simd4.columns.3.y, simd4.columns.3.z)
                movedNode?.worldPosition = vector;
            }
            
        case .ended:
            
            //旋转完颜色恢复
            if self.rotateNode != nil {
                self.rotateNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow")
                self.rotateNode = nil;
            }
            self.movedNode = nil
            
        default:
            break
        }
        
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            self.currentAngleY = self.newAngleY
            lastPoint = nil
        }
    }
    //如果有父节点返回父节点,没有返回自己
    private func getModelNode(node: SCNNode) -> ModelNode? {
        if let modelNode = node as? ModelNode {
            return modelNode
        }
        guard let parentNode = node.parent else {
            return nil
        }
        return getModelNode(node: parentNode)
    }
    private func isClockwise(yuandian p1: SCNVector3,from p2: SCNVector3,to p3: SCNVector3) -> Bool {
        //        p1=(x1,y1), p2=(x2,y2), p3=(x3,y3) 求向量 p12=(x2-x1,y2-y1) p23=(x3-x2,y3-y2) 则当 p12 与 p23 的叉乘（向量积） p12 x p23 = (x2-x1)*(y3-y2)-(y2-y1)*(x3-x2)
        let p12 = (p2.x - p1.x,p2.z - p1.z)
        let p23 = (p3.x - p2.x,p3.z - p2.z)
        let value = p12.0 * p23.1 - p12.1 * p23.0
        return value > 0
    }
    private func getAngle(from: SCNVector3,to: SCNVector3,yuandian: SCNVector3) -> CGFloat {
        let x1 = from.x - yuandian.x
        let z1 = from.z - yuandian.z
        let x2 = to.x - yuandian.x
        let z2 = to.z - yuandian.z
        let x = x1 * x2 + z1 * z2
        let z = x1 * z2 - x2 * z1
        let angel = acos(x/sqrt(x * x + z * z))
        print("jisuan",x1,z1,x2,z2,x,z,angel)
        return CGFloat(angel)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuratio
        
        // Run the view's session
        sceneView.session.run(self.arSessionConfiguration)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first;
        let firstResult = sceneView.hitTest((touch?.location(in: sceneView))!, options: nil).first;
        if let node = firstResult?.node as? RotateNode {
            
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("dddd")
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        self.planeNode = node
        self.planeAnchor = planeAnchor
        DispatchQueue.main.async {
            self.addButton.isHidden = false
        }
        
        
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
