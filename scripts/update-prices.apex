List<Menu_Item__c> items = [SELECT Id, Name, Price__c FROM Menu_Item__c];
List<Menu_Item__c> toUpdate = new List<Menu_Item__c>();
for (Menu_Item__c item : items) {
    if (item.Name.contains('Paneer')) {
        item.Price__c = 249.00;
        toUpdate.add(item);
    }
}
if (!toUpdate.isEmpty()) {
    update toUpdate;
    System.debug('Updated ' + toUpdate.size() + ' menu item prices.');
}
