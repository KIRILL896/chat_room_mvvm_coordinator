//
//  MyEventsCellView.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//

import UIKit
import RxSwift
import RxCocoa

class MyEventCellView: UITableViewCell, Reusable {
    
    var disposeBag = DisposeBag()
    
    let dateLabel:UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 15, weight: .regular)
        return l
    }()
    
    
    let textLabel_:UILabel = {
        let l = UILabel()
        l.textColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 13, weight: .regular)
        return l
    }()
    
    
    let imageStack:UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5.0
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    let eventDescription:UILabel = {
        let l = UILabel()
        l.textColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.numberOfLines = 0
        return l
    }()
    
    
    let actionsButton:UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.frame = CGRect(x: 0, y: 0, width: 4, height: 20)
        b.setImage(UIImage(named: "bellIcon"), for: .normal)
        return b
    }()
    
    
    let textView:UITextView = {
         let textView = UITextView(frame: CGRect(x: 20.0, y: 90.0, width: 250.0, height: 100.0))
         textView.contentInsetAdjustmentBehavior = .automatic
         textView.textAlignment = NSTextAlignment.justified
         textView.backgroundColor = .white
         textView.font = UIFont.systemFont(ofSize: 14)
         textView.textColor = .black//UIColor.init(red: 133/255, green: 152/255, blue: 167/255, alpha: 1.0)
         textView.autocapitalizationType = UITextAutocapitalizationType.sentences
         textView.isSelectable = true
         textView.isEditable = false
         textView.dataDetectorTypes = UIDataDetectorTypes.link
         textView.autocorrectionType = UITextAutocorrectionType.yes
         textView.spellCheckingType = UITextSpellCheckingType.yes
         textView.isEditable = true
         return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setupConstraint()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setupConstraint()
    }
    
    override func prepareForReuse() {
      super.prepareForReuse()
      disposeBag = DisposeBag()
    }
    
    
    func setupConstraint() {
        selectionStyle = .none
        
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        selectionStyle = .none
       
        
        let over_view = UIView()
        over_view.backgroundColor = .mainWhite
        over_view.layer.cornerRadius = 12
        over_view.layer.zPosition = 1
        over_view.backgroundColor = .mainWhite
        over_view.layer.cornerRadius = 12
        over_view.clipsToBounds = true
         
        
        
        over_view.translatesAutoresizingMaskIntoConstraints = false
        over_view.layer.cornerRadius = 12.0
        contentView.addSubview(over_view)
        over_view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        over_view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        over_view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        over_view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        over_view.addSubview(dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: over_view.leadingAnchor, constant: 16).isActive = true
        dateLabel.topAnchor.constraint(equalTo: over_view.topAnchor, constant: 16).isActive = true
        
        contentView.addSubview(actionsButton)
        actionsButton.layer.zPosition = 20
        actionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35).isActive = true
        actionsButton.topAnchor.constraint(equalTo: over_view.topAnchor, constant: 16).isActive = true
        actionsButton.widthAnchor.constraint(equalToConstant: 32).isActive = true

        
        over_view.addSubview(eventDescription)
        eventDescription.leadingAnchor.constraint(equalTo: over_view.leadingAnchor, constant: 16).isActive = true
        eventDescription.trailingAnchor.constraint(equalTo: over_view.trailingAnchor, constant: -16).isActive = true
        eventDescription.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
 

        over_view.addSubview(imageStack)

        imageStack.topAnchor.constraint(equalTo: eventDescription.bottomAnchor, constant: 12).isActive = true
        imageStack.leadingAnchor.constraint(equalTo: over_view.leadingAnchor, constant: 16).isActive = true
        imageStack.heightAnchor.constraint(equalToConstant:32).isActive = true
        over_view.addSubview(textLabel_)
        textLabel_.makeAnchors { make in
            make.top(equalTo:imageStack.bottom, constant:5)
            make.leading(equalTo:over_view.leading, constant:16)
            make.trailing(equalTo:over_view.trailing, constant:-16)
            make.bottom(equalTo:over_view.bottom, constant:-16)
        }
    }
}



extension MyEventCellView {
    
    func setupCell(model:Event) {
        let date_ = model.startAt?.components(separatedBy: " ")[1]
        let without_second = date_?.components(separatedBy: ":")
        self.dateLabel.text = without_second![0] + ":" + without_second![1]
        self.eventDescription.text = model.name
        self.textLabel_.text = model.eventListDescription
        
        guard let speakers_ = model.topSpeakers else {return}
        
        imageStack.removeFullyAllArrangedSubviews()
        
        for speaker in speakers_ {
            guard let photo_ = speaker.photo else {return}
            let image_1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
            image_1.image = UIImage(named: "placeholderAvatarIcon")
            image_1.translatesAutoresizingMaskIntoConstraints = false
            image_1.loadImage_(from: photo_, size: 32)
            image_1.widthAnchor.constraint(equalToConstant: 32).isActive = true
            image_1.heightAnchor.constraint(equalToConstant: 32).isActive = true
            imageStack.addArrangedSubview(image_1)
        }
    }
    
}
