// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Dropdown {
    /// CheckList
    internal static let checkList = L10n.tr("Localizable", "Dropdown.CheckList")
    /// Draw
    internal static let draw = L10n.tr("Localizable", "Dropdown.Draw")
    /// Photos
    internal static let photos = L10n.tr("Localizable", "Dropdown.Photos")
    /// Text
    internal static let text = L10n.tr("Localizable", "Dropdown.Text")
    /// Videos
    internal static let videos = L10n.tr("Localizable", "Dropdown.Videos")
  }

  internal enum ListFontVC {
    /// List Font
    internal static let title = L10n.tr("Localizable", "ListFontVC.Title")
  }

  internal enum SegmentControl {
    /// Colors
    internal static let colors = L10n.tr("Localizable", "SegmentControl.Colors")
    /// Gradients
    internal static let gradients = L10n.tr("Localizable", "SegmentControl.Gradients")
    /// Images
    internal static let images = L10n.tr("Localizable", "SegmentControl.Images")
  }

  internal enum StyleView {
    /// Background Color
    internal static let backgroundColor = L10n.tr("Localizable", "StyleView.BackgroundColor")
    /// Text Color
    internal static let pickColor = L10n.tr("Localizable", "StyleView.PickColor")
  }

  internal enum Tabbar {
    /// Home
    internal static let home = L10n.tr("Localizable", "Tabbar.Home")
    /// Menu
    internal static let menu = L10n.tr("Localizable", "Tabbar.Menu")
    /// Photos
    internal static let photos = L10n.tr("Localizable", "Tabbar.Photos")
    /// Video
    internal static let video = L10n.tr("Localizable", "Tabbar.Video")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
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
