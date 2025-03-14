//
//  PKSTextField.swift
//  PKSUI
//
//  Created by Ömer Hamid Kamışlı on 3/14/25.
//

import SwiftUI

/// A customizable text input field designed for SwiftUI.
///
/// `PKSTextField` provides flexibility to customize the appearance and behavior of text fields through composable views, including labels, placeholders, and optional start and end content.
///
/// ``WORK IN PROGRESS``
/// ```
public struct PKSTextField<Label: View, Placeholder: View, StartContent: View, EndContent: View>: View {

    // MARK: - Properties

    /// The text entered by the user.
    @Binding private var text: String

    /// View displayed at the start of the text field.
    private var startContent: () -> StartContent

    /// View displayed at the end of the text field.
    private var endContent: () -> EndContent

    /// View that describes the text field.
    private var label: () -> Label

    /// View shown when the text field is empty.
    private var placeholder: () -> Placeholder

    /// Creates a new `PKSTextField` instance.
    ///
    /// - Parameters:
    ///   - text: A binding to the text entered by the user.
    ///   - label: A view builder providing the label view.
    ///   - placeholder: A view builder providing the placeholder view.
    ///   - startContent: A view builder for content at the start of the field.
    ///   - endContent: A view builder for content at the end of the field.
    public init(
        text: Binding<String>,
        label: @escaping () -> Label,
        placeholder: @escaping () -> Placeholder,
        startContent: @escaping () -> StartContent,
        endContent: @escaping () -> EndContent
    ) {
        self._text = text
        self.startContent = startContent
        self.endContent = endContent
        self.label = label
        self.placeholder = placeholder
    }

    public var body: some View {
        Text("Work in progress...")
    }
}


