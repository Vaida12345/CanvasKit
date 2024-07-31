//
//  Layer + Init.swift
//  CanvasKit
//
//  Created by Vaida on 7/31/24.
//

import Testing
import Foundation
@testable
import CanvasKit
import Stratum
@testable
import MetalManager


extension Tag {
    @Tag static var layer: Tag
    @Tag static var `init`: Tag
}


@Suite(.tags(.layer, .`init`))
struct Layer_init {
    
    @Test
    func init_from_image() async throws {
        let source = 
    }
    
}
