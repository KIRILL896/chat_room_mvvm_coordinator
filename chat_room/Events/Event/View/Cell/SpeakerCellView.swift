//
//  SpeakerCellView.swift
//  Liveroom
//
//  Created by отмеченные on 04.04.2021.
//

import UIKit
import RxSwift
import RxCocoa

class SpeakerCellView:UITableViewCell, Reusable {
    
    var disposeBag = DisposeBag()
    
    let textLabel_:UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 17)
        return l
    }()
    
    let removeIcon:UIButton = {
       let v = UIButton(type: .custom)
       v.frame =  CGRect(x: 0, y: 0, width: 24, height: 24)
       v.setImage(UIImage(named: "remove"), for: .normal)
       v.translatesAutoresizingMaskIntoConstraints = false
       return v
    }()
    
    let avatar:UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        image.image = UIImage()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 14
        image.backgroundColor = .red
        return image
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
        self.backgroundColor = UIColor.init(red: 229/255, green: 237/255, blue: 244/255, alpha: 1.0)

        contentView.addSubview(removeIcon)
        removeIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        removeIcon.trailingAnchor.constraint(equalTo: contentView.trailing, constant: -16).isActive = true
        removeIcon.makeAnchors { make in
            make.height(24)
            make.width(24)
        }
        contentView.addSubview(avatar)
        avatar.makeAnchors { make in
            make.leading(equalTo: contentView.leading, constant: 98)
            make.centerY(equalTo: contentView.centerY)
            make.height(28)
            make.width(28)
        }
        
        contentView.addSubview(textLabel_)
        textLabel_.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        textLabel_.leadingAnchor.constraint(equalTo: avatar.trailing, constant: 8).isActive = true
        textLabel_.trailingAnchor.constraint(equalTo: removeIcon.leading, constant: -8).isActive = true
    }
}



extension SpeakerCellView {
    func setupCell(model:Subscriber_) {
        self.textLabel_.text = model.firstname! + " " + model.lastname!
        self.avatar.loadImage_(from: model.photo, size: 24)
    }
}
