//
//  NotificationsCellView.swift
//  Liveroom
//
//  Created by отмеченные on 21.03.2021.
//


import UIKit
import RxSwift
import RxCocoa

class NotificationCellView:UITableViewCell, Reusable {
    
    var disposeBag = DisposeBag()

    let date:UILabel = {
       let v = UILabel()
       v.translatesAutoresizingMaskIntoConstraints = false
       v.font = .systemFont(ofSize: 13, weight: .thin)
       v.textColor = UIColor.init(red: 133/255, green: 152/255, blue: 167/255, alpha: 1.0)
       return v
    }()
    
    
    let avatar:UIImageView = {
        let view = UIImageView()
        view.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameDescription:UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.font = .systemFont(ofSize: 13, weight: .thin)
        v.numberOfLines = 0
        v.textColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return v
     }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      setupConstraint_()
    }
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      setupConstraint_()
    }
    
    override func prepareForReuse() {
      super.prepareForReuse()
      disposeBag = DisposeBag()
    }
    

    func setupConstraint_() {
        let over_view = UIView()
        over_view.backgroundColor = .mainBackground
        over_view.layer.zPosition = 1
        over_view.clipsToBounds = true
        over_view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(over_view)
        over_view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        over_view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        over_view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        over_view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        over_view.addSubview(avatar)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.widthAnchor.constraint(equalToConstant: 32).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 32).isActive = true
        avatar.topAnchor.constraint(equalTo: over_view.topAnchor, constant: 5).isActive = true
        avatar.leadingAnchor.constraint(equalTo: over_view.leadingAnchor, constant: 16).isActive = true
        avatar.layer.cornerRadius = 16.0
        
        over_view.addSubview(nameDescription)
        nameDescription.makeAnchors { make in
            make.top(equalTo:over_view.top, constant:5)
            make.leading(equalTo:avatar.trailing, constant:16)
            make.trailing(equalTo:over_view.trailing, constant:-35)
            make.bottom(equalTo:over_view.bottom, constant:-16)
        }
        
        over_view.addSubview(date)
        date.translatesAutoresizingMaskIntoConstraints = false
        date.topAnchor.constraint(equalTo: over_view.topAnchor, constant: 5).isActive = true
        date.trailingAnchor.constraint(equalTo: over_view.trailingAnchor, constant: -8).isActive = true
    }
}



extension NotificationCellView {
    
    func setupCell(model:NotificationCellModel) {
        
        self.avatar.loadImageUsingUrlString(urlString: model.avatar)
        
        if model.type == "subscriber" {
            let text = "\(model.name)" + " новый подписчик"
            let fullText = text//String(model.name + " " + model.nameDescription)
            let ctc = fullText.count
            let stringe = fullText as NSString
            let attributedString = NSMutableAttributedString(string: stringe as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13.0, weight:.regular)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), range: NSMakeRange(0, ctc))
            let boldFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0, weight: .bold)]
            attributedString.addAttributes(boldFontAttribute, range: stringe.range(of: model.name))
            self.nameDescription.attributedText = attributedString
        } else if model.type == "event"{
            let fullText = String(model.name + " приглашает тебя стать спикером в комнате " + model.nameDescription)
            let ctc = fullText.count
            let stringe = fullText as NSString
            let attributedString = NSMutableAttributedString(string: stringe as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13.0, weight:.regular)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), range: NSMakeRange(0, ctc))
            let boldFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13.0, weight: .bold)]
            attributedString.addAttributes(boldFontAttribute, range: stringe.range(of: model.name))
            attributedString.addAttributes(boldFontAttribute, range: stringe.range(of: model.nameDescription))
            self.nameDescription.attributedText = attributedString
        }
        
        guard let model_date = model.date else {return}
        
        let date = (model_date / 60) / 60 >= 60 ? String((model_date / 60 / 60)) + " ч" : String((model_date / 60 / 60 )) + " м"
        
        self.date.text = date
    
    }
    
}


