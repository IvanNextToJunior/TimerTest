//
//  RecordTableViewCell.swift
//  TimerTest
//
//  Created by Alexander Kormanovsky on 27.03.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit




protocol RecordTableViewCellDelegate : class {
    
    func recordTableViewCellShouldStartPlaying(_ cell: RecordTableViewCell)
    func recordTableViewCellShouldPausePlaying(_ cell: RecordTableViewCell)
    
}


class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    
    private let stoppedTitle = "▶️"
    private let playingTitle = "⏸"
    
    let formatter = RecordDurationFormatter()
    
    private var timer: Timer?
    
    var recordIndex: Int!
    
    var isPlaying: Bool = false {
        didSet {
            togglePlayButtonTitle(playing: isPlaying)
        }
    }
    
    var seconds: TimeInterval = 0 {
        didSet {
            updateTimeLabelText()
        }
    }
    
    weak var delegate: RecordTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        togglePlayButtonTitle(playing: false)
    }
    
    // MARK: UI Update
    
    private func togglePlayButtonTitle(playing: Bool) {
        playButton.setTitle(playing ? playingTitle : stoppedTitle, for: .normal)
    }
    
    func updateTimeLabelText() {
        DispatchQueue.main.async {
            self.timeLabel.text = self.formatter.format(self.seconds)
        }
    }
    
    // MARK: UI Events
    
    @IBAction func playButtonTouchUpInside(_ sender: UIButton) {
        isPlaying = !isPlaying
        
        if isPlaying {
            delegate?.recordTableViewCellShouldStartPlaying(self)
        } else {
            delegate?.recordTableViewCellShouldPausePlaying(self)
        }
    }
    
}
