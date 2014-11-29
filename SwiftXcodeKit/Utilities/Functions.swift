/*
 * The sources in the "XcodeKit" directory are based on the Ruby project Xcoder.
 *
 * Copyright (c) 2012 cisimple
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

internal func doesArrayContain<ValueType: Equatable>(whole: [ValueType], #value: ValueType) -> Bool {
    // By definition, an empty array does not contain any value.
    if whole.count == 0 {
        return false
    }
    
    let filtered = whole.filter { $0 == value }
    return filtered.count != 0
}

internal extension Array {
    internal func select(predicate: (T) -> (Bool)) -> [T] {
        var retval = [T]()
        
        for obj in self {
            if predicate(obj) {
                retval.append(obj)
            }
        }
        
        return retval
    }
    
    internal func reject(predicate: (T) -> (Bool)) -> [T] {
        var retval = [T]()
        
        for obj in self {
            if !predicate(obj) {
                retval.append(obj)
            }
        }
        
        return retval
    }
}
