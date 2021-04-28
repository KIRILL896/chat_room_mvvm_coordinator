//
//  MyEventsViewController.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import RxDataSources
import BTNavigationDropdownMenu



class MyEventsViewController:UIViewController, StoryBoard {
    private var viewModel:MyEventsViewModelPresentable!
    var viewModelBuilder:MyEventsViewModelPresentable.ViewModelBuilder!
    @IBOutlet weak var table: UITableView!
    
    private let selected_:PublishSubject<Event> = PublishSubject<Event>()
    
    private let disposeBag = DisposeBag()
    private let deleteAction = PublishSubject<Event>()
    private let redactAction = PublishSubject<Event>()
    private let eventsType = BehaviorSubject<String>(value: "all")
    
    let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
    
    let scoredMeEmpty: UILabel = {
      let view = UILabel()
      view.alpha = 0
      view.textColor = Colors.subtitleText
      view.text = "Nobody has rated you yet"
      return view
    }()
    
    let scoredByMeEmpty: UILabel = {
      let view = UILabel()
      view.alpha = 1.0
      view.textColor = Colors.subtitleText
      view.text = ""
      return view
    }()
    
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<MyEventSectionModel>(configureCell: {_, tableView, indexPath, item in
        let notificationCell = tableView.dequequeCell(MyEventCellView.self, for: indexPath)
        notificationCell.setupCell(model: item)
        notificationCell
            .actionsButton
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.showCreateView()
            }).disposed(by: notificationCell.disposeBag)
        
        return notificationCell
    }, canEditRowAtIndexPath: { _, _ in
        return true
     })
    
    
    func showCreateView() {
        let createView = CreateView()
        createView.modalPresentationStyle = .custom
        createView.transitioningDelegate = self
        self.present(createView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupInput()
        self.setupOutput()
    }
    
    
}

extension MyEventsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is CreateRoomView {
            return CreateRoomPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is ChoiceOfInterlocutorsView {
            return ChoiceOfInterlocutorsPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is InputRoomNameView {
            return InputRoomNameViewPresentationController(presentedViewController: presented, presenting: presenting)
        } else if presented is CreateView {
            return CreateViewPresentationController(presentedViewController: presented, presenting: presenting)
        }
        else {
            return UIPresentationController(presentedViewController: presented, presenting: presenting)
        }
    }
}


extension MyEventsViewController {
    
    func setupUI() {

        view.addSubview(scoredByMeEmpty)

        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        scoredByMeEmpty.makeAnchors { make in
          make.centerX(equalTo: table.centerX)
          make.centerY(equalTo: table.centerY)
        }
        
        
        
        table.register(MyEventCellView.self, forCellReuseIdentifier:MyEventCellView.reuseIdentifier)
        table.register(MyEventsHeaderSection.self, forHeaderFooterViewReuseIdentifier:   MyEventsHeaderSection.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.layer.shadowColor = UIColor.mainShadow.cgColor
        table.layer.shadowOffset = CGSize(width: 0, height: 4)
        table.layer.shadowOpacity = 0.10
        table.layer.shadowRadius = 16.0 / 2
        table.refreshControl = UIRefreshControl()
        
        
        let items = ["События для вас", "Мои События"]
        let menuView = BTNavigationDropdownMenu(title: BTTitle.index(0), items: items)
        
        menuView.cellBackgroundColor = UIColor.white
        menuView.arrowTintColor = .black
        menuView.cellTextLabelAlignment = .left
        menuView.arrowImage = UIImage(named:"eventMarker")
        menuView.navigationBarTitleFont =   .systemFont(ofSize: 24, weight: .bold)
        
        self.navigationItem.titleView = menuView
     
        
        self.navigationItem.rightBarButtonItems = [self.search]
        
        menuView.didSelectItemAtIndexHandler = {[unowned self] (indexPath: Int) -> () in
            print("Did select item at index: \(indexPath)")
            self.navigationItem.title = items[indexPath]
            let subjectText = indexPath == 0 ? "all" : "my"
            let button_ = indexPath == 0 ? self.search : self.add
            self.navigationItem.rightBarButtonItems = [button_]
            self.eventsType.onNext(subjectText)
        }
        
    }
    func setupInput() {
        
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
                    .mapToVoid()
                    .asDriverOnErrorJustComplete()
        let pull = table.refreshControl!.rx
                    .controlEvent(.valueChanged)
                    .asDriver()
                
    
            
        viewModel = viewModelBuilder((
            addEvent:add.rx.tap.asDriver(),
            chooseModel:table.rx.modelSelected(Event.self).asDriver(),
            deleteEvent:self.deleteAction.asDriverOnErrorJustComplete(),
            redactEvent:self.redactAction.asDriverOnErrorJustComplete(),
            eventsType:self.eventsType.asDriverOnErrorJustComplete(),
            pullRefreshTrigger:Driver.merge(viewWillAppear, pull)
        ))
    }
    
    func setupOutput() {
        self.dataSource.titleForHeaderInSection = { dataSource, index in
          return dataSource.sectionModels[index].title
        }
                
        self.viewModel.output.events.drive(table.rx.items(dataSource: self.dataSource)).disposed(by:disposeBag)
        
        self.table.rx.setDelegate(self).disposed(by: disposeBag)
        
        self.viewModel.output.countTextWarnings.asObservable().bind(to: self.scoredByMeEmpty.rx.text).disposed(by: disposeBag)
        
        self.viewModel.output.fetching.drive(table.refreshControl!.rx.isRefreshing).disposed(by: disposeBag)
    }
    
    
   
    
    
    func accept_or_reject(user:Event) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let accept = UIAlertAction(
          title: "Редактировать событие",
          style: .default) { [weak self] _ in
            self?.redactAction.onNext(user)
        }
        
        let reject = UIAlertAction(
          title: "Удалить",
          style: .default) { [weak self] _ in
            self?.deleteAction.onNext(user)
        }
        reject.titleTextColor = .red
        let cancel = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        alertVC.addAction(accept)
        alertVC.addAction(reject)
        alertVC.addAction(cancel)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}


extension MyEventsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let sectionView = tableView.dequequeHeader(MyEventsHeaderSection.self)
          sectionView.setupConstraint()
          return sectionView
    }
}

