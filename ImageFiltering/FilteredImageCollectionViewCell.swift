//
//  FilteredImageCollectionViewCell.swift
//  ImageFiltering
//
//  Created by Matthew Harrilal on 3/25/20.
//  Copyright © 2020 Matthew Harrilal. All rights reserved.
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class FilteredCellsCache {
    static var cellsCache = [String:UIImage]()
}

class FilteredImageCollectionViewCell: UICollectionViewCell {
    lazy var filterNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    lazy var filteredImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    static var identifier: String {
        return String(describing: self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(filterNameLabel)
        contentView.addSubview(filteredImageView)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            filterNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            filterNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),

            filteredImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            filteredImageView.topAnchor.constraint(equalTo: filterNameLabel.bottomAnchor, constant: 5),
            filteredImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            filteredImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func applyFilter(filterName: String) {
        if FilteredCellsCache.cellsCache[filterName] != nil {
            filteredImageView.image = FilteredCellsCache.cellsCache[filterName]
            return
        }

        let ciImage = CIImage(image: filteredImageView.image!, options: [CIImageOption.applyOrientationProperty : true])

        guard let filter = CIFilter(name: filterName) else { return }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let filteredImage = filter.outputImage

        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(filteredImage!, from: filteredImage!.extent)
        filteredImageView.image = UIImage(cgImage: cgImage!)

        FilteredCellsCache.cellsCache[filterName] = filteredImageView.image
    }
}
