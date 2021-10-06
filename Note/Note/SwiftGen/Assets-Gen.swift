// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let icDownAddNote = ImageAsset(name: "ic_downAddNote")
  internal static let icUpAddNote = ImageAsset(name: "ic_upAddNote")
  internal static let appBg = ColorAsset(name: "AppBg")
  internal static let colorApp = ColorAsset(name: "ColorApp")
  internal static let disableHome = ColorAsset(name: "DisableHome")
  internal static let navigationBar = ColorAsset(name: "NavigationBar")
  internal static let textColorApp = ColorAsset(name: "TextColorApp")
  internal static let viewLine = ColorAsset(name: "ViewLine")
  internal static let icCheckbox = ImageAsset(name: "ic_checkbox")
  internal static let icUncheck = ImageAsset(name: "ic_uncheck")
  internal static let icChecklistDD = ImageAsset(name: "ic_checklistDD")
  internal static let icDrawDD = ImageAsset(name: "ic_drawDD")
  internal static let icPhotoDD = ImageAsset(name: "ic_photoDD")
  internal static let icTextDD = ImageAsset(name: "ic_textDD")
  internal static let icVideoDD = ImageAsset(name: "ic_videoDD")
  internal static let icHome = ImageAsset(name: "ic_home")
  internal static let icMenu = ImageAsset(name: "ic_menu")
  internal static let icClose = ImageAsset(name: "ic_close")
  internal static let icDone = ImageAsset(name: "ic_done")
  internal static let icExport = ImageAsset(name: "ic_export")
  internal static let icHideKeyboard = ImageAsset(name: "ic_hideKeyboard")
  internal static let icKeyboard = ImageAsset(name: "ic_keyboard")
  internal static let icPickColor = ImageAsset(name: "ic_pickColor")
  internal static let icPin = ImageAsset(name: "ic_pin")
  internal static let icReminder = ImageAsset(name: "ic_reminder")
  internal static let icSetupcolor = ImageAsset(name: "ic_setupcolor")
  internal static let icText = ImageAsset(name: "ic_text")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = Color(asset: self)

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
