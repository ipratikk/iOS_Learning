//
//  ChatViewController.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 25/02/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

protocol ChatsViewService : UIViewController {
    var isNewConversation : Bool { get set }
    var otherUserEmail : String { get set }
    var conversationID : String? { get set }
    func listenForMessages(id : String, shouldScrollToBottom : Bool)
}

class ChatViewController: MessagesViewController, ChatsViewService {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public var otherUserEmail: String
    internal var conversationID: String?
    private var messages = [Message]()
    
    init(with email: String, id : String?) {
        self.conversationID = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "",
                      senderId: safeEmail,
                      displayName: "Me")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
    }
    
    private func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside{ [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: {[weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: {[weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {[weak self] _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func presentPhotoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like to attach a photo from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            self?.present(picker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {[weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            self?.present(picker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    internal func listenForMessages(id : String, shouldScrollToBottom : Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result{
            case .success(let messages):
                print("Success in getting messages :\(messages)")
                guard !messages.isEmpty else{
                    print("Messages are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom{
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("Failed to get messages : \(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationID{
            listenForMessages(id: conversationId, shouldScrollToBottom : true)
        }
    }
    
}

extension ChatViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let imageData = image.pngData(),
              let messageId = createMessageID(),
              let conversationId = conversationID,
              let name = self.title,
              let selfSender = selfSender else{
            return
        }
        
        let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
        
        // Upload Image
        StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: {[weak self] result in
            guard let strongSelf = self else{
                return
            }
            switch result{
            case .success(let urlString):
                print("Uploaded message photo : \(urlString)")
                
                guard let url = URL(string: urlString),
                      let placeholder = UIImage(systemName: "plus") else{
                    return
                }
                
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                
                let message = Message(sender: selfSender,
                                      messageId: messageId,
                                      sentDate: Date(),
                                      kind: .photo(media))
                
                DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                    if success{
                        print("Sent photo message")
                    }else{
                        print("Failed to send photo message")
                    }
                })
            case .failure(let error):
                print("Message photo upload error : \(error)")
            }
        })
        // Send Image
    }
}

extension ChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageID() else{
            return
        }
        print("Sending : \(text)")
        //        Send Message
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        if isNewConversation{
            // create new convo
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("Message sent")
                    self?.isNewConversation = false
                }
                else{
                    print("Message failed to send")
                }
            })
        }
        else{
            //append to convo
            guard  let conversationId = conversationID, let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail : otherUserEmail, name: name, newMessage: message, completion: {success in
                if success {
                    print("Message sent")
                }
                else{
                    print("Failed to send")
                }
            })
        }
    }
    
    private func createMessageID() -> String? {
        // Date, otherUserEmail, senderEmail, random Int
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("Created message id : \(newIdentifier)")
        
        return newIdentifier
    }
}

extension ChatViewController : MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self Sender is Nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
}

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
