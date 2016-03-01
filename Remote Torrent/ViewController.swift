//
//  ViewController.swift
//  Remote Torrent
//
//  Created by Adam Michael on 2/29/16.
//  Copyright © 2016 Adam LLC. All rights reserved.
//

import UIKit
import PusherSwift

class ViewController: UIViewController {
  let pusherKey = ""
  let channelName = "private-torrentfiles"
  let eventName = "client-newtorrent"
  let authEndpoint = "https://experiments.ajmichael.net/remotetorrent/auth"
  var channel: PusherChannel?

  @IBOutlet weak var filelabel: UILabel!
  var torrentUrl: NSURL?

  @IBAction func startTorrent() {
    if let url = torrentUrl as NSURL! {
      if let data = NSData(contentsOfURL: url) as NSData! {
        let encoded = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)

        var start = 0
        let chunk = 6000
        var piece = 1
        let pieces = 1 + encoded.characters.count / chunk
        while start < encoded.characters.count {
          var next = start + chunk
          if next > encoded.characters.count {
            next = encoded.characters.count
          }
          let substring = encoded[encoded.startIndex.advancedBy(start) ..< encoded.startIndex.advancedBy(next)]

          channel!.trigger(eventName, data: [
            "id": url.absoluteString,
            "piece": piece,
            "pieces": pieces,
            "data": substring
            ])
          start = next
          piece = piece + 1
          sleep(1)
        }
      }
    }
  }

  func setFile(url: NSURL) {
    torrentUrl = url
    filelabel.text = url.pathComponents?.last
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let pusher = Pusher(key: pusherKey, options: [ "authEndpoint": authEndpoint, "encrypted": true])
    pusher.connect()
    channel = pusher.subscribe(channelName)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

