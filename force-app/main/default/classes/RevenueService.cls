/**
 * RevenueService — Revenue aggregation and insights for restaurant owners.
 */
public with sharing class RevenueService {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInsights(Id restaurantId) {
        if (restaurantId == null) {
            Account acc = AccountSelector.selectFirstRestaurant();
            if (acc != null) {
                restaurantId = acc.Id;
            }
        }

        Map<String, Object> insights = new Map<String, Object>();
        insights.put('restaurantId', restaurantId);

        // Fetch Restaurant details
        if (restaurantId != null) {
            List<Account> accs = [
                SELECT Id, Name, Cuisines__c, Opening_Hours__c, Location_Area__c
                FROM Account
                WHERE Id = :restaurantId
                LIMIT 1
            ];
            if (!accs.isEmpty()) {
                Account acc = accs[0];
                insights.put('restaurantName', acc.Name);
                insights.put('restaurantCuisines', acc.Cuisines__c);
                insights.put('restaurantHours', acc.Opening_Hours__c);
                insights.put('restaurantLocation', acc.Location_Area__c);
            }
        }

        // Total revenue + order count
        AggregateResult[] revenueAgg = OrderSelector.selectRevenueByRestaurant(restaurantId);
        if (!revenueAgg.isEmpty()) {
            insights.put('totalRevenue', revenueAgg[0].get('totalRevenue'));
            insights.put('completedOrders', revenueAgg[0].get('orderCount'));
        }

        // Average order value
        AggregateResult[] avgAgg = [
            SELECT AVG(Total__c) avgOrder
            FROM Order__c
            WHERE Restaurant__c = :restaurantId AND Status__c = 'Completed'
        ];
        if (!avgAgg.isEmpty()) {
            insights.put('averageOrderValue', avgAgg[0].get('avgOrder'));
        }

        // Top selling items
        List<Menu_Item__c> topItems = MenuSelector.selectTopSelling(restaurantId, 5);
        insights.put('topSellingItems', topItems);

        // Review summary
        insights.put('reviewSummary', ReviewService.generateSummary(restaurantId));

        // Orders by status breakdown
        AggregateResult[] statusBreakdown = [
            SELECT Status__c, COUNT(Id) cnt
            FROM Order__c
            WHERE Restaurant__c = :restaurantId
            GROUP BY Status__c
        ];
        Map<String, Integer> statusMap = new Map<String, Integer>();
        for (AggregateResult ar : statusBreakdown) {
            statusMap.put((String) ar.get('Status__c'), (Integer) ar.get('cnt'));
        }
        insights.put('ordersByStatus', statusMap);

        return insights;
    }
}
