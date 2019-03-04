//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Irais Gopar osorio on 3/2/19.
//  Copyright © 2019 Irais Gopar Osorio. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    let query = PFQuery(className: "Posts")
    
    //let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        myRefreshControl.addTarget(self, action: #selector(loadMorePosts), for: .valueChanged)
//        tableView.refreshControl =  myRefreshControl
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if(posts != nil){
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = loginViewController
        
        
    }
    
//    @objc func loadMorePosts(){
//        query.limit = query.limit + 20
//        self.tableView.reloadData()
//        self.myRefreshControl.endRefreshing()
//
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username!
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment!"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "comments")
        post.saveInBackground { (success, error) in
            if(success){
                print("comment saved")
            }else{
                print("Error saving comment")
            }
        }
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
