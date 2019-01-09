/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

protocol FunctionManagerProtocol {

    static var defaultValueForUndefinedFunction: Double { get set }

    func isIdempotent(tag: String) -> Bool

    func function(tag: String) -> Function?

    func functions() -> [Function]

    func value(tag: String, firstParameter: AnyObject?, secondParameter: AnyObject?, spriteObject: SpriteObject) -> AnyObject

    func formulaEditorItems() -> [FormulaEditorItem]

    func exists(tag: String) -> Bool

    // TODO: make instance method
    static func requiredResource(tag: String) -> ResourceType

    // TODO: make instance method
    static func name(tag: String) -> String?
}
