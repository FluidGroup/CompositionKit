//
//  CircularClippingView.swift
//  AppUIKit
//
//  Created by muukii on 2019/09/01.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation
import MondrianLayout

open class CircularClippingView<Body: UIView>: WrapperView<Body> {
  
  public override init(_ wrappedView: Body) {
    super.init(wrappedView)
    mondrian.layout
      .width(.to(self).height)
      .activate()
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    layer.masksToBounds = true
    layer.cornerRadius = bounds.width / 2
  }
}
