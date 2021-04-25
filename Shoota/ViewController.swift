import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {

  @IBOutlet var sceneView: ARSKView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    // Show statistics such as fps and node count
    sceneView.showsFPS = true
    sceneView.showsNodeCount = true

    // Load the SKScene from 'Scene.sks'
    if let scene = SKScene(fileNamed: "Scene") {
      sceneView.presentScene(scene)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = AROrientationTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }

  func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
    return SKSpriteNode(imageNamed: "target")
  }
}
