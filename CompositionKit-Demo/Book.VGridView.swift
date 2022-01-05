import CompositionKit
import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit

@available(iOS 13, *)
public enum Book_VGridView {

  static var body: BookView {

    BookNavigationLink(title: "VGridView") {

      BookPreview(expandsWidth: true, maxHeight: 100, minHeight: 100) {

        let gridView = VGridView(numberOfColumns: 2)
        gridView.setContents([
          UILabel.mockMultiline(text: "Hello"),
          UILabel.mockMultiline(text: "Hello"),
        ])

        return AnyView { view in
          VStackBlock(alignment: .fill) {

            gridView

            StackingSpacer(minLength: 0)

          }

        }

      }
    }

  }

}
