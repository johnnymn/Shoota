import SpriteKit
import ARKit

class Scene: SKScene {
  // This label shows the player how
  // many targets are currently visible.
  let remainingLabel = SKLabelNode()

  // Used to create new targets
  // every 2 seconds.
  var timer: Timer!

  // How many targets have been created.
  var targetsCreated = 0

  // How many targets are currently visible.
  var targetCount = 0 {
    // Update the remainingLabel automatically
    // after this property is set to a new value.
    didSet {
      remainingLabel.text = "Remaining: \(targetCount)"
    }
  }

  override func didMove(to view: SKView) {
    remainingLabel.fontSize = 36
    remainingLabel.fontName = "AmericanTypewriter"
    remainingLabel.color = .white
    // The remainingLabel needs to be positioned
    // statically on the screen because its part
    // of the HUD.
    remainingLabel.position = CGPoint(x: frame.midX, y: frame.midY + 120)
    addChild(remainingLabel)
    targetCount = 0

    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
      self.createTarget()
    }
  }

  /// Creates new targets and places them on the screen.
  func createTarget() {
    // End the game if we created
    // all the targets already.
    if targetsCreated == 20 {
      timer?.invalidate()
      timer = nil
      return
    }

    targetsCreated += 1
    targetCount += 1

    // Find the scene view.
    guard let sceneView = view as? ARSKView else {
      return
    }

    // Create random x rotation.
    let xRotation = simd_float4x4(
            SCNMatrix4MakeRotation(
                    Float.pi * 2 * Float.random(in: 0...1), 1, 0, 0))
    // Create random y rotation.
    let yRotation = simd_float4x4(
            SCNMatrix4MakeRotation(
                    Float.pi * 2 * Float.random(in: 0...1), 0, 1, 0))
    // Combine them.
    let rotation = simd_mul(xRotation, yRotation)
    // Move forward 1.5m into the screen.
    var translation = matrix_identity_float4x4
    translation.columns.3.z = -1.5
    // Combine the translation and rotation.
    let transform = simd_mul(rotation, translation)

    // Create an anchor at the calculated position.
    let anchor = ARAnchor(transform: transform)
    sceneView.session.add(anchor: anchor)
  }
}
