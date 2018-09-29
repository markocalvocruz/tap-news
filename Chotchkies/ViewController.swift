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

extension String {
    func slice(from: String, to: String, options: NSString.CompareOptions = []) -> String? {
        return  (range(of: from, options: options)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
    func substringToFirstChar(of char: Character) -> String
    {
        guard let pos = self.range(of: String(char)) else { return self }
        // or  guard let pos = self.index(of: char) else { return self }
        let subString = self[..<pos.lowerBound]
        return String(subString)
    }

}

struct Article {
    var url: String
    var description: String
    var image: String?

    var domain: String?
    var author: String?
    var date: Date?
    
    init(description: String, xml: String, pubDate: Date?) {
        //print(xml)
        self.url = xml.slice(from: "\"", to: "\"")!
        self.description = description.substringToFirstChar(of: "(")
        if let meta = description.slice(from: "(", to: ")") {
            let array: [String] = meta.components(separatedBy: "/")
            if array.count == 1 {
                self.domain = array[0]
            } else if array.count > 1 {
                self.author = array[0]
                self.domain = array[1]
                self.date = pubDate
               // print(array)
            }
        } else {
            print("Error parsing: \(description)")
        }
     
    }
    
    
}

class ViewController: UIViewController {
    
    @IBAction func viewArticle(_ sender: UIButton) {
        performSegue(withIdentifier: "viewArticle", sender: self)

    }
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var domain_label: UILabel!
    @IBOutlet weak var author_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var next_page: UIButton!
    @IBAction func next_page(_ sender: UIButton) {
        if let feed = feed {
            if x < feed.items!.count - 1 {
                x += 1
            } else if x == feed.items!.count - 1 {
                x = 0
            }
        }
        updateUI()
    }
    
    
    var x = 0
    var feed: RSSFeed?
    var articles: [Article] = []
    var article: Article {
        return self.articles[x]
    }
    let parser = FeedParser(URL: feedURL)!
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd"
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
                    let article = Article(description: description, xml: xml, pubDate: pubDate)
                    strongSelf.articles.append(article)
                    
                }
                // Then back to the Main thread to update the UI.
                DispatchQueue.main.async {
                    strongSelf.updateUI()
                }

            }
            
        }
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        upSwipe.direction = .up
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc
    func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .up) {
            print("Swipe Up")
            performSegue(withIdentifier: "viewArticle", sender: self)

        }
        
        if (sender.direction == .right) {
            print("Swipe Right")
           
        }
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
    
    private func updateUI() {
        
        if feed != nil {
            self.description_label.text = self.articles[x].description
            self.author_label.text = self.articles[x].author
            self.domain_label.text = self.articles[x].domain
            if let date = self.articles[x].date {
              //  print("DATE: \(date) TO \(dateFormatter.string(for: date))")
                self.date_label.text = dateFormatter.string(for: date)!
            } else {
               // print("DATE NIL: \(self.articles[x].date)")
                self.date_label.text = "empty"
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

