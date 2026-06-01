/**
 * RevenueService — Revenue aggregation and insights for restaurant owners.
 */
public with sharing class RevenueService {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInsights(Id restaurantId) {
        Map<String, Object> insights = new Map<String, Object>();

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
