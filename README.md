# RevenueCatPurchaseModuleDemo

This is a simple service under RevenueCar purchasing SDK. I made it to provide purchases in some apps i developed.
The module contains simply all basic functions to provide user purchases functionality:
* Loading products
* Purchasing products
* Restore product

RevenueCat has its own class hierarchy, different from what StoreKit provides.
For this reason, I added a wrapper class over their product classes and added logic whereby each product from the received list is sorted in descending order of its duration. Please keep it in mind if youll decide to use this code
