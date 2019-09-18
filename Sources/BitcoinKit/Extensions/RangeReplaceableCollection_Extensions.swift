//
//  RangeReplaceableCollection_Extensions.swift
//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
import Foundation

extension RangeReplaceableCollection {

    mutating func prepend(element: Element, toLength expectedLength: Int?) {
        self = prepending(element: element, toLength: expectedLength)
    }

    func prepending(element: Element, toLength expectedLength: Int?) -> Self {
        guard let expectedLength = expectedLength else {
            return self
        }
        var modified = self
        while modified.count < expectedLength {
            modified = [element] + modified
        }
        return modified
    }

    mutating func append(element: Element, toLength expectedLength: Int?) {
        self = appending(element: element, toLength: expectedLength)
    }

    func appending(element: Element, toLength expectedLength: Int?) -> Self {
        guard let expectedLength = expectedLength else {
            return self
        }
        var modified = self
        while modified.count < expectedLength {
            modified.append(element)
        }
        return modified
    }
}
