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

    @IBOutlet weak var add: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    //捕获的平面节点
    var captureNode: SCNNode!
    var rotateNode: RotateNode?
    var currentAngle: CGFloat = 0.0
    
    
    
    
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
    
    
    @IBAction func add(_ sender: UIButton) {
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/cup/cup.scn")!
//        //创建一个节点
//        let ratoteNode = BottomNode()
//        ratoteNode.position = SCNVector3(0, -0.1, -0.3)
//        // Set the scene to the view
//        sceneView.scene.rootNode.addChildNode(ratoteNode);
//
    //scnview 添加手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panHandle(gesture:)))
        sceneView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandle(gesture:)))
        sceneView.addGestureRecognizer(tap)
        
        
        
        //添加模型

//        let cupScene = SCNScene(named: "art.scnassets/cup/cup.scn")
//        let cupNode = cupScene?.rootNode.childNodes.first
//        cupNode?.position = SCNVector3(0, -0.2, -0.3)
//        sceneView.scene = cupScene!;
////
//        let bottomNode = BottomNode()
//        //y方向scale设置为零后，hitTest捕捉不到节点
//        //bottomNode.scale = SCNVector3(1.5, 0, 1.5)
//        bottomNode.position = SCNVector3(0, -0.2-0.01, -0.3)
//        sceneView.scene.rootNode.addChildNode(bottomNode)
        
        
        
//        let bottomNode = BottomNode()
//        //y方向scale设置为零后，hitTest捕捉不到节点
//        //bottomNode.scale = SCNVector3(1.5, 0, 1.5)
//        bottomNode.position = SCNVector3(0, -0.2, -0.3)
//        sceneView.scene.rootNode.addChildNode(bottomNode)
      
    }
    @objc func tapHandle(gesture: UITapGestureRecognizer)  {
        print("点击了")
        let results:[SCNHitTestResult] = (self.sceneView?.hitTest(gesture.location(in: self.sceneView), options: nil))!
        let hitTest = self.sceneView.hitTest(gesture.location(in: self.sceneView), types: .estimatedHorizontalPlane)
        print(hitTest)
        guard results.count > 0 else{
               return
           }
        for result in results {
            if let node = result.node as? BottomNode {
                print(node.name ?? "rr")
            }
            print(result.node.name!)
        }
    }
    @objc func panHandle(gesture: UIPanGestureRecognizer)  {
      //判断手势状态，
        print("移动点",gesture.location(in: self.sceneView))
        print("手指状态",gesture.state.rawValue)
        
        let results:[SCNHitTestResult] = (self.sceneView?.hitTest(gesture.location(in: self.sceneView), options: nil))!
//        guard results.count > 0 else{
//               return
//           }
        
       
        if let node = results.first?.node as? RotateNode {//命中旋转小节点
            print("状态",gesture.state.rawValue)
            if self.rotateNode == nil {//一次拖动只取第一次命中的节点
                self.rotateNode = node
            }
           
        }
        
        if gesture.state == .began  && self.rotateNode != nil {
            self.rotateNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow_red")
        }
      
        if gesture.state == .ended && self.rotateNode != nil {
            self.rotateNode?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "arrow")
            self.rotateNode = nil;
            
        }
        
        //旋转 ,首先选中旋转小节点
        
        if self.rotateNode != nil { //可根据拖动距离旋转
            let parentNode = self.rotateNode?.parent?.parent;
            let transtion = gesture.translation(in: gesture.view)
            let x: CGFloat = transtion.x
            let y: CGFloat = transtion.y
            let newAngle: CGFloat = x*2*CGFloat(Double.pi)/180
            
            print("旋转角度:" + "\(newAngle)")
            
            var currentAngle: CGFloat = CGFloat(parentNode?.eulerAngles.y ?? 0.0)
            print("当前欧拉角",currentAngle)
            //除以100 是降低旋转灵敏度
            self.currentAngle += newAngle/100
            
            parentNode?.eulerAngles = SCNVector3(0, self.currentAngle, 0)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuratio

        // Run the view's session
        sceneView.session.run(self.arSessionConfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
   

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first;
            let firstResult = sceneView.hitTest((touch?.location(in: sceneView))!, options: nil).first;
        if let node = firstResult?.node as? RotateNode {
            print("touch")
        }
    }
   
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("进入")
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
//        //获取模型场景
//        let cupScene = SCNScene(named: "art.scnassets/cup/cup.scn")
//        let cupNode = cupScene?.rootNode.childNodes.first
//        cupNode?.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//        //创建底座，添加到cup节点上面
//        let bottomNode = BottomNode()
//        bottomNode.scale = SCNVector3(3, 1, 3)
//        bottomNode.position = SCNVector3(0, -0.03,0)
//        cupNode?.addChildNode(bottomNode)
//
//        node.addChildNode(cupNode!)
        
                //获取模型场景
               
        let cupNode = self.cupScene?.rootNode.childNodes.first
                cupNode?.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
                //创建底座，添加到cup节点上面
        self.bottomNode.scale = SCNVector3(3, 1, 3)
        self.bottomNode.position = SCNVector3(0, -0.03,0)
                cupNode?.addChildNode(self.bottomNode)
        if cupNode != nil {
            node.addChildNode(cupNode!)
        }
               
                captureNode = node;
            
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



//override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    let touch = touches.first;
//    let firstResult = sceneView.hitTest((touch?.location(in: sceneView))!, options: nil).first;
//    if let node = firstResult?.node {
//        if node == shipNode || node.parent == shipNode {
//            // 将 shipNode 从sceneView.scene.rootNode坐标系下，转换到sceneView.pointOfView坐标系下
//                           let matrixInPOV = sceneView.scene.rootNode.simdConvertTransform(shipNode.simdTransform, to: sceneView.pointOfView)
//                           // 添加到相机结点下
//                           sceneView.pointOfView?.addChildNode(shipNode)
//                           shipNode.simdTransform = matrixInPOV
//                           shipNode.opacity = 0.5;//半透明
//        }
//    }
//
//
//}
//
//override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    if shipNode.opacity < 1 {//这里偷懒，用透明度做个判断
//        // 将 shipNode 从sceneView.pointOfView坐标系下，转换到sceneView.scene.rootNode坐标系下，传 nil  默认就是 scene.rootNode
//        let matrixInRoot = sceneView.pointOfView!.simdConvertTransform(shipNode.simdTransform, to: nil)
//        // 回到原来的结点下
//        sceneView.scene.rootNode.addChildNode(shipNode)
//        shipNode.simdTransform = matrixInRoot
//        shipNode.opacity = 1;
//    }
//}
