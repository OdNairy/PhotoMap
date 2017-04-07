//
//  LocationNotes.swift
//  PhotoMap
//
//  Created by Roman Gardukevich on 4/6/17.
//  Copyright © 2017 Roman Gardukevich. All rights reserved.
//

import UIKit

final class LocationNotesController: UIViewController {
    var location: Location? {
        didSet{
            guard isViewLoaded else {return}
            textView.text = location?.notes
        }
    }

    @IBAction func saveButtonTap(_ sender: Any) {
        guard let location = location else { return }
        location.notes = textView.text
        
        LocationDBService()?.update(location)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = location?.notes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }
}
