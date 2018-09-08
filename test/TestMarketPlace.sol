pragma solidity 0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/MarketPlace.sol";


contract TestMarketPlace{
   // MarketPlace market = MarketPlace(DeployedAddresses.MarketPlace());
    MarketPlace market = new MarketPlace();
    string  itemName1 = "Apple";
    bytes32 returnedId1 = bytes32(keccak256(itemName1));

    string  itemName2 = "Bananas";
    bytes32 returnedId2 = bytes32(keccak256(itemName2));

    string  itemName3 = "Mango";
    bytes32 returnedId3 = bytes32(keccak256(itemName3));
        // add item
    function testAddingItems() public {
        
        uint itemPrice1 = 300 wei;
        uint itemQuantity1 = 2000;

        uint itemPrice2 = 400 wei;
        uint itemQuantity2 = 3000;

        uint itemPrice3 = 500 wei;
        uint itemQuantity3 = 4000;

        Assert.equal(market.newProduct(itemName1, itemPrice1, itemQuantity1), returnedId1, "Product Apple should be added.");
        Assert.equal(market.newProduct(itemName2, itemPrice2, itemQuantity2), returnedId2, "Product Bananas should be added.");
        Assert.equal(market.newProduct(itemName3, itemPrice3, itemQuantity3), returnedId3, "Product Mango should be added.");
    }
} 