/**
 * CustomerSelector — Centralized SOQL queries for Contact (Customer).
 */
public with sharing class CustomerSelector {

    public static Contact selectById(Id contactId) {
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Phone, AccountId
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];
        return contacts.isEmpty() ? null : contacts[0];
    }

    public static List<Contact> selectByAccountId(Id accountId) {
        return [
            SELECT Id, FirstName, LastName, Email, Phone
            FROM Contact
            WHERE AccountId = :accountId
        ];
    }

    public static Contact selectByEmail(String email) {
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Email, Phone, AccountId
            FROM Contact
            WHERE Email = :email
            LIMIT 1
        ];
        return contacts.isEmpty() ? null : contacts[0];
    }
}
