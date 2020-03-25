//
//  ViewController.swift
//  ImageFiltering
//
//  Created by Matthew Harrilal on 3/25/20.
//  Copyright © 2020 Matthew Harrilal. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class FilterImageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImagePickerDelegate {

    private let filterDataSource: [CIFilter] = [.discBlur(), .vignette(), .sepiaTone(), .vibrance(), .gloom(), .gaussianBlur(), .unsharpMask()]

    private var shouldChainFilters: Bool = false

    private var currentImage: UIImage?

    private var imagePicker: ImagePicker!

    private lazy var imageView: UIImageView = {
        let v = UIImageView(frame: CGRect.zero)
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        v.image = UIImage(named: "airtime")
        return v
    }()

    private lazy var chainFiltersButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitle("Chain Filters", for: .normal)
        v.backgroundColor = .green
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 10
        return v
    }()

    private lazy var galleryButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitle("Gallery", for: .normal)
        v.backgroundColor = .red
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 10
        return v
    }()

    private var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 300, height: 250)
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let v = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        v.dataSource = self
        v.delegate = self
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.register(FilteredImageCollectionViewCell.self, forCellWithReuseIdentifier: FilteredImageCollectionViewCell.identifier)
        return v
    }()

    private var currentFilter: CIFilter? {
        didSet {
            guard let filter = currentFilter else { return }
            applyFilter(filterName: filter.name)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(collectionView)
        view.addSubview(chainFiltersButton)
        view.addSubview(galleryButton)

        chainFiltersButton.addTarget(self, action: #selector(chainFiltersButtonAction), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(galleryButtonAction), for: .touchUpInside)

        self.imagePicker = ImagePicker(presentationController: self, imagePickerDelegate: self)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),

            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.widthAnchor.constraint(equalTo: view.widthAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 400),

            chainFiltersButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            chainFiltersButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            chainFiltersButton.widthAnchor.constraint(equalToConstant: 150),
            chainFiltersButton.heightAnchor.constraint(equalToConstant: 100),

            galleryButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            galleryButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            galleryButton.widthAnchor.constraint(equalToConstant: 150),
            galleryButton.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    func applyFilter(filterName: String) {
        var ciImage: CIImage!

        guard let filter = CIFilter(name: filterName) else { return }

        if let image = imageView.image, shouldChainFilters {
            ciImage = CIImage(image: image)
        } else if let currentImage = currentImage {
            ciImage = CIImage(image: currentImage)
        } else {
            ciImage = CIImage(image: UIImage(named: "airtime")!, options: [CIImageOption.applyOrientationProperty : true])
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        let filteredImage = filter.outputImage

        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(filteredImage!, from: filteredImage!.extent)
        imageView.image = UIImage(cgImage: cgImage!)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilteredImageCollectionViewCell.identifier, for: indexPath) as! FilteredImageCollectionViewCell

        let filter = filterDataSource[indexPath.row]

        cell.filterNameLabel.text = filter.name
        cell.filteredImageView.image = UIImage(named: "airtime")
        cell.applyFilter(filterName: filter.name)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = filterDataSource[indexPath.row]
        currentFilter = filter
    }

    @objc private func chainFiltersButtonAction() {
        shouldChainFilters = !shouldChainFilters
        chainFiltersButton.backgroundColor = shouldChainFilters ? .red : .green
        chainFiltersButton.setTitle(shouldChainFilters ? "Chaining Filters" : "Chain Filters", for: .normal)
    }

    @objc private func galleryButtonAction(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }

    func didSelect(image: UIImage?) {
        currentImage = image
        self.imageView.image = image
    }
}

