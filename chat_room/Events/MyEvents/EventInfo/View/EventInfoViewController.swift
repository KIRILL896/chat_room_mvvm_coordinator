//
//  EventInfoViewController.swift
//  Liveroom
//
//  Created by отмеченные on 12.04.2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import RxDataSources

class EventInfoViewController : UIViewController{
    
    private var viewModel:EventInfoViewModelPresentable!
    var viewModelBuilder:EventInfoViewModelPresentable.ViewModelBuilder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
