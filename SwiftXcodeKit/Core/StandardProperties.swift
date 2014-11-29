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

public final class StandardPropertiesClass {
    public let ProductName = "PRODUCT_NAME"
    public let SupportedPlatforms = "SUPPORTED_PLATFORMS"
    public let PrecompilePrefixHeader = "GCC_PRECOMPILE_PREFIX_HEADER"
    public let PrefixHeaderPath = "GCC_PREFIX_HEADER"
    public let BundleInfoPropertyListPath = "INFOPLIST_FILE"
    public let WrapperExtension = "WRAPPER_EXTENSION"
    public let TargetedDeviceFamily = "TARGETED_DEVICE_FAMILY"
    public let SDKRoot = "SDKROOT"
    public let OtherCFlags = "OTHER_CFLAGS"
    public let CLanguageStandard = "GCC_C_LANGUAGE_STANDARD"
    public let AlwaysSearchUserPaths = "ALWAYS_SEARCH_USER_PATHS"
    public let GCCVersion = "GCC_VERSION"
    public let Architectures = "ARCHS"
    public let WarnAboutMissingPrototypes = "GCC_WARN_ABOUT_MISSING_PROTOTYPES"
    public let WarnAboutReturnTypes = "GCC_WARN_ABOUT_RETURN_TYPE"
    public let CodeSigningIdentity = "CODE_SIGN_IDENTITY"
    public let ValidateProduct = "VALIDATE_PRODUCT"
    public let iOSDeploymentTarget = "IPHONEOS_DEPLOYMENT_TARGET"
    public let StripWhileCopying = "COPY_PHASE_STRIP"
    public let OtherLinkerFlags = "OTHER_LDFLAGS"
    public let EnableDeadCodeStripping = "DEAD_CODE_STRIPPING"
    public let DebuggingInformationFormat = "DEBUG_INFORMATION_FORMAT"
    public let EnableObjCExceptions = "GCC_ENABLE_OBJC_EXCEPTIONS"
    public let GenerateDebuggingSymbols = "GCC_GENERATE_DEBUGGING_SYMBOLS"
    public let LinkWithStandardLibraries = "LINK_WITH_STANDARD_LIBRARIES"
    public let InstallPath = "INSTALL_PATH"
    public let ObjectType = "MACH_O_TYPE"
    public let OSXDeploymentTarget = "MACOSX_DEPLOYMENT_TARGET"
    public let ValidArchitectures = "VALID_ARCHS"
    public let UserHeaderSearchPaths = "USER_HEADER_SEARCH_PATHS"
}

public let StandardProperties = StandardPropertiesClass()
