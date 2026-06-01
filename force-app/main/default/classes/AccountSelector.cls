/**
 * AccountSelector — Centralized SOQL queries for Account (Restaurant).
 */
public with sharing class AccountSelector {

    public static Account selectFirstRestaurant() {
        List<Account> accs = [
            SELECT Id, Name, Type
            FROM Account
            LIMIT 1
        ];
        return accs.isEmpty() ? null : accs[0];
    }
}
