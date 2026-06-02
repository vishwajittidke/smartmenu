List<Menu_Item__c> allItems = [SELECT Id, Name, Description__c FROM Menu_Item__c];
List<Menu_Item__c> toDelete = new List<Menu_Item__c>();
for (Menu_Item__c item : allItems) {
    String name = item.Name != null ? item.Name.toLowerCase() : '';
    String descr = item.Description__c != null ? item.Description__c.toLowerCase() : '';
    if (name.contains('burger') || name.contains('beef') || name.contains('chicken') || name.contains('pork') || name.contains('meat') || name.contains('fish') ||
        descr.contains('burger') || descr.contains('beef') || descr.contains('chicken') || descr.contains('pork') || descr.contains('meat') || descr.contains('fish')) {
        toDelete.add(item);
    }
}
delete toDelete;
System.debug('Deleted non-veg items count: ' + toDelete.size());
