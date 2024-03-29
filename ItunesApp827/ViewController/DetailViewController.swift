//
//  DetailViewController.swift
//  ItunesApp827
//
//  Created by mac on 9/11/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import AVFoundation
class DetailViewController: UIViewController {

    @IBOutlet weak var detailTableView: UITableView!
    
    @IBOutlet weak var playlist: UIButton!
    
    var viewModel: ViewModel!
    var audioPlayer: AVAudioPlayer!
    var previousSelected: Int? //optional - could be nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetail()
    }
    
    @IBAction func addToPlaylistButton(_ sender: UIButton) {
        let track = viewModel.tracks[sender.tag]
        print(sender.tag)
        
        // display the alert
        if !viewModel.isInPlaylist(track: track){
        let alert = UIAlertController(title: "Add To Playlist", message: "You have just added the song \"\(track.name!)\" to the playlist", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
            viewModel.add(track: track)
        } else {
            let alert2 = UIAlertController(title: "Add To Playlist", message: "Sorry!!! This song is already in the playlist", preferredStyle: .alert)
            let okayAction2 = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alert2.addAction(okayAction2)
               present(alert2, animated: true, completion: nil)
        }
        
//        // add the track to the playlist if it is not in the playlist
//        if !viewModel.isInPlaylist(track: track){
//            viewModel.add(track: track)
//            print(CoreManager.shared.load().count)
//        }
    }
    
    @IBAction func priceButtonTapped(_ sender: UIButton) {
        let webVC = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webVC.viewModel = viewModel
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @objc func previewButtonTapped(sender: UIButton) {
        
        let track = viewModel.tracks[sender.tag]
        print(sender.tag)
        //check if its the fist time we tapped the play button - check if same button is tapped twice
        if previousSelected != nil && sender.tag != previousSelected {
            detailTableView.reloadRows(at: [IndexPath(row: previousSelected!, section: 1)], with: .top)
        }
        
        switch sender.currentImage == #imageLiteral(resourceName: "play") {
        case true:
            guard let endpoint = track.url, let url = URL(string: endpoint) else { return }
            //API Requests
            URLSession.shared.dataTask(with: url) { [weak self] (dat, _, _) in
                if let data = dat {
                    do {
                        DispatchQueue.main.async {
                            sender.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                            self?.previousSelected = sender.tag
                        }
                        //Set AVPlayer with Data from API Request
                        self?.audioPlayer = try AVAudioPlayer(data: data)
                        //AudioPlayer to play
                        self?.audioPlayer.play()
                    } catch {
                        print("Couldn't Play Data: \(error.localizedDescription)")
                        return
                    }
                }
            }.resume()
            
        case false:
            previousSelected = nil
            sender.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            audioPlayer.pause()
        }
        
    }
    
    

    private func setupDetail() {
        viewModel.delegate = self
        detailTableView.tableFooterView = UIView(frame: .zero)
    }
    
    

}

//MARK: TableView

extension DetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableCellOne.identifier, for: indexPath) as! TrackTableCellOne
            cell.album = viewModel.currentAlbum
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableCellTwo.identifier, for: indexPath) as! TrackTableCellTwo
            let track = viewModel.tracks[indexPath.row]
            cell.track = track
            
            cell.trackPreviewButton.tag = indexPath.row
            cell.addPlaylistButton.tag = indexPath.row
            cell.trackPreviewButton.addTarget(self, action: #selector(previewButtonTapped(sender:)), for: .touchUpInside)
            
            
            return cell
        }
    }
    
    
    
}

extension DetailViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected row: " + String(indexPath.row))
    }
}

//MARK: TrackDelegate
extension DetailViewController: TrackDelegate {
    func update() {
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}
