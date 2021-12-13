//
//  BackgroundView.swift
//  AppUIKit
//
//  Created by muukii on 2019/08/19.
//  Copyright © 2019 eure. All rights reserved.
//

import Foundation

import MondrianLayout

/// Composition
public final class AnyBackgroundView: UIView {
 
  public init(body: UIView, background: UIView) {
    super.init(frame: .zero)
    
    addSubview(background)
    addSubview(body)

    body.mondrian.layout
      .edges(.toSuperview)
      .activate()
    background.mondrian.layout
      .edges(.toSuperview)
      .activate()
    
    background.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    background.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
  }

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
