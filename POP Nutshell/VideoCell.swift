//
//  VideoCell.swift
//  POP Nutshell
//
//  Created by Patrick Bellot on 7/3/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    weak var titleLabel = UILabel()
    weak var descriptionLabel = UILabel()
    weak var videoThumbnailUrl = UIImageView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel!.text = nil
        descriptionLabel!.text = nil
        videoThumbnailUrl!.image = nil
    }
}