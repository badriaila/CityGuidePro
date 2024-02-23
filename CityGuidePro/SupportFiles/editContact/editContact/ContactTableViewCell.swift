import UIKit

class Contact {
    var name: String
    var number: String
    
    init(name: String, number: String) {
        self.name = name
        self.number = number
    }
}

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    var contact: Contact?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 20))
        contentView.addSubview(nameLabel)
        
        numberLabel = UILabel(frame: CGRect(x: 10, y: 30, width: 100, height: 20))
        contentView.addSubview(numberLabel)
        
        deleteButton = UIButton(frame: CGRect(x: 200, y: 15, width: 60, height: 30))
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with contact: Contact) {
        self.contact = contact
        nameLabel.text = contact.name
        numberLabel.text = contact.number
    }
    
    @objc func deleteButtonTapped() {
        guard let contact = contact else { return }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DeleteContact"), object: nil, userInfo: ["contact": contact])
    }
}

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var contacts: [Contact] = []
    var contactsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create some sample contacts
        contacts.append(Contact(name: "John Doe", number: "123-456-7890"))
        contacts.append(Contact(name: "Jane Smith", number: "555-555-5555"))
        contacts.append(Contact(name: "Bob Johnson", number: "222-333-4444"))
        
        // Create the table view
        contactsTableView = UITableView(frame: view.bounds, style: .plain)
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        view.addSubview(contactsTableView)
        
        // Register the cell class
        contactsTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "ContactCell")
        
        // Listen for delete notifications
        NotificationCenter.default.addObserver(self, selector: #selector(deleteContact(_:)), name: NSNotification.Name(rawValue: "DeleteContact"), object: nil)
    }
    
    @objc func deleteContact(_ notification: Notification) {
        guard let contact = notification.userInfo?["contact"] as? Contact else { return }
        if let index = contacts.firstIndex(where: { $0 === contact }) {
            contacts.remove(at: index)
            contactsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        cell.configure(with: contacts[indexPath.row])
        return cell
    }
}

class EditContactViewController: UIViewController {
    var contacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the view
        view.backgroundColor = UIColor.white
        
        // Create the add button
        let addButton = UIButton(type: .system)
        addButton.setTitle("Add Contact", for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        view.addSubview(addButton)
        
        // Create the contacts table view
        let contactsTableView = UITableView(frame: CGRect(x: 0, y: 50, width: view.bounds.width, height: view.bounds.height - 50), style: .plain)
        contactsTableView.dataSource = self
        view.addSubview(contactsTableView)
        
        // Register the cell class
        contactsTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "ContactCell")
    }
    
    @objc func addButtonTapped() {
        // Show a pop-up view to add a new contact
    }
}

extension EditContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        cell.configure(with: contacts[indexPath.row])
        return cell
    }
}
