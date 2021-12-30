public class ProspectHandler {
    // BEFORE_INSERT
    // Add references to the realtors selling and purchasing the home
    public static void AttachRealtors(List<Prospect__c> insertedProspects) {
        Set<ID> accountIDs = new Set<ID>();
        Set<ID> propertyIDs = new Set<ID>();
        for (Prospect__c p : insertedProspects) {
            accountIDs.add(p.Account__c);
            propertyIDs.add(p.Property__c);
        }

        // Map properties to accounts
        Map<ID, ID> propertyToOwner = new Map<ID, ID>();
        for (Property__c property : [SELECT id, Property_Owner__c FROM Property__c WHERE id IN :propertyIDs]) {
            accountIDs.add(property.Property_Owner__c);
            propertyToOwner.put(property.id, property.Property_Owner__c);
        }

        // Map accounts to realtors
        Map<ID, ID> accountToRealtor = new Map<ID, ID>();
        for (Account a : [SELECT id, Realtor__c FROM Account WHERE id IN :accountIDs]) {
            accountToRealtor.put(a.id, a.Realtor__c);
        }
        
        // Update buying and selling realtor on each property
        for (Prospect__c p : insertedProspects) {
            p.Purchasing_Realtor__c = accountToRealtor.get(p.Account__c);

            ID propertyAccount = propertyToOwner.get(p.Property__c);
            p.Selling_Realtor__c = accountToRealtor.get(propertyAccount);
        }
    }

    // BEFORE_INSERT
    public static void ValidateInsertStatusAndApplyDate(List<Prospect__c> newProspects) {
        for (Prospect__c p : newProspects) {
            // Default NONE to FAVORITED
            if (GetStatus(p) == 'None') {
                SetStatus(p, 'Favorited');
            }

            // Error on Invalid Insertion Status
            Set<String> invalidInserts = new Set<String>{'Pending Sale', 'Sold', 'Cancelled'};

            String status = GetStatus(p);
            if (invalidInserts.contains(status)) {
                p.addError('Invalid Status. Cannot be Pending, Sold, or Cancelled at Insertion.');
            } else {
                TimestampOn(p, status);
            }
        }
    }

    // BEFORE_UPDATE
    public static void ApplyDates(List<Prospect__c> updates, Map<ID, Prospect__c> oldMap) {
        for (Prospect__c p : updates) {
            String newStatus = GetStatus(p);
            String oldStatus = GetStatus(oldMap.get(p.id));

            if (oldStatus != newStatus) {
                TimestampOn(p, newStatus);
            }
        }
    }

    // BEFORE_UPDATE
    public static void UpdatePendingSalePrices(List<Prospect__c> updates, Map<ID, Prospect__c> oldMap) {
        for (Prospect__c p : updates) {
            String newStatus = GetStatus(p);
            String oldStatus = GetStatus(oldMap.get(p.id));

            if (newStatus != 'Pending Sale') { continue; }
            if (oldStatus == 'Pending Sale') { continue; }
            
            // On newly pending sales,
            // Update sale price to counter offer (or offer if counter is null)
            if (p.Counter_Offer__c == null) {
                p.Sale_Price__c = p.Offer_Price__c;
            } else {
                p.Sale_Price__c = p.Counter_Offer__c;
            }
        }
    }

    public static void TimestampOn(Prospect__c p, String status) {
        switch on status {
            when 'Favorited' {
                p.Favorited_Date__c = System.today();
            }
            when 'Offer' {
                p.Offer_Date__c = System.today();
            }
            when 'Pending Sale' {
                p.Sale_Date__c = System.today();
            }
            when 'Sold' {
                p.Closing_Date__c = System.today();
            }
            when 'Cancelled' {
                p.Cancellation_Date__c = System.today();
            }
        }
    }

    // BEFORE_UPDATE
    public static void ValidateStatusChange(List<Prospect__c> updates, Map<ID, Prospect__c> oldMap) {
        for (Prospect__c p : updates) {
            String newStatus = GetStatus(p);
            String oldStatus = GetStatus(oldMap.get(p.id));

            if (!StatusChangeIsValid(oldStatus, newStatus)) {
                p.addError('Cannot move from status ' + oldStatus + ' to ' + newStatus);
            }
        }
    }

    public static Boolean StatusChangeIsValid(String oldValue, String newValue) {
        if (oldValue == newValue) { return true; }

        Boolean result = false;
        switch on oldValue {
            when 'None' {
                if (newValue == 'Favorited') { result = true; }
                if (newValue == 'Offer') { result = true; }
            }
            when 'Favorited' {
                if (newValue == 'Offer') { result = true; }
            }
            when 'Offer' {
                if (newValue == 'Pending Sale') { result = true; }
                if (newValue == 'Cancelled') { result = true; }
            }
            when 'Pending Sale' {
                if (newValue == 'Sold') { result = true; }
                if (newValue == 'Cancelled') { result = true; }
            }
        }
        return result;
    }

    public static String GetStatus(Prospect__c fromProspect) {
        return String.valueOf(fromProspect.Status__c);
    }

    public static void SetStatus(Prospect__c toProspect, String toValue) {
        toProspect.Status__c = toValue;
    }

    // BEFORE_UPDATE
    // All validations of nulls/changes of prices for each possible status or status change
    public static void ValidatePrices(List<Prospect__c> updates, Map<ID, Prospect__c> oldMap) {
        for (Prospect__c p : updates) {
            String newStatus = GetStatus(p);
            String oldStatus = GetStatus(oldMap.get(p.id));

            // Booleans used for validations....
            Boolean statusChange = newStatus == oldStatus;

            Boolean offerPriceNull = p.Offer_Price__c == null;
            Boolean counterOfferNull = p.Counter_Offer__c == null;
            Boolean salePriceNull = p.Sale_Price__c == null;

            Boolean offerPriceChange = p.Offer_Price__c != oldMap.get(p.id).Offer_Price__c;
            Boolean counterOfferChange = p.Counter_Offer__c != oldMap.get(p.id).Counter_Offer__c;
            Boolean salePriceChange = p.Sale_Price__c != oldMap.get(p.id).Sale_Price__c;
            // Booleans ready. Now start validations

            Boolean valid = true;
            switch on newStatus {
                when 'None', 'Favorited' {
                    // All prices must be null, and may not change
                    if (!offerPriceNull || offerPriceChange) { valid = false; }
                    if (!counterOfferNull || counterOfferChange) { valid = false; }
                    if (!salePriceNull || salePriceChange) { valid = false; }
                }
                when 'Offer' {
                    // Must have offer price, and no sale price
                    if (offerPriceNull) { valid = false; }
                    if (!salePriceNull) { valid = false; }
                    // CounterOffer may change multiple times or be null
                    
                    if (offerPriceChange && !statusChange) {
                        valid = false;
                    } // Offer price can only change if Offer just made
                }
                when 'Pending Sale' {
                    // Requires both offer price and sale price
                    if (offerPriceNull) { valid = false; }
                    if (salePriceNull) { valid = false; }

                    // Offer price and counter offer may not change
                    if (offerPriceChange || counterOfferChange) { valid = false; }
                    
                    if (salePriceChange && !statusChange) {
                        valid = false;
                    } // If sale price changed, its status must be new

                    // Sale price must be equal to counter offer, or offer if no counter
                    if (counterOfferNull) {
                        if (p.Offer_Price__c != p.Sale_Price__c) { valid = false; }
                    } else {
                        if (p.Counter_Offer__c != p.Sale_Price__c) { valid = false; }
                    }
                }
                when 'Sold', 'Cancelled' {
                    // Prices locked in.
                    if (offerPriceChange || counterOfferChange || salePriceChange) {
                        valid = false;
                    }
                    // Sold must have a sale price
                    if (newStatus == 'Sold' && salePriceNull) { valid = false; }
                }
                when else {
                    p.addError('Invalid status on prospect: ' + newStatus); 
                }
            }
        }
    }

    public static void PreventInvalidDeletions(List<Prospect__c> toDelete) {
        for (Prospect__c p : toDelete) {
            String status = GetStatus(p);
            switch on status {
                when 'Cancelled', 'Sold', 'Pending Sale', 'Offer' {
                    p.addError('Can\'t delete Prospect with status of ' + status);
                }
            }
        }
    }
}
