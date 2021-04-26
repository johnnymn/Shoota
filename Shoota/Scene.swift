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

  // The time the game started at.
  let startTime = Date()

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

  // Handle the player touches on the screen.
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }

    // Check if the player hit any targets.
    let location = touch.location(in: self)
    let hit = nodes(at: location)

    // Scale out and fade out the first
    // target in the array of hits.
    if let sprite = hit.first {
      // We want to remove only targets so we check the
      // type of the sprite to avoid running this code
      // on labels, etc.
      if sprite is SKSpriteNode {
        let scaleOut = SKAction.scale(to: 2, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleOut, fadeOut])
        let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
        sprite.run(sequence)
        targetCount -= 1

        // Handle the end of the game.
        if targetsCreated >= 20 && targetCount == 0 {
          gameOver()
        }
      }
    }
  }

  /// Handles the end of the game actions.
  func gameOver() {
    // Remove the label for the remaining targets.
    remainingLabel.removeFromParent()

    // Display the game over image.
    let gameOver = SKSpriteNode(imageNamed: "gameOver")
    addChild(gameOver)

    // Calculate the time it took the player to
    // finish the game and display it on a label.
    let timeTaken = Date().timeIntervalSince(startTime)
    let timeLabel = SKLabelNode(text: "Time taken: \(Int(timeTaken)) seconds")
    timeLabel.fontSize = 36
    timeLabel.fontName = "AmericanTypewriter"
    timeLabel.color = .white
    timeLabel.position = CGPoint(x: frame.midX, y: frame.midY - 120)
    addChild(timeLabel)
  }
}
