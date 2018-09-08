var MarketPlace = artifacts.require("./MarketPlace.sol");

//https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/test/helpers/expectThrow.js
var expectThrow = async function(promise,message) {
    try {
        await promise;
      } catch (error) {
        // Message is an optional parameter here
        if (message) {
          assert(
            error.message.search(message) >= 0,
            'Expected \'' + message + '\', got \'' + error + '\' instead',
          );
          return;
        } else {
          // TODO: Check jump destination to destinguish between a throw
          //       and an actual invalid jump.
          const invalidOpcode = error.message.search('invalid opcode') >= 0;
          // TODO: When we contract A calls contract B, and B throws, instead
          //       of an 'invalid jump', we get an 'out of gas' error. How do
          //       we distinguish this from an actual out of gas event? (The
          //       ganache log actually show an 'invalid jump' event.)
          const outOfGas = error.message.search('out of gas') >= 0;
          const revert = error.message.search('revert') >= 0;
          assert(
            invalidOpcode || outOfGas || revert,
            'Expected throw, got \'' + error + '\' instead',
          );
          return;
        }
      }
      assert.fail('Expected throw not received');
}

contract('MarketPlace', async (accounts) => {

    const market = await MarketPlace.deployed();

    const itemName1 = "Apple";
    const itemPrice1 = 300 ;
    const itemQuantity1 = 3000;

    const itemName2 = "Bananas";
    const itemPrice2 = 400;
    const itemQuantity2 = 4000;

    const itemName3 = "Mango";
    const itemPrice3 = 500;
    const itemQuantity3 = 5000;

    const account_owner = accounts[0];
    const account_buyer = accounts[2];
    
    //test function newProduct()
    it("should add new item", async () => {

        var returnedID1 = await market.newProduct(itemName1, itemPrice1, itemQuantity1);
        var returnedID2 = await market.newProduct(itemName2, itemPrice2, itemQuantity2);
        var returnedID3 = await market.newProduct(itemName3, itemPrice3, itemQuantity3);

        assert(returnedID1.receipt.status == 1, 'adding apples was unsuccessful.');
        assert(returnedID2.receipt.status == 1, 'adding bananas was unsuccessful.');
        assert(returnedID3.receipt.status == 1, 'adding mangos was unsuccessful.');
    });

    //test function newProduct() for duplicates
    it("should not add existing item", async () => {

        await expectThrow(market.newProduct(itemName1, itemPrice1, itemQuantity1)); // should throw exception
        //should not have more than 3 products ;)
        console.log(await market.getProducts());
    }); 
    
    //test function getProducts()
    it("should return all items in market", async () => {
        //use call for view functions
        let products = await market.getProducts.call();
        //www.chaijs.com/guide/styles/
        assert.lengthOf(products, 3, "Ups.. ;)");
    });
    
    // test function getProduct(id)
    it("should return item by id ", async () => {

        var products = await market.getProducts.call();
        var returnedID = products[0];//item id

        var item1 = await market.getProduct.call(returnedID);

        //The assert.strictEqual() method tests if two values are equal, using the === operator.
        assert.strictEqual(item1[0], itemName1, 'Names do not match ');
    });
    //test buy() function
    it("should buy items, by anyone", async () => {

        var products = await market.getProducts.call();
        var returnedID = products[0];//item id

        await market.buy(returnedID, 5, { value: itemPrice1 * 5 , from: account_buyer});
        await market.buy(returnedID, 2, { value: itemPrice1 * 2 , from: account_owner});
        var item = await market.getProduct.call(returnedID);
        //The assert.strictEqual() method tests if two values are equal, using the === operator.
        assert.strictEqual(Number(item[2]), itemQuantity1 - 7, 'Quantity do not match');
    });

    it("Check if enought value is sent", async function () {
        let market = await MarketPlace.deployed();

        var products = await market.getProducts.call();
        var returnedID = products[0];//item id

        await expectThrow( market.buy(returnedID, 3, { value: itemPrice1}));
    });
    //test function update()
    it("should update item quantity", async () => {
        let market = await MarketPlace.deployed();

        var products = await market.getProducts.call();
        var returnedID1 = products[0];

        //get quantity before update
        const item = await market.getProduct(returnedID1);
        var test1 = Number(item[2])+ 100;

        await market.update(returnedID1, 100);
        
        //check quantity after ubdate
        const itemAfterUpdate = await market.getProduct(returnedID1);
        var test2 = Number(itemAfterUpdate[2]);

        assert.equal(test2,test1, 'Incorrectly updated quantity of the product');
    });
    
    //test function withdrow() by owner
    it("owner should withdraw the funds", async () => {
        let market = await MarketPlace.deployed();

        var products = await market.getProducts.call();
        var returnedID = products[0];//item id
       
        await market.buy(returnedID, 5, { value: itemPrice1 * 5 });
        var receiptWithdraw = await market.withdraw();
        assert(receiptWithdraw.receipt.status == 1, 'Money are not transferred. Value of receiptWithdraw is ' + receiptWithdraw.receipt.status);               
    });

    //test function withdrow() by notOwner
    it("everyone can withdraw the funds", async () => {
        let market = await MarketPlace.deployed();

        var products = await market.getProducts.call();
        var returnedID = products[0];//item id
        
        await market.buy(returnedID, 5, { value: itemPrice1 * 5 });

        const balanceBefore = await web3.eth.getBalance(account_owner);
        console.log(balanceBefore);

        await expectThrow(market.withdraw({from: account_buyer}));

        const balanceAfter= await web3.eth.getBalance(account_owner);
        console.log(balanceAfter);
    });

});