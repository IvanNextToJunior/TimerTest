//
//  RecordTableViewCell.swift
//  TimerTest
//
//  Created by Alexander Kormanovsky on 27.03.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit


class RecordDurationFormatter : DateComponentsFormatter {
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        unitsStyle = .positional
        zeroFormattingBehavior = .pad
    }
    
    /// Метод, преобразующий время в нужный формат
    func format(_ seconds: TimeInterval) -> String? {
        
        // Длительность будет отображаться как 1:00:00
        if seconds > 59.59 {
            allowedUnits = [.hour, .minute, .second]
        } else {
            allowedUnits = [.minute, .second]
        }
        
        return string(from: seconds)
    }
}


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
