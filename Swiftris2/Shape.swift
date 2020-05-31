//
//  Shape.swift
//  Swiftris2
//
//  Created by Elliott Barnes on 2020-05-30.
//  Copyright © 2020 Barnes. All rights reserved.
//

import Foundation
import SpriteKit

let numOrientations: UInt32 = 4

enum Orientation: Int, CustomStringConvertible {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue: Int(arc4random_uniform(numOrientations)))!
    }
    
    static func rotate(orientation: Orientation, clockWise: Bool) -> Orientation{
        
        var rotated = orientation.rawValue + (clockWise ? 1 : -1)
        
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue: rotated)!
        
    }
}

// the number of shape varieties

let NumShapeTypes: UInt32 = 7

// shape indexes
let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible {
    
    // the color of the shape
    let color: BlockColor
    
    // the blocks comprising the shape
    var blocks = Array<Block> ()
    
    // the current orientation of the shape
    var orientation: Orientation
    
    //the column & row representing the shape's anchor point
    var column, row : Int
    
    // Overrides
    
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>]{
        return [:]
    }
    
    var bottomBlocksForOrientations: [Orientation: Array<Block>]{
        return [:]
    }
    
    var bottomBlocks: Array<Block> {
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
            return []
        }
        return bottomBlocks
    }
    
    // hashable
    
    var hashValue: Int {
        return blocks.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
    
    // custom string convertible
    var description: String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column: Int, row: Int, color: BlockColor, orientation: Orientation) {
        self.color = color
        self.row = row
        self.column = column
        self.orientation = orientation
        initializeBlocks()
    }
    
    convenience init(column: Int, row: Int) {
        self.init(column: column, row: row, color: BlockColor.random(), orientation: Orientation.random())
    }
    final func initializeBlocks() {
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
    
    blocks = blockRowColumnTranslations.map { (diff) -> Block in
                 return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
             }
    }
    
    final func rotateBlocks(orientation: Orientation) {
             guard let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else {
                 return
             }
    // #1
             for (idx, diff) in blockRowColumnTranslation.enumerated() {
                 blocks[idx].column = column + diff.columnDiff
                 blocks[idx].row = row + diff.rowDiff
             }
         }

         final func lowerShapeByOneRow() {
            shiftBy(columns: 0, rows:1)
         }

    // #2
         final func shiftBy(columns: Int, rows: Int) {
             self.column += columns
             self.row += rows
             for block in blocks {
                 block.column += columns
                 block.row += rows
             }
         }

    // #3
         final func moveTo(column: Int, row:Int) {
             self.column = column
             self.row = row
            rotateBlocks(orientation: orientation)
         }

         final class func random(startingColumn:Int, startingRow:Int) -> Shape {
             switch Int(arc4random_uniform(NumShapeTypes)) {
    // #4
             case 0:
                 return SquareShape(column:startingColumn, row:startingRow)
             case 1:
                 return LineShape(column:startingColumn, row:startingRow)
             case 2:
                 return TShape(column:startingColumn, row:startingRow)
             case 3:
                 return LShape(column:startingColumn, row:startingRow)
             case 4:
                 return JShape(column:startingColumn, row:startingRow)
             case 5:
                 return SShape(column:startingColumn, row:startingRow)
             default:
                 return ZShape(column:startingColumn, row:startingRow)
             }
         }
}

func ==(lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}


