//
//  EventViewController.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//


import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxGesture
import CropViewController




class EventViewController:UIViewController, StoryBoard {
    
    private var viewModel:EventViewModelPresentable!
    var viewModelBuilder:EventViewModelPresentable.ViewModelBuilder!
    var cropViewController:CropViewController? = nil
    
    let date = Components.cell(text: "Дата", cellRight: .disclosure)
    let time = Components.cell(text: "Время", cellRight: .disclosure)
    
    let name = Components.cell(text: "Название события", cellRight: .no)
    let people = Components.cellGuestCreator(text: "Участник", cellRight: .no, imageUrl: "")
    let add_person = Components.cellButton(text: "Добавить гостей", cellRight: .no, color:UIColor.init(red: 34/255, green: 136/255, blue: 221/255, alpha: 1.0))

    
    private let timeObserver = BehaviorRelay<String>(value: "")
    private let deleteItem:PublishSubject<Subscriber_> = PublishSubject<Subscriber_>()
    private let selectSubscriberModel = PublishSubject<Subscriber_>()
    let avatarPicker = PublishSubject<UIImage>()
    var picker: ImagePicker?
    private let disposeBag = DisposeBag()
    
    
    let descriptionLabel:UILabel = {
       let l = UILabel()
       l.text = "Событие"
       l.font = .systemFont(ofSize: 17, weight: .bold)
       l.textColor = .black
       l.translatesAutoresizingMaskIntoConstraints = false
       return l
    }()
    
    let cancelButton:UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Отмена", for: .normal)
        b.setTitleColor(UIColor.init(red: 34/255, green: 136/255, blue: 221/255, alpha: 1.0), for: .normal)
        return b
    }()
    
    let iconSelectImage: UIImageView = {
      let view = UIImageView()
      view.height(24).isActive = true
      view.width(24).isActive = true
      view.image = UIImage(named:"eventImage")
      return view
    }()
    
    
    let createButton:UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Создать", for: .normal)
        b.setTitleColor(UIColor.init(red: 34/255, green: 136/255, blue: 221/255, alpha: 1.0), for: .normal)
        return b
    }()
    
    let closeSelectImage:UIButton = {
       let b = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
       b.setImage(UIImage(named: "closeSelectImage"), for: .normal)
       b.isHidden = true
       b.translatesAutoresizingMaskIntoConstraints = false
       b.height(24).isActive = true
       b.width(24).isActive = true
       return b
    }()
    
    let placeholderLabel:UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Описание"
        return placeholderLabel
    }()
    
    let textView:UITextView = {
         let textView = UITextView(frame: CGRect(x: 20.0, y: 90.0, width: 250.0, height: 100.0))
         textView.contentInsetAdjustmentBehavior = .automatic
         textView.textAlignment = NSTextAlignment.justified
         textView.backgroundColor = UIColor.init(red: 229/255, green: 237/255, blue: 244/255, alpha: 1.0)
         textView.textColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
         textView.font = .systemFont(ofSize: 17, weight: .regular)
         textView.autocapitalizationType = .none
         textView.isSelectable = true
         textView.dataDetectorTypes = UIDataDetectorTypes.link
         textView.layer.cornerRadius = 10
         //textView.autocorrectionType =
         textView.spellCheckingType = UITextSpellCheckingType.yes
         textView.isEditable = true
         return textView
    }()
    
    
    var datePicker:UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
        }
        let loc = Locale(identifier: "ru")
        datePicker.locale = loc
        return datePicker
    }()
    
    
    let ImageSelectedView:UIImageView = {
       let image = UIImageView()
       image.layer.cornerRadius = 10.0
       image.layer.masksToBounds = true
       image.contentMode = .scaleAspectFill
       image.translatesAutoresizingMaskIntoConstraints = false
       return image
    }()
    
    
    let imageViewStack:UIStackView = {
       let stack = UIStackView()
       stack.alignment = .center
       stack.spacing = 5.0
       stack.axis = .horizontal
       stack.distribution = .equalSpacing
       return stack
    }()
    
    let subScribersList:subscribersListView = {
        let list = subscribersListView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        list.translatesAutoresizingMaskIntoConstraints = false
        list.layer.zPosition = 5
        list.layer.cornerRadius = 13
        return list
    }()
    
    let minumumSymbols:UILabel = {
        let l = UILabel()
        l.text = "255 символов осталось"
        l.font = .systemFont(ofSize: 13, weight: .thin)
        l.textColor = UIColor.init(red: 133/255, green: 152/255, blue: 167/255, alpha: 1.0)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let scrollview:UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.zPosition = 0
        v.autoresizingMask = .flexibleHeight
        return v
    }()
    
    
    let overLayer:UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.zPosition = 2
        v.backgroundColor = UIColor.init(red: 22/255, green: 73/255, blue: 116/255, alpha: 0.48)
        return v
    }()
    
    let table:UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.isScrollEnabled = false
        view.backgroundColor = UIColor.init(red: 229/255, green: 237/255, blue: 244/255, alpha: 1.0)//.white
        view.separatorInset =  UIEdgeInsets(top: 0, left: 16 + 64 + 16, bottom: 0,   right: 0)
        view.register(SpeakerCellView.self, forCellReuseIdentifier: SpeakerCellView.reuseIdentifier)
        view.rowHeight = UITableView.automaticDimension
        return view
    }()
    
    var tableConstraint: NSLayoutConstraint!
    var sizer = PublishSubject<Void>()
    var imageHeightContstaint:NSLayoutConstraint!
    
    
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<TopSpeakersSectionModel>(configureCell: {_, tableView, indexPath, item in
        let cell = tableView.dequequeCell(SpeakerCellView.self, for: indexPath)
        cell.setupCell(model: item)
        
        cell
            .removeIcon
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.deleteItem.onNext(item)
            }).disposed(by: cell.disposeBag)
        return cell
    }, canEditRowAtIndexPath: { _, _ in
        return true
     })
    
    
    private lazy var subDataSource = RxTableViewSectionedReloadDataSource<SubscribersSectionModel>(configureCell: {_, tableView, indexPath, item in
        let cell = tableView.dequequeCell(SubscriberCellView.self, for: indexPath)
        cell.setupCell(model: item)
        cell
            .selecltedIcon
            .rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.selectSubscriberModel.onNext(item)
            }).disposed(by: cell.disposeBag)
        return cell
    }, canEditRowAtIndexPath: { _, _ in
        return true
     })
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupInput()
        self.setupOutPut()
    
    }
    
}



extension EventViewController {
    
    func setupUI() {

        view.addSubview(scrollview)
        scrollview.makeAnchors { make in
          make.top(equalTo: view.safeTop)
          make.bottom(equalTo: view.safeBottom)
          make.leading(equalTo: view.leading)
          make.trailing(equalTo: view.trailing)
        }

        
        scrollview.addSubview(cancelButton)
        cancelButton.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 20).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 16).isActive = true
        
        
        scrollview.addSubview(createButton)
        createButton.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 20).isActive = true
        createButton.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: -16).isActive = true
        createButton.setTitleColor(Colors.gray2, for: .disabled)
        
        scrollview.addSubview(descriptionLabel)
        descriptionLabel.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 28).isActive = true
        
        
        scrollview.addSubview(ImageSelectedView)
        ImageSelectedView.makeAnchors { make in
          make.centerX(equalTo: scrollview.centerX)
          make.leading(equalTo: scrollview.leading, constant: 16)
          make.trailing(equalTo: scrollview.trailing, constant: -16)
          make.top(equalTo: scrollview.topAnchor, constant: 70)
        }
        
        
        imageHeightContstaint = ImageSelectedView.height(40)
        imageHeightContstaint.isActive = true
        
        let label = UILabel()
        label.text = "Добавить обложку"
        label.textColor  = .mainBlue
        label.font = .systemFont(ofSize: 17, weight: .regular)
        
        imageViewStack.addArrangedSubview(iconSelectImage)
        imageViewStack.addArrangedSubview(label)
        
        ImageSelectedView.addSubview(imageViewStack)
        imageViewStack.makeAnchors { make in
          make.centerX(equalTo: ImageSelectedView.centerX)
          make.centerY(equalTo: ImageSelectedView.centerY)
        }
         
        ImageSelectedView.addSubview(closeSelectImage)
        closeSelectImage.makeAnchors { make in
            make.top(equalTo: ImageSelectedView.top, constant:12)
            make.trailing(equalTo: ImageSelectedView.trailing, constant:-12)
        }
        
        
        let EventInfoStack = Components.stack(arrSub: [
            name.0, Components.separator(), people.0, Components.separator(), table,  Components.separator(), add_person.0
        ], axis: .vertical)
        let EventInfoView = UIView()
        EventInfoView.backgroundColor = UIColor.init(red: 229/255, green: 237/255, blue: 244/255, alpha: 1.0)
        EventInfoView.round(radius: 12)
        EventInfoStack.full(in: EventInfoView)
        scrollview.addSubview(EventInfoView)
        EventInfoView.makeAnchors { make in
          make.top(equalTo: ImageSelectedView.bottom, constant: 25)
          make.leading(equalTo: scrollview.leading, constant: 16)
          make.trailing(equalTo: scrollview.trailing, constant: -16)
        }
        
    
        let dateStack = Components.stack(arrSub: [
            date.0, Components.separator(), time.0
        ], axis: .vertical)
        dateStack.spacing = 0.0
        dateStack.backgroundColor =  UIColor.init(red: 229/255, green: 237/255, blue: 244/255, alpha: 1.0)
        let dateStackView = UIView()
        dateStackView.backgroundColor =  UIColor.init(red: 229/255, green: 237/255, blue: 244/255, alpha: 1.0)
        dateStackView.round(radius: 12)
        dateStack.full(in: dateStackView)
        scrollview.addSubview(dateStackView)
        dateStackView.makeAnchors { make in
          make.top(equalTo: EventInfoView.bottom, constant: 16)
          make.leading(equalTo: scrollview.leading, constant: 16)
          make.trailing(equalTo: scrollview.trailing, constant: -16)
          make.width(UIScreen.main.bounds.width - 32)
        }
        
        
        datePicker.frame =  CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200)
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .allEvents)
        time.1.inputView = datePicker
        date.1.inputView = datePicker
        let doneButton = UIBarButtonItem.init(title: "Готово", style: .done, target: self, action: #selector(self.datePickerDone))
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44))
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        time.1.inputAccessoryView = toolBar
        date.1.inputAccessoryView = toolBar
        
        tableConstraint = table.height(1)
        tableConstraint.isActive = true
        
        placeholderLabel.font = UIFont.systemFont(ofSize: 17)
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.init(red: 133/255, green: 152/255, blue: 167/255, alpha: 1.0)
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        textView.delegate = self
        scrollview.addSubview(textView)
        textView.makeAnchors { make in
            make.top(equalTo:dateStackView.bottom, constant:20)
            make.leading(equalTo:scrollview.leading, constant:16)
            make.trailing(equalTo:scrollview.trailing, constant:-16)
            make.height(160)
        }
        scrollview.addSubview(minumumSymbols)
        minumumSymbols.makeAnchors { make in
            make.top(equalTo:textView.bottom, constant:16)
            make.leading(equalTo:scrollview.leading, constant:20)
            make.bottom(equalTo:scrollview.bottom, constant:-20)
        }
        

        self.view.addSubview(overLayer)
        overLayer.makeAnchors { make in
            make.bottom(equalTo:view.safeBottom)
            make.leading(equalTo:view.leading)
            make.trailing(equalTo:view.trailing)
            make.top(equalTo:view.safeTop)
        }
        
        scrollview.layer.zPosition = 0
        self.view.addSubview(subScribersList)
        subScribersList.makeAnchors { make in
            make.bottom(equalTo:view.bottom)
            make.leading(equalTo:view.leading)
            make.trailing(equalTo:view.trailing)
            make.top(equalTo:view.top, constant:100)
        }
        
        
        self.overLayer.isHidden = true
        self.subScribersList.isHidden = true
    }
    
    
    @objc func dateChanged() {
      let today = datePicker.date
      let formatter1 = DateFormatter()
      formatter1.dateFormat =  "HH:mm"
      let time_String = formatter1.string(from: today)
      time.1.text = time_String
      formatter1.dateFormat =  "dd.MM.y"
      let dateString = formatter1.string(from: today)
      date.1.text = dateString
      self.timeObserver.accept(time_String + ":" +  dateString)//onNext(time_String + dateString)
    }
  
    
    
    @objc func datePickerDone() {
        time.1.resignFirstResponder()
        date.1.resignFirstResponder()
    }
    
    func setupInput() {
        viewModel = viewModelBuilder((
            cancel:cancelButton.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
            create:createButton.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
            eventName:name.1.rx.text.orEmpty.asDriver(),
            time:self.timeObserver.asDriverOnErrorJustComplete(),
            eventDescription:self.textView.rx.text.orEmpty.asDriverOnErrorJustComplete(),
            addGuests:add_person.0.rx.tapGesture().when(.recognized).mapToVoid().asDriverOnErrorJustComplete(),
            tableModelSelected:table.rx.modelSelected(Speaker.self).asDriverOnErrorJustComplete(),
            deleteTableItem:deleteItem.asDriverOnErrorJustComplete(),
            selectedSubscriber:self.selectSubscriberModel.asDriverOnErrorJustComplete(),
            searchText:self.subScribersList.text_Filed.rx.text.orEmpty.asDriver(),
            avatarPicker:self.avatarPicker.asDriverOnErrorJustComplete()
        ))
    }
    
    
    func setupOutPut() {
        self.table.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.output.canCreate.asObservable().bind(to: createButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.output.textCount.asObservable().bind(to:self.minumumSymbols.rx.text).disposed(by: disposeBag)
        viewModel.output.selectedSubscirbers.drive(table.rx.items(dataSource: self.dataSource)).disposed(by:disposeBag)
        viewModel.output.subscribers.drive(subScribersList.table.rx.items(dataSource: self.subDataSource)).disposed(by:subScribersList.bag)
        viewModel.output.textBlock.asObservable().bind(to:textView.rx.text).disposed(by: disposeBag)
        
        
        
        sizer.bind { [unowned self] _ in
          self.tableConstraint.constant = self.table.contentSize.height - 2
          self.table.layoutIfNeeded()
          self.scrollview.layoutIfNeeded()
        }
        .disposed(by: disposeBag)
        
        viewModel
          .output
          .selectedSubscirbers
          .asObservable()
          .bind { [unowned self] _ in
            self.sizer.onNext(())
          }
          .disposed(by: disposeBag)

        viewModel
          .output
          .selectedSubscirbers
          .asObservable()
          .mapToVoid()
          .bind { [unowned self] _ in
            self.sizer.onNext(())
          }
          .disposed(by: disposeBag)
        
        
        viewModel
          .output
          .subscribers
          .asObservable()
          .bind { [unowned self] _ in
            self.subScribersList.sizer.onNext(())
          }
          .disposed(by: disposeBag)
        
    
        viewModel
          .output
          .subscribers
          .asObservable()
          .mapToVoid()
          .bind { [unowned self] _ in
            self.subScribersList.sizer.onNext(())
          }
          .disposed(by: disposeBag)
        
        
        ImageSelectedView
          .rx
          .tapGesture()
          .when(.recognized)
          .mapToVoid()
          .bind { [unowned self] _ in
            self.picker = ImagePicker(presentationController: self, delegate: self)
            self.picker!.present(from: self.view)
          }
          .disposed(by: disposeBag)
        
        
        subScribersList
            .closeImage
            .rx
            .tapGesture()
            .when(.recognized)
            .asObservable()
            .bind { [weak self] _ in
                guard let self = self else {return}
                self.overLayer.isHidden = true
                self.subScribersList.text_Filed.text = ""
                self.subScribersList.isHidden = true
            }.disposed(by: disposeBag)
        
        
        add_person.0.rx.tapGesture().when(.recognized).mapToVoid().asObservable().bind { [weak self] in
            self?.overLayer.isHidden = false
            self?.subScribersList.isHidden = false
        }.disposed(by: disposeBag)
        
        
        closeSelectImage
            .rx
            .tap
            .asObservable()
            .bind { [weak self] in
                guard let self = self else {return}
                self.closeSelectImage.isHidden = true
                self.ImageSelectedView.image = nil
                self.imageViewStack.isHidden = false
                self.imageHeightContstaint.constant = 40
            }.disposed(by: disposeBag)
        
        
        
        
        
    }
    
}



extension EventViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
         placeholderLabel.isHidden = !textView.text.isEmpty
    }

}

extension EventViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return UITableView.automaticDimension
    }
}


extension EventViewController: ImagePickerDelegate {
  func didSelect(image: UIImage?) {
    guard let img = image else { return }
    self.avatarPicker.onNext(img)
    self.ImageSelectedView.image = image
    self.imageHeightContstaint.constant = 194
    self.imageViewStack.isHidden = true
    self.closeSelectImage.isHidden = false
  }
}

extension EventViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.avatarPicker.onNext(image)
        self.cropViewController?.dismiss(animated: true)//dismissAnimatedFrom(self, toView: self.view, toFrame: self.view.frame, setup: nil, completion: nil)
        self.iconSelectImage.image = image
    }
}


