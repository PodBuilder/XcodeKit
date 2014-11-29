//
//  Errors.swift
//  PodBuilder
//
//  Created by William Kent on 9/1/14.
//  Copyright (c) 2014 William Kent. All rights reserved.
//

import Foundation

public final class ErrorsClass {
    public let unspecifiedInternalError = 1
    public let syntaxErrorInPBXProject = 2
}

public let Errors = ErrorsClass()
public let ErrorDomain = "XcodeProject"
