//
//  ConversationViewController.swift
//  MapKitTutorial
//
//  Created by Zohar Mosseri on 26/11/2023.
//

import Foundation
import UIKit
import FirebaseAuth


class ConversationViewController : UIViewController{
    
    //todo change event to Conversation
    private var conversations = [Event]()
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true // if there are no conversations so we want another message to show
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return table
    }()
    
    private let noConversationsLabel : UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 12
        label.text = "No Conversations"
        label.textColor = .gray
        label.isHidden = true
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(tableView)
        scrollView.addSubview(noConversationsLabel)
        //Conversations
        //setupTableView()
        fetchConversations()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2,
                                            width: view.width-20,
                                            height: 100)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let LVC = LoginViewController()
            let nav = UINavigationController(rootViewController: LVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    /*
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    */
    private func fetchConversations(){
        
    }
    
}
/*
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }

    func openConversation(_ model: Conversation) {
        let SCVC = SingleChatViewController(with: model.otherUserEmail, id: model.id)
        SCVC.title = model.name
        SCVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(SCVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                if !success {
                    // add model and row back and show error alert

                }
            })

            tableView.endUpdates()
        }
    }
}
*/
