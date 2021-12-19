//
//  EmojiCategoryKeyboard.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-17.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import SwiftUI

/**
 This keyboard lists all emojis from a selected category, as
 well as a menu that lets the user select a new category and
 change back to an alphabetic keyboard.
 
 As long as the view requires iOS 14, the extensions must be
 kept in the main struct body for the previews to compile.
 */
@available(iOS 14.0, *)
public struct EmojiCategoryKeyboard<KeyboardView: View, CategoryTitleView: View>: View {
    
    /**
     Create an emoji category keyboard.
     
     - Parameters:
       - categories: The categories to show in the menu.
       - appearance: The appearance to apply to the menu.
       - context: The context to use when rendering the view.
       - selection: The currently selected category.
       - style: The style to apply to the keyboard, by default `.standardPhonePortrait`.
       - categoryTitle: A category title provider, by default `.standardCategoryTitle`.
       - categoryTitleView: An emoji category title view builder.
       - categoryKeyboard: An emoji category keyboard view builder.
     */
    public init(
        categories: [EmojiCategory] = EmojiCategory.all,
        appearance: KeyboardAppearance,
        context: KeyboardContext,
        selection: EmojiCategory? = nil,
        style: EmojiKeyboardStyle = .standardPhonePortrait,
        categoryTitle: @escaping CategoryTitleProvider = standardCategoryTitle,
        categoryTitleView: @escaping CategoryTitleViewProvider,
        categoryKeyboard: @escaping CategoryKeyboardProvider) {
        self.categories = categories.filter { $0.emojis.count > 0 }
        self.appearance = appearance
        self.style = style
        self.context = context
        self.initialSelection = selection
        self.categoryTitle = categoryTitle
        self.categoryTitleView = categoryTitleView
        self.categoryKeyboard = categoryKeyboard
    }
    
    private let initialSelection: EmojiCategory?
    private let categories: [EmojiCategory]
    private let appearance: KeyboardAppearance
    private let context: KeyboardContext
    private let style: EmojiKeyboardStyle
    private let categoryTitle: CategoryTitleProvider
    private let categoryTitleView: CategoryTitleViewProvider
    private let categoryKeyboard: CategoryKeyboardProvider
    
    @State private var isInitialized = false
    @State private var selection = EmojiCategory.smileys
    
    
    // MARK: - Typealiases
    
    /**
     This is a typealias for a function that can be used for
     providing a title for an emoji category.
     */
    @available(iOS 14.0, *)
    public typealias CategoryTitleProvider = (EmojiCategory) -> String
    
    /**
     This is a typealias for a function that can be used for
     providing a title view for an emoji category.
     */
    @available(iOS 14.0, *)
    public typealias CategoryTitleViewProvider = (EmojiCategory, String) -> CategoryTitleView

    /**
     This is a typealias for a function that can be used for
     providing a keyboard view for an emoji category.
     */
    @available(iOS 14.0, *)
    public typealias CategoryKeyboardProvider = (EmojiCategory, EmojiKeyboardStyle) -> KeyboardView
    
    
    // MARK: - Public Static Builders
    
    /**
     This function returns the standard title for a category.
     */
    public static func standardCategoryTitle(for category: EmojiCategory) -> String {
        category.title
    }
    

    // MARK: - Private Functions
    
    private var defaults: UserDefaults { .standard }
    
    private let defaultsKey = "com.keyboardkit.EmojiCategoryKeyboard.category"
    
    private var persistedCategory: EmojiCategory {
        let name = defaults.string(forKey: defaultsKey) ?? ""
        return categories.first { $0.rawValue == name } ?? .smileys
    }
    
    private func initialize() {
        if isInitialized { return }
        selection = initialSelection ?? persistedCategory
        isInitialized = true
    }
    
    private func saveCurrentCategory() {
        defaults.set(selection.rawValue, forKey: defaultsKey)
    }
    
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            categoryTitleView(selection, categoryTitle(selection))
            ScrollView(.horizontal, showsIndicators: false) {
                categoryKeyboard(selection, style)
            }
            EmojiCategoryKeyboardMenu(
                categories: categories,
                appearance: appearance,
                context: context,
                selection: $selection,
                style: style)
        }
        .onAppear(perform: initialize)
        .onDisappear(perform: saveCurrentCategory)
    }
}

@available(iOS 14.0, *)
public extension EmojiCategoryKeyboard where KeyboardView == EmojiKeyboard<EmojiKeyboardButton> {
    
    /**
     Create an emoji category keyboard, that uses a standard
     view for category keyboards.
     
     - Parameters:
       - categories: The categories to show in the menu.
       - appearance: The appearance to apply to the menu.
       - context: The context to use when rendering the view.
       - selection: The currently selected category.
       - style: The style to apply to the keyboard, by default `.standardPhonePortrait`.
       - categoryTitle: A category title provider, by default `.standardCategoryTitle`.
       - categoryTitleView: An emoji category title view builder.
     */
    init(
        categories: [EmojiCategory] = EmojiCategory.all,
        appearance: KeyboardAppearance,
        context: KeyboardContext,
        selection: EmojiCategory? = nil,
        style: EmojiKeyboardStyle = .standardPhonePortrait,
        categoryTitle: @escaping CategoryTitleProvider = standardCategoryTitle,
        categoryTitleView: @escaping CategoryTitleViewProvider) {
        self.categories = categories.filter { $0.emojis.count > 0 }
        self.appearance = appearance
        self.style = style
        self.context = context
        self.initialSelection = selection
        self.categoryTitle = categoryTitle
        self.categoryTitleView = categoryTitleView
        self.categoryKeyboard = Self.standardCategoryKeyboard
    }
    
    /**
     The standard function to use to build an emoji category
     title view.
     */
    static func standardCategoryKeyboard(
        category: EmojiCategory,
        style: EmojiKeyboardStyle) -> EmojiKeyboard<EmojiKeyboardButton> {
        EmojiKeyboard(
            emojis: category.emojis,
            style: style)
    }
}

@available(iOS 14.0, *)
public extension EmojiCategoryKeyboard where CategoryTitleView == EmojiCategoryTitle {
    
    /**
     Create an emoji category keyboard, that uses a standard
     view for category titles.
     
     - Parameters:
       - categories: The categories to show in the menu.
       - appearance: The appearance to apply to the menu.
       - context: The context to use when rendering the view.
       - selection: The currently selected category.
       - style: The style to apply to the keyboard, by default `.standardPhonePortrait`.
       - categoryTitle: A category title provider, by default `.standardCategoryTitle`.
       - categoryKeyboard: An emoji category keyboard view builder.
     */
    init(
        categories: [EmojiCategory] = EmojiCategory.all,
        appearance: KeyboardAppearance,
        context: KeyboardContext,
        selection: EmojiCategory? = nil,
        style: EmojiKeyboardStyle = .standardPhonePortrait,
        categoryTitle: @escaping CategoryTitleProvider = standardCategoryTitle,
        categoryKeyboard: @escaping CategoryKeyboardProvider) {
        self.categories = categories.filter { $0.emojis.count > 0 }
        self.appearance = appearance
        self.style = style
        self.context = context
        self.initialSelection = selection
        self.categoryTitle = categoryTitle
        self.categoryTitleView = Self.standardCategoryTitleView
        self.categoryKeyboard = categoryKeyboard
    }
    
    /**
     The standard function to use to build an emoji category
     title view.
     */
    static func standardCategoryTitleView(
        category: EmojiCategory,
        title: String) -> EmojiCategoryTitle {
        EmojiCategoryTitle(title: title)
    }
}

@available(iOS 14.0, *)
public extension EmojiCategoryKeyboard where KeyboardView == EmojiKeyboard<EmojiKeyboardButton>, CategoryTitleView == EmojiCategoryTitle {
    
    /**
     Create an emoji category keyboard, that uses a standard
     view for the category titles and keyboards.
     
     - Parameters:
       - categories: The categories to show in the menu.
       - appearance: The appearance to apply to the menu.
       - context: The context to use when rendering the view.
       - selection: The currently selected category.
       - style: The style to apply to the keyboard, by default `.standardPhonePortrait`.
       - categoryTitle: A category title provider, by default `.standardCategoryTitle`.
     */
    init(
        categories: [EmojiCategory] = EmojiCategory.all,
        appearance: KeyboardAppearance,
        context: KeyboardContext,
        selection: EmojiCategory? = nil,
        style: EmojiKeyboardStyle = .standardPhonePortrait,
        categoryTitle: @escaping CategoryTitleProvider = standardCategoryTitle) {
        self.categories = categories.filter { $0.emojis.count > 0 }
        self.appearance = appearance
        self.style = style
        self.context = context
        self.initialSelection = selection
        self.categoryTitle = categoryTitle
        self.categoryTitleView = Self.standardCategoryTitleView
        self.categoryKeyboard = Self.standardCategoryKeyboard
    }
    
    /**
     The standard function to use to build an emoji category
     title view.
     */
    static func standardCategoryTitleView(
        category: EmojiCategory,
        title: String) -> EmojiCategoryTitle {
        EmojiCategoryTitle(title: title)
    }
}
    
@available(iOS 14.0, *)
struct EmojiCategoryMenu_Keyboard: PreviewProvider {
    
    static var previews: some View {
        EmojiCategoryKeyboard(
            appearance: .preview,
            context: .preview,
            selection: .smileys)
    }
}
