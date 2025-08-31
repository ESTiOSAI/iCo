//
//  TabRouter.swift
//  AIProject
//
//  Created by kangho lee on 8/26/25.
//

import Foundation

/// Tab 전환과 선택된 Tab 관찰을 위해 만듦
@Observable
final class TabRouter {
    var selected: TabFeature = .dashboard
}
