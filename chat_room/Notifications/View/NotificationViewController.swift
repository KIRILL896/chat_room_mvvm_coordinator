//
//  NotificationViewController.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class NotificationViewController:UIViewController, StoryBoard {
    
    private var viewModel:NotificationViewModelPresentable!
    var viewModelBuilder:NotificationViewModelPresentable.ViewModelBuilder!
    @IBOutlet weak var table: UITableView!
    
    private static let cellId:String = "NotificationCellId"
    
    private let selected_:PublishSubject<NotificationCellModel> = PublishSubject<NotificationCellModel>()
    
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<NotificationSectionModel>(configureCell: {_, tableView, indexPath, item in
        let notificationCell = tableView.dequequeCell(NotificationCellView.self, for: indexPath)//tableView.dequeueReusableCell(withIdentifier: NotificationCellView.reuseIdentifier, for: indexPath) as! NotificationCellView
        notificationCell.setupCell(model: item)
        return notificationCell
    })
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Оповещения"
        setupUI()
        setupInput()
        setupOutput()
    }
    
}


extension NotificationViewController {
    
    func setupUI() {
        self.view.backgroundColor = .mainBackground
        table.register(NotificationCellView.self, forCellReuseIdentifier:NotificationCellView.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.backgroundColor = .mainBackground
        table.rx.setDelegate(self).disposed(by: disposeBag)
    }
    func setupInput() {
        table.rx
          .modelSelected(NotificationCellModel.self)
          .bind(to:self.selected_)
          .disposed(by: disposeBag)
        viewModel = viewModelBuilder((
            clickAction: selected_.asDriverOnErrorJustComplete(), ()
        ))
    }
    
    func setupOutput() {
        self.viewModel.output.notifications.drive(table.rx.items(dataSource: self.dataSource)).disposed(by:disposeBag)
    }
}


extension NotificationViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
   }
}


