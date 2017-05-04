//
//  GameScene.swift
//  Phi Squad Game
//
//  Created by Joseph DeYoung on 3/14/17.
//  Copyright © 2017 Joseph DeYoung. All rights reserved.
//

import SpriteKit
import GameplayKit

extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "Commando1")
    let deece = SKSpriteNode(imageNamed: "DC-17m")
    let e5 = SKSpriteNode(imageNamed: "E5BlasterRifle")
    var highScore:CGFloat = 0
    var playerName:String = "Name"
    let playableRect:CGRect = CGRect(x: 0, y: 0, width: 1334, height: 750)
    var velocity = CGPoint.zero
    var dt: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    var lastTouchLocation: CGPoint = CGPoint.zero
    let warningLabel = SKLabelNode(fontNamed: "Times New Roman")
    
    func readPropertyList(){
        var format = PropertyListSerialization.PropertyListFormat.xml //format of the property list
        var plistData:[String:AnyObject] = [:]  //our data
        let plistPath:String? = Bundle.main.path(forResource: "data", ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do{
            plistData = try PropertyListSerialization.propertyList(from: plistXML,
                                                                   options: .mutableContainersAndLeaves,
                                                                   format: &format)
                as! [String:AnyObject]
            highScore = plistData["High Score"] as! CGFloat
            playerName = plistData["Name"] as! String
        }
        catch{
            print("Error reading plist: \(error), format: \(format)")
        }
    }

    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        backgroundColor = SKColor.black
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            addChild(background)
        }
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                },
                SKAction.wait(forDuration: 5.0)])))
        
        player.anchorPoint = CGPoint(x: 0.5, y: 0)
        player.texture?.filteringMode = SKTextureFilteringMode.nearest
        player.setScale(15.0)
        player.zPosition = 10
        player.position = CGPoint(x: 1334/2, y: 30)
        addChild(player)
        
        deece.removeFromParent()
        deece.texture?.filteringMode = SKTextureFilteringMode.nearest
        deece.setScale(0.03)
        deece.zPosition = 15
        deece.position = CGPoint(x: -1.5, y: 18.3)
        player.addChild(deece)
        
        readPropertyList()
        print("High Score: \(highScore)")
        //player.xScale = -15
    }
    
    
    /*func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }*/
    
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0 }
        lastUpdateTime = currentTime
        
        move(sprite: player, velocity: velocity)
        
        highScore += 1
        print(highScore)
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        move(sprite:player, velocity: CGPoint(x: touchLocation.x, y: 30))
        lastTouchLocation = touchLocation
    }
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
        
        boundsCheckPlayer()
    }
    
    func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        // 2
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint.zero
        background.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background)
        // 4
        backgroundNode.size = CGSize(
            width: background.size.width,
            height: background.size.height)
        return backgroundNode
    }

    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "Droid1")
        let left = CGPoint(x: -enemy.size.width, y: 30)
        let right = CGPoint(x: size.width + enemy.size.width, y: 30)
        let spawnLeft:Bool = Bool.random()
        enemy.texture?.filteringMode = SKTextureFilteringMode.nearest
        enemy.zPosition = 50
        enemy.anchorPoint = CGPoint(x: 0.5, y: 0)
        enemy.setScale(22)
        enemy.name = "enemy"
        warningLabel.text = "!"
        warningLabel.fontSize = 60
        warningLabel.zPosition = 20
        warningLabel.fontColor = UIColor.red
        let actionMove = SKAction.moveBy(x: (size.width + enemy.size.width), y: 0.0, duration: 5.0)
        let actionRemove = SKAction.removeFromParent()
        e5.removeFromParent()
        e5.texture?.filteringMode = SKTextureFilteringMode.nearest
        e5.setScale(0.0065)
        e5.zPosition = 15
        e5.position = CGPoint(x: 1.3, y: 16.3)
        enemy.addChild(e5)
        if(spawnLeft == true){
            enemy.position = left
            warningLabel.position = CGPoint(x: size.width/2, y: size.height/2)
            addChild(warningLabel)
            run(SKAction.wait(forDuration: 1.0))
            warningLabel.run(actionRemove)
            
            enemy.run(SKAction.sequence([actionMove, actionRemove]))

        } else {
            enemy.position = right
            enemy.xScale = -22
            warningLabel.position = CGPoint(x: 100, y: size.height/2)
            addChild(warningLabel)
            run(SKAction.wait(forDuration: 1.0))
            warningLabel.run(actionRemove)
            let actionMove = SKAction.moveBy(x: (-size.width - enemy.size.width), y: 0.0, duration: 5.0)
            let actionRemove = SKAction.removeFromParent()
            enemy.run(SKAction.sequence([actionMove, actionRemove]))

        }
        
        addChild(enemy)   
    }
    
    func boundsCheckPlayer() {
        let bottomLeft = CGPoint(x: playableRect.minX, y: playableRect.minY)
        let topRight = CGPoint(x: playableRect.maxX, y: playableRect.maxY)
        player.zPosition = 50
        if player.position.x <= bottomLeft.x {
            player.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        if player.position.x >= topRight.x {
            player.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if player.position.y <= bottomLeft.y {
            player.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if player.position.y >= topRight.y {
            player.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }

    
}
