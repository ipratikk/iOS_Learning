//
//  ConversationTableViewCell.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 03/03/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName:"person.circle")?.withTintColor(.gray,
                                                                             renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize : 21, weight : .semibold)
        return label
    }()
    
    private let userMessageLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize : 19, weight : .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let userUnreadCountLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize : 21, weight : .semibold)
        return label
    }()
    
    private let attachmentLabel : NSMutableAttributedString = {
        let iconsSize = CGRect(x: 0, y: -5, width: 20, height: 20)
        let photoAttachment = NSTextAttachment()
        photoAttachment.image = UIImage(systemName: "photo")
        photoAttachment.bounds = iconsSize
        let att_string = NSMutableAttributedString()
        att_string.append(NSAttributedString(attachment: photoAttachment))
        att_string.append(NSAttributedString(string: " Photo Message"))
        return att_string
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height-20)/2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom + 10,
                                        width: contentView.width - 20 - userImageView.width,
                                        height: (contentView.height-20)/2)
    }
    
    public func configure(with model : Conversation){
        if model.latestMessage.text.contains("png") {
            self.userMessageLabel.attributedText = attachmentLabel
        }else{
            self.userMessageLabel.text = model.latestMessage.text
        }
        
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: {[weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get image url : \(error)")
            }
        })
    }
}
