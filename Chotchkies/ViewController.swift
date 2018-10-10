//
//  ViewController.swift
//  Chotchkies
//
//  Created by Mark Calvo-Cruz on 3/14/18.
//  Copyright © 2018 hello U. All rights reserved.
//

import UIKit
import FeedKit
let feedURL = URL(string: "https://www.techmeme.com/feed.xml")!

extension Data
{
    func toString() -> String
    {
        return String(data: self, encoding: .utf8)!
    }
}

class ViewController: UIViewController {
    
    //MARK: IB Outlets
    @IBAction func viewArticle(_ sender: UIButton) {
//        performSegue(withIdentifier: "viewArticle", sender: self)

    }
  //  @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var index_label: UILabel!
    @IBOutlet weak var domain_label: UILabel!
  //  @IBOutlet weak var author_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var next_page: UIButton!
    @IBAction func next_page(_ sender: UIButton) {
        self.nextArticle()
    }

    var bookmarksPath: String?
    
    var x = 0
    var feed: RSSFeed?
    var articles: [Article] = []
    var article: Article {
        return self.articles[x]
    }
    var bookmarks: [Bookmark] = []
    let parser = FeedParser(URL: feedURL)!
    let dateFormatter = DateFormatter()
    
    //MARK: VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd"
        self.view.backgroundColor = #colorLiteral(red: 0.8549019608, green: 0.9176470588, blue: 0.9450980392, alpha: 1)
        self.description_label.textColor = #colorLiteral(red: 0.1176470588, green: 0.1882352941, blue: 0.2470588235, alpha: 1)
        self.initiateSwipeGestures([.up, .right, .left, .down])
        self.description_label.font = UIFont(name: "Marion", size: 25.0)
        self.domain_label.font = UIFont(name: "Marion-Italic", size: 20.0)
        self.index_label.font = UIFont(name: "Marion", size: 20.0)

        bookmarks = retrieveBookmarksFromPlist()
        
        
        // Parse asynchronously, not to block the UI.
        parser.parseAsync { [weak self] (result) in
            if let strongSelf = self {
            //    print(result.rssFeed?.items?.forEach { print( "\($0.pubDate) - \($0.author) - \($0.title!)")})
              //  print("HI")
                strongSelf.feed = result.rssFeed
                for item in (strongSelf.feed?.items)! {
                    let pubDate = item.pubDate
                    let xml = item.description!
                    let author = self?.getAuthor(str: item.title!)
                    let description = item.title!
                    let article = Article(description: description, xml: xml, pubDate: pubDate)/**
                    let bookmark = Bookmark(article: article)
                    let encoder = PropertyListEncoder()
                    encoder.outputFormat = .xml
                    do {
                        let data = try encoder.encode(bookmark)
                        print(data.toString())
                    } catch {
                        print(error)
                    }**/
                    strongSelf.articles.append(article)
                    
                }
                // Then back to the Main thread to update the UI.
                DispatchQueue.main.async {
                    strongSelf.updateUI()
                }
            }
        }
    }
    
    private func initiateSwipeGestures(_ gestures: [SwipeGesture]) {
        if gestures.contains(.up) {
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
            swipeUp.direction = .up
            self.view.addGestureRecognizer(swipeUp)
        }
        if gestures.contains(.right) {
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
            swipeRight.direction = .right
            self.view.addGestureRecognizer(swipeRight)
        }
        if gestures.contains(.left) {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
            swipeLeft.direction = .left
            self.view.addGestureRecognizer(swipeLeft)
            
        }
        if gestures.contains(.down) {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
            swipeDown.direction = .down
            self.view.addGestureRecognizer(swipeDown)
        }

    }
    
    private func retrieveBookmarksFromPlist() -> [Bookmark] {
        var arr: [Bookmark] = []
        //Read the PLIST - pull bookmarks from plist
        if let path = Bundle.main.path(forResource: "Bookmarks", ofType: "plist") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decoder = PropertyListDecoder()
                arr = try decoder.decode([Bookmark].self, from: data)
            }
            catch {
                print(error)
            }
        } else {
            print ("could not access Bookmarks.plist")
        }
        return arr
    }
    
    @objc
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            self.handleSwipeUp(sender)
        case .right:
            self.handleSwipeRight(sender)
        case .left:
            self.handleSwipeLeft(sender)
        case .down:
            self.handleSwipeDown(sender)
        default: break
        }
    }
    
    @objc
    private func handleSwipeUp(_ sender:UISwipeGestureRecognizer) {
        print("Swipe Up")
        performSegue(withIdentifier: "viewArticle", sender: self)

    }
    @objc
    private func handleSwipeDown(_ sender:UISwipeGestureRecognizer) {
        print("Swipe Down")
        self.bookmarkArticle()
        
    }
    @objc
    private func handleSwipeRight(_ sender:UISwipeGestureRecognizer) {
        print("Swipe Right")
     //   self.nextArticle()
        
    }
    @objc
    private func handleSwipeLeft(_ sender:UISwipeGestureRecognizer) {
        print("Swipe Left")
        self.previousArticle()
        
    }
    private func getAuthor(str: String) -> String {
        let startTrim = str.lastIndex(of: "(")
        let endTrim = str.lastIndex(of: "/")
        if let startTrim = startTrim,
            let endTrim = endTrim {
            return String(str[startTrim...endTrim])
        } else {
            return ""
        }
    }
    
    private func nextArticle() {
        if let feed = feed {
            if x < feed.items!.count - 1 {
                x += 1
            } else if x == feed.items!.count - 1 {
                x = 0
            }
        }
        updateUI()
    }
    
    private func previousArticle() {
        //TODO: Implement code
    }
    private func bookmarkArticle(_ param: Article? = nil) -> Bookmark? {
        let x = param ?? article
        let og = bookmarks.count
        let bookmark = Bookmark(article: x)
        //TODO: Implement code
        if let path = Bundle.main.path(forResource: "Bookmarks", ofType: "plist") {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            do {
                let data = try encoder.encode(bookmark)
                try data.write(to: URL(fileURLWithPath: path))
                bookmarks.append(bookmark)
            } catch {
                print(error)
            }
        }
        if bookmarks.count > og {
            print("Successfully added \(bookmark.article.description)")
            return bookmark
        } else {
            print("error saving bookmark")
            print(bookmarks.count)
        }
        print(bookmarks.map { $0.article.description})
        return nil
    }
    private func updateUI() {
        
        if feed != nil {
            self.index_label.text = "\(x + 1) of \(articles.count)"
            self.description_label.text = self.articles[x].description
          //  self.author_label.text = self.articles[x].author
            self.domain_label.text = "Source: \(self.articles[x].author), \(self.articles[x].domain!)"
            if let date = self.articles[x].date {
              //  print("DATE: \(date) TO \(dateFormatter.string(for: date))")
                //self.date_label.text = dateFormatter.string(for: date)!
            } else {
               // print("DATE NIL: \(self.articles[x].date)")
              //  self.date_label.text = "empty"
            }
        }
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "viewArticle" {
            assert(segue.destination.isKind(of: WebViewController.self))
            let vc = segue.destination as! WebViewController
            vc.url_string = self.article.url

        }
    }


}

enum SwipeGesture {
    case up
    case down
    case left
    case right
}
