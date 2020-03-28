//
//  RecordsViewController.swift
//  TimerTest
//
//  Created by Alexander Kormanovsky on 24.03.2020.
//  Copyright © 2020 test. All rights reserved.
//

import UIKit

class Record {
    
    var isPlaying = false
    var duration: TimeInterval = 100
    lazy var currentSeconds = duration
    
    func reset() {
        isPlaying = false
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
    
    // TODO: maybe optimize because is gets called by timer via playingCell every second
    private var playingRecordIndex: Int? {
        records.firstIndex { $0 === playingRecord }
    }
    
    private var playingCell: RecordTableViewCell? {
        guard let index = playingRecordIndex else {
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
        record.isPlaying = true
        playingRecord = record

        startTimer()
    }
    
    func stopPlayingNowRecord() {
        guard let record = playingRecord, let cell = playingCell else {
            return
        }
        
        record.reset()
        
        cell.seconds = record.duration
        cell.isPlaying = false
        
        stopTimer()
    }
    
    func pausePlayingNowRecord() {
        guard let record = playingRecord else {
            return
        }
        
        record.isPlaying = false
        
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
        cell.isPlaying = record.isPlaying
        
        return cell
    }
    
}

extension RecordsViewController : RecordTableViewCellDelegate {
    
    func recordTableViewCellShouldStartPlaying(_ cell: RecordTableViewCell) {
        if cell !== playingCell {
            // stop previous record if any
            stopPlayingNowRecord()
        }
        
        startRecord(with: cell.recordIndex)
    }
    
    func recordTableViewCellShouldPausePlaying(_ cell: RecordTableViewCell) {
        pausePlayingNowRecord()
    }
    
}

