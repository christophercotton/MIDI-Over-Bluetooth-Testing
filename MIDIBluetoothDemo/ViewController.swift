//
//  ViewController.swift
//  MIDIBluetoothDemo
//
//  Created by Christopher Fonseka on 23/09/2014.
//  Copyright (c) 2014 ROLI. All rights reserved.
//

import UIKit
import CoreAudioKit // At time of writing CoreAudioKit only works on iOS8 devices, not the simulator
import CoreMIDI

class ViewController: UIViewController  {

	var central		: CABTMIDICentralViewController
	var peripheral	: CABTMIDILocalPeripheralViewController
	var midi		: Midi
	
	@IBOutlet weak var latencyLabel: UILabel!
	
	
	required init(coder aDecoder: NSCoder)
	{
		central = CABTMIDICentralViewController()
		peripheral = CABTMIDILocalPeripheralViewController()
		midi = Midi()
		
		super.init(coder: aDecoder)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotLatency:", name: "latency", object: nil)
	}
	
	override func viewDidAppear(animated: Bool)
	{
		self.latencyLabel.text = "Pending"
	}

	/*
		When "Central" button is pressed, the CABTMIDICentralViewController takes over
		to set up the current device as a Bluetooth Central device, over which MIDI can be recieved
	*/
	@IBAction func setUpCentral(sender: AnyObject)
	{
		self.navigationController?.pushViewController(central, animated: true)
	}
	
	/*
		When "Peripheral" button is pressed, the CABTMIDILocalPeripheralViewController takes over
		to set up the current device as a Bluetooth Peripher device, over which MIDI can be sent
	*/
	@IBAction func setUpPeripheral(sender: AnyObject)
	{
		self.navigationController?.pushViewController(peripheral, animated: true)
	}	

	@IBAction func testButtonPressed(sender: AnyObject)
	{
	}
	
	/*
		When a note is pressed on the mysterious blue keyboard a note is sent, in addtion to a
		SYSEX message containing the current timestamp
	*/
	@IBAction func notePressed(sender: UIButton)
	{
		let note = sender.tag
		self.sendNoteOn(UInt8(note))
		
		midi.sendTimestamp()
	}
	
	/*
		This when a note on the blue keyboard is unpressed, send note off
	*/
	@IBAction func noteUnPressed(sender: UIButton)
	{
		let note = sender.tag
		self.sendNoteOff(UInt8(note))
	}
	
	func sendNoteOn(noteNo : UInt8)
	{
		let note      = noteNo
		let noteOn	  = [0x90, note, 127]
		
		let size  = UInt32(sizeof(UInt8) * 3)
		midi.sendBytes(noteOn, size: size)
	}
	
	func sendNoteOff(noteNo : UInt8)
	{
		let note	= noteNo
		let noteOff	= [0x80, note, 0]
	
		let size	= UInt32(sizeof(UInt8) * 3)
		midi.sendBytes(noteOff, size: size)
	}
	
	/*
		The callback is triggered by NSNotificationCenter.
		When a peripheral sends a timestamp message to the host, the host sends it back.
		The peripheral then decodes the timestamp, compares it to it's current timestamp,
		and reports half this value here, as an NSNotification.
	*/
	func gotLatency(notification : NSNotification)
	{
		let latency = midi.latency
		println("Last latency is \(latency)")
		
		dispatch_async(dispatch_get_main_queue(),
			{
				self.latencyLabel.text = String(latency) + "ms"
			})
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

