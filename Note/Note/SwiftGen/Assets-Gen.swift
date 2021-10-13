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
  internal static let bgColorView = ColorAsset(name: "BgColorView")
  internal static let colorApp = ColorAsset(name: "ColorApp")
  internal static let disableHome = ColorAsset(name: "DisableHome")
  internal static let navigationBar = ColorAsset(name: "NavigationBar")
  internal static let textColorApp = ColorAsset(name: "TextColorApp")
  internal static let viewLine = ColorAsset(name: "ViewLine")
  internal static let viewMoveSegment = ColorAsset(name: "ViewMoveSegment")
  internal static let icCheckbox = ImageAsset(name: "ic_checkbox")
  internal static let icUncheck = ImageAsset(name: "ic_uncheck")
  internal static let icChecklistDD = ImageAsset(name: "ic_checklistDD")
  internal static let icDrawDD = ImageAsset(name: "ic_drawDD")
  internal static let icPhotoDD = ImageAsset(name: "ic_photoDD")
  internal static let icTextDD = ImageAsset(name: "ic_textDD")
  internal static let icVideoDD = ImageAsset(name: "ic_videoDD")
  internal static let icDefaultHome = ImageAsset(name: "ic_defaultHome")
  internal static let icFourView = ImageAsset(name: "ic_four_view")
  internal static let icMoreAction = ImageAsset(name: "ic_moreAction")
  internal static let icSortAscending = ImageAsset(name: "ic_sort_ascending")
  internal static let icSortDescending = ImageAsset(name: "ic_sort_descending")
  internal static let icThreeView = ImageAsset(name: "ic_three_view")
  internal static let icTrash = ImageAsset(name: "ic_trash")
  internal static let icTwoView = ImageAsset(name: "ic_two_view")
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
  internal static let _1 = ImageAsset(name: "1")
  internal static let _10 = ImageAsset(name: "10")
  internal static let _11 = ImageAsset(name: "11")
  internal static let _12 = ImageAsset(name: "12")
  internal static let _13 = ImageAsset(name: "13")
  internal static let _141 = ImageAsset(name: "14-1")
  internal static let _1410 = ImageAsset(name: "14-10")
  internal static let _1411 = ImageAsset(name: "14-11")
  internal static let _1412 = ImageAsset(name: "14-12")
  internal static let _1413 = ImageAsset(name: "14-13")
  internal static let _1414 = ImageAsset(name: "14-14")
  internal static let _1415 = ImageAsset(name: "14-15")
  internal static let _1416 = ImageAsset(name: "14-16")
  internal static let _1417 = ImageAsset(name: "14-17")
  internal static let _1418 = ImageAsset(name: "14-18")
  internal static let _1419 = ImageAsset(name: "14-19")
  internal static let _142 = ImageAsset(name: "14-2")
  internal static let _1420 = ImageAsset(name: "14-20")
  internal static let _1421 = ImageAsset(name: "14-21")
  internal static let _1422 = ImageAsset(name: "14-22")
  internal static let _1423 = ImageAsset(name: "14-23")
  internal static let _1424 = ImageAsset(name: "14-24")
  internal static let _143 = ImageAsset(name: "14-3")
  internal static let _144 = ImageAsset(name: "14-4")
  internal static let _145 = ImageAsset(name: "14-5")
  internal static let _146 = ImageAsset(name: "14-6")
  internal static let _147 = ImageAsset(name: "14-7")
  internal static let _148 = ImageAsset(name: "14-8")
  internal static let _149 = ImageAsset(name: "14-9")
  internal static let _14 = ImageAsset(name: "14")
  internal static let _151 = ImageAsset(name: "15-1")
  internal static let _152 = ImageAsset(name: "15-2")
  internal static let _153 = ImageAsset(name: "15-3")
  internal static let _154 = ImageAsset(name: "15-4")
  internal static let _155 = ImageAsset(name: "15-5")
  internal static let _156 = ImageAsset(name: "15-6")
  internal static let _157 = ImageAsset(name: "15-7")
  internal static let _158 = ImageAsset(name: "15-8")
  internal static let _159 = ImageAsset(name: "15-9")
  internal static let _15 = ImageAsset(name: "15")
  internal static let _2 = ImageAsset(name: "2")
  internal static let _3 = ImageAsset(name: "3")
  internal static let _4 = ImageAsset(name: "4")
  internal static let _5 = ImageAsset(name: "5")
  internal static let _6 = ImageAsset(name: "6")
  internal static let _7 = ImageAsset(name: "7")
  internal static let _8 = ImageAsset(name: "8")
  internal static let _9 = ImageAsset(name: "9")
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
