//
//  RecordsViewController.swift
//  TimerTest
//
//  Created by Alexander Kormanovsky on 24.03.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class Record {

    var duration: TimeInterval = 100
    lazy var currentSeconds = duration
    
    func reset() {
         
        currentSeconds = duration
    }
    
    func countDown() -> TimeInterval {
        if currentSeconds > 0 {
            currentSeconds -= 1.0
        }
        
        return currentSeconds
    }
    
}

class RecordsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private var seconds = TimeInterval()
    
    /// Using background timer because common Timer is getting suspended
    /// on table view scroll (because of schedule on main loop)
    private var timer = RepeatingTimer(timeInterval: 1)
    
    private var records: [Record] = []
    
    private var playingRecord: Record?
    
    private var playingCell: RecordTableViewCell? {
        guard let index = setPlayingRecordIndex() else {
            return nil
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        return tableView.cellForRow(at: indexPath) as? RecordTableViewCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = String(NSStringFromClass(RecordTableViewCell.self).split(separator: ".").last!)
        self.tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: "cell")
        
        for _ in 0..<100 {
            records.append(Record())
        }
    }
    
    // MARK: Playback
    
    /// Resume or start record
    func startRecord(with index: Int) {
        let record = records[index]
        
        playingRecord = record

        startTimer()
    }
    
    func stopPlayingNowRecord() {
        guard let record = playingRecord, let cell = playingCell else {
            return
        }
        
        record.reset()
        
        cell.seconds = record.duration
        cell.playButton.isSelected = false
        
        stopTimer()
    }
    
    func pausePlayingNowRecord() {
        stopTimer()
    }
    
    // MARK: Timer
    
    @objc private func countSeconds() {
        guard let record = self.playingRecord else {
            return
        }
        
        seconds = record.countDown()
        
        DispatchQueue.main.async {
            guard let cell = self.playingCell else {
                return
            }
            
            cell.seconds = self.seconds
        }
    }
    
    private func startTimer() {
        
        if timer.eventHandler == nil {
            timer.eventHandler = {
                self.countSeconds()
            }
        }
        
        timer.resume()
    }
    
    private func stopTimer() {
        timer.suspend()
    }
   
    private func setPlayingRecordIndex () -> Int? {
        records.firstIndex { $0 === playingRecord }
    }
}

extension RecordsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecordTableViewCell
        cell.delegate = self
        cell.recordIndex = indexPath.row
        
        let record = records[indexPath.row]
        cell.seconds = record.currentSeconds
         
        
        return cell
    }
    
}

extension RecordsViewController : RecordTableViewCellDelegate {
    func recordTableViewCellShouldStop(_ cell: RecordTableViewCell) {
        stopPlayingNowRecord()
    }
    
    
    func recordTableViewCellShouldStartPlaying(_ cell: RecordTableViewCell) {
        if cell !== playingCell || cell.timeLabel.text == "00:00", let delegate = cell.delegate {
            // stop previous record if any
            delegate.recordTableViewCellShouldStop(cell)
        }
        
        startRecord(with: cell.recordIndex)
    }
    
    func recordTableViewCellShouldPausePlaying(_ cell: RecordTableViewCell) {
        pausePlayingNowRecord()
    }
    
}

