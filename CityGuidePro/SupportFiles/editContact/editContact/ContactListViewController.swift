import UIKit

class ContactListViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties

    var contacts: [Contact] = []

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigationBar()
        loadContacts()
    }

    // MARK: - Private methods

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "ContactTableViewCell")
    }

    private func setupNavigationBar() {
        navigationItem.title = "Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactButtonTapped))
    }

    private func loadContacts() {
        // Load contacts from your data source
        // and assign them to the contacts property
    }

    @objc private func addContactButtonTapped() {
        // Handle the "Add Contact" button tap
    }

}

// MARK: - UITableViewDelegate

extension ContactListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle the contact selection
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Handle the contact deletion
        }
    }

}

// MARK: - UITableViewDataSource

extension ContactListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell

        let contact = contacts[indexPath.row]
        cell.configure(with: contact)

        return cell
    }

}
