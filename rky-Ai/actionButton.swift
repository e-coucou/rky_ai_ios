//
//  actionButton.swift
//  rky-Ai
//
//  Created by Eric PLAIDY on 03/08/2016.
//  Copyright © 2016 eCoucou. All rights reserved.
//

import UIKit

@IBDesignable class actionButton: UIButton {
    @IBInspectable var fillColor: UIColor = UIColor.blueColor()
    @IBInspectable var numButton:UInt = 1
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(ovalInRect: rect)
        fillColor.setFill()
        path.fill()
        
        let h = rect.height
        let w = rect.width
        let color:UIColor = UIColor.blueColor()

        //set up the width and height variables
        //for the horizontal stroke
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        //create the path
        let plusPath = UIBezierPath()
        
        //set the path's line width to the height of the stroke
        plusPath.lineWidth = plusHeight
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        plusPath.moveToPoint(CGPoint(
            x:bounds.width/2 - plusWidth/2,
            y:bounds.height/2))
        
        //add a point to the path at the end of the stroke
        plusPath.addLineToPoint(CGPoint(
            x:bounds.width/2 + plusWidth/2,
            y:bounds.height/2))
        
        switch numButton {
        case 0:
            let drect = CGRect(x: (w * 0.4),y: (h * 0.4),width: (w * 0.2),height: (h * 0.2))
            let centerpath = UIBezierPath(ovalInRect: drect)
            color.set()
            centerpath.stroke()
            centerpath.fill()
        case 1:
            //Vertical Line
            //move to the start of the vertical stroke
            plusPath.moveToPoint(CGPoint(
                x:bounds.width/2 + 0.5,
                y:bounds.height/2 - plusWidth/2 + 0.5))
            
            //add the end point to the vertical stroke
            plusPath.addLineToPoint(CGPoint(
                x:bounds.width/2 + 0.5,
                y:bounds.height/2 + plusWidth/2 + 0.5))
        default:
            print("!")
        }
        
        //set the stroke color
        UIColor.whiteColor().setStroke()
        
        //draw the stroke
        plusPath.stroke()
    }

}