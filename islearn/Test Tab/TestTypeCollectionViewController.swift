import UIKit

private let reuseIdentifier = "TestTypeCell"

private let reuseHeaderIdentifier = "Header"

class TestTypeCollectionViewController: UICollectionViewController {
    
    func createCompositionalLayout()->UICollectionViewLayout {
        return UICollectionViewCompositionalLayout {
            (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            var section : NSCollectionLayoutSection
            
            switch sectionIndex {
                
            case 0:
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                item.contentInsets = NSDirectionalEdgeInsets(
                    top : 10,
                    leading: 10,
                    bottom: 5,
                    trailing: 10
                )
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.3))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                section = NSCollectionLayoutSection(group: group)
                
            default :
                return nil
                
            }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        collectionView.register(UICollectionReusableView.self,forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TestTypeCollectionViewCell
        
        switch indexPath.item {
            
        case 0:
            cell.testTypeImage.image = UIImage(systemName: "graduationcap.fill")
            cell.testTypeName.text = "Classic Tests"
            cell.testTypeDescription.text = "Practice learnt concepts and earn XP"
            
        case 1:
            cell.testTypeImage.image = UIImage(systemName: "hand.wave.fill")
            cell.testTypeName.text = "Gesture Tests"
            cell.testTypeDescription.text = "Gain proficiency in gestures and earn XP"
            
        default:
            cell.testTypeImage.image = UIImage(systemName: "phe")
            cell.testTypeName.text = "Gesture Tests"
            cell.testTypeDescription.text = "The chosen undead. Kindle the bonfire."
        }
        
        //        cell.backgroundColor =
        cell.testTypeImage.layer.shadowOpacity = 0.5
        cell.testTypeImage.layer.shadowOffset = CGSize(width: 5, height: 10)
        cell.layer.cornerRadius = 20
        //        cell.layer.borderColor = UIColor..cgColor
        //        cell.layer.borderWidth = 1
        cell.testTypeDescription.textColor = .systemGray
        
        cell.chevronSymbol.titleLabel?.text = ""
        
        
        cell.chevronSymbol.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        
        return cell
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? TestListCollectionViewController{
            
            let indexPath = collectionView.indexPathsForSelectedItems!
            
            switch indexPath.first?.item {
            case 0:
                destinationVC.screenTitle = "Classic Test"
                destinationVC.testType = .classic
            case 1:
                destinationVC.screenTitle = "Gesture Test"
                destinationVC.testType = .gesture
            default:
                destinationVC.screenTitle = ""
            }
        }
        
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath)
        
        header.subviews.forEach { $0.removeFromSuperview() }
        
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 8
        
        let label = UILabel()
        label.text = "Choose a type of test"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .natural
        label.textColor = .accent
        label.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: horizontalPadding),
            label.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -horizontalPadding),
            label.topAnchor.constraint(equalTo: header.topAnchor, constant: verticalPadding),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -verticalPadding)
        ])
        
        return header
    }

}
