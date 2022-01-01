import MondrianLayout
import StorybookKit
import SwiftUI
import UIKit
import CompositionKit

@available(iOS 13, *)
public enum Book_VGridView {

  static var body: BookView {

    BookNavigationLink(title: "VGridView") {

      BookPreview(expandsWidth: true, maxHeight: 100, minHeight: 100) {

        return AnyView { view in
          VStackBlock(alignment: .fill) {

            VGridView(contents: [
              UILabel.mockMultiline(text: "Hello"),
              UILabel.mockMultiline(text: "Hello")
//              UIView.mock(backgroundColor: .neon(.blue), preferredSize: .init(width: 20, height: 20)),
//              UIView.mock(backgroundColor: .neon(.blue), preferredSize: .init(width: 20, height: 20)),
            ])

            StackingSpacer(minLength: 0)

          }


        }

      }
    }

  }

}
