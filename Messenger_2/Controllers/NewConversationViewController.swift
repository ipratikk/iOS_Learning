//
//  NewConversationViewController.swift
//  Messenger_2
//
//  Created by Goyal, Pratik on 22/02/21.
//

import UIKit
import JGProgressHUD
import RxSwift
import RxCocoa

class NewConversationViewController: UIViewController {
    
    public var completion : ((SearchResult) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [User]()
    private var results = [SearchResult]()
    
    private var hasFetched = false
    
    private let disposeBag = DisposeBag()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
//        table.isHidden = true
        table.register(NewConversationCell.self,
                       forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    
    private let noResultsLabel : UILabel  = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight : .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        searchBar.delegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        getAllUsers(with: "users") { result in
            switch result {
            case .success(let userList):
                self.users = userList
            case .failure(let error):
                print("Error : \(error)")
            }
        }
        searchBar.becomeFirstResponder()
        
        searchBar.rx.text.orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<[UserViewModel]> in
                if (query.isEmpty) {
                    return self.convertModel(with: self.users)
                }
                else{
                    return self.filterUsers(with: query, array: self.users).observe(on: MainScheduler.instance)
                }
                //            }
            }.bind(to: tableView.rx.items(cellIdentifier: NewConversationCell.identifier, cellType: NewConversationCell.self)) {
                (index,item,cell) in
                cell.configure(with: item)
            }.disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4, y: (view.height - 200)/2, width: view.width/2, height: 200)
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

extension NewConversationViewController : UISearchBarDelegate {
    public func convertModel(with data : [User]) -> Observable<[UserViewModel]> {
        return Observable.just(data).map{
            $0.map{
                UserViewModel(user: $0)
            }
        }
    }
    
    public func getAllUsers(with query : String, completion : @escaping (Result<[User],Error>) -> Void) {
        guard var currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        currentUserEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        DatabaseManager.shared.getDataFor(path: query){ result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let value):
                do {
                    let data = try JSONSerialization.data(withJSONObject: value, options: [])
                    let model = try JSONDecoder().decode([User].self, from: data).filter { $0.email != currentUserEmail }
                    completion(.success(model))
                }catch let error {
                    print(error)
                }
            }
        }
    }
    
    public func filterUsers(with query : String, array : [User]) -> Observable<[UserViewModel]> {
        
        guard var currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return convertModel(with: array)
        }
        
        currentUserEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let seq = array.filter{
            $0.name.lowercased().contains(query.lowercased()) && $0.email != currentUserEmail
        }
        return convertModel(with: seq)
    }
    
//    func filterUsers(with term: String) {
//        // update the UI: eitehr show results or show no results label
//        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
//            return
//        }
//
//        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
//
//        self.spinner.dismiss()
//
//        let results: [SearchResult] = users.filter({
//            guard let email = $0["email"], email != safeEmail else {
//                return false
//            }
//
//            guard let name = $0["name"]?.lowercased() else {
//                return false
//            }
//
//            return name.hasPrefix(term.lowercased())
//        }).compactMap({
//
//            guard let email = $0["email"],
//                  let name = $0["name"] else {
//                return nil
//            }
//
//            return SearchResult(name: name, email: email)
//        })
//
//        self.results = results
//
//        updateUI()
//    }
    
    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}


