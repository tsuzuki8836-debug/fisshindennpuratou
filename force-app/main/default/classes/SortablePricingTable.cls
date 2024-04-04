public with sharing class SortablePricingTable implements Comparable {
    private final PricingTable__c pricingTable;

    public SortablePricingTable(PricingTable__c pricingTable) {
        this.pricingTable = pricingTable;
    }

    public Integer compareTo(Object otherObject) {
        if (!(otherObject instanceof SortablePricingTable)) {
            throw new SortException('Can\'t sort with incompatible type');
        }

        SortablePricingTable other = (SortablePricingTable) otherObject;
        String currentString = this.pricingTable.Name6__c;
        String otherString = other.pricingTable.Name6__c;
        String currentReplaced = currentString.replaceAll('\\D', '');
        String otherReplaced = otherString.replaceAll('\\D', '');

        Integer currentNumber = Integer.valueOf(currentReplaced);
        Integer otherNumber = Integer.valueOf(otherReplaced);

        if (currentNumber < otherNumber) return -1;
        if (currentNumber > otherNumber) return 1;

        return 0;
    }

    public static void sort(List<PricingTable__c> pricingTables) {
        
        List<SortablePricingTable> sortablePricingTables = new List<SortablePricingTable>();
        for (PricingTable__c pct : pricingTables) {
            sortablePricingTables.add(new SortablePricingTable(pct));
        }
    
        sortablePricingTables.sort();

        for (Integer i = 0; i < pricingTables.size(); i++) {
            pricingTables[i] = sortablePricingTables[i].pricingTable;
        }
      }

    public class SortException extends Exception {}
}