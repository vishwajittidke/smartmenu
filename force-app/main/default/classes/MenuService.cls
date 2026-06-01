/**
 * MenuService — Business workflows for menu management.
 */
public with sharing class MenuService {

    @AuraEnabled(cacheable=true)
    public static List<Menu_Item__c> getMenuForRestaurant(Id restaurantId) {
        return MenuSelector.selectAvailableByRestaurant(restaurantId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Menu_Item__c> getRecommendations(Id restaurantId) {
        return MenuSelector.selectTopSelling(restaurantId, 5);
    }

    @AuraEnabled
    public static Menu_Item__c createMenuItem(String name, String description, Decimal price,
                                               String category, Id restaurantId) {
        if (String.isBlank(name)) throw new BusinessException('Menu item name is required.');
        if (price == null || price <= 0) throw new BusinessException('Price must be positive.');
        if (restaurantId == null) throw new BusinessException('Restaurant is required.');

        Menu_Item__c item = new Menu_Item__c(
            Name = name,
            Description__c = description,
            Price__c = price,
            Category__c = category,
            Is_Available__c = true,
            Restaurant__c = restaurantId
        );
        insert item;
        return item;
    }

    @AuraEnabled
    public static Menu_Item__c toggleAvailability(Id menuItemId) {
        Menu_Item__c item = MenuSelector.selectById(menuItemId);
        if (item == null) throw new BusinessException('Menu item not found.');
        item.Is_Available__c = !item.Is_Available__c;
        update item;
        return item;
    }

    @AuraEnabled
    public static Menu_Item__c updatePrice(Id menuItemId, Decimal newPrice) {
        if (newPrice == null || newPrice <= 0) throw new BusinessException('Price must be positive.');
        Menu_Item__c item = MenuSelector.selectById(menuItemId);
        if (item == null) throw new BusinessException('Menu item not found.');
        item.Price__c = newPrice;
        update item;
        return item;
    }
}
