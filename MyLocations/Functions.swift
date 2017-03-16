//
//  Functions.swift
//  MyLocations
//
//  Created by Yixin Xue on 3/2/17.
//  Copyright © 2017 Yixin Xue. All rights reserved.
//

import Foundation
import Dispatch

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    //The annotation @escaping is necessary for closures that are not performed immediately, 
    //so that Swift knows that it should hold on to this closure for a while.
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}
