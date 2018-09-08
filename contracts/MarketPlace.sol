//Project MarketPlace
//create by Nadezhda Vasilevska

pragma solidity 0.4.24;

//provides basic authorization control functions
contract Ownable {
    address public owner;
   
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "You don't have permission to perform this action.");
        _;
    }
}

//Math operations with safety checks that throw on error
//prevents underflow or overflow
library SafeMath{
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        //there is no case where this function can overflow/underflow
        uint256 c = a / b;
        return c;
    }
    
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

library MarketLib{
    using SafeMath for uint;
    
    struct MarketItems{
        string name;
        uint price;
        uint quantity;
        bool exists; 
    }

    function addQuantaty(MarketItems storage self, uint quantity) public {
        self.quantity = self.quantity.add(quantity);
    }
    
    function removeQuantity(MarketItems storage self, uint quantity) public {
        self.quantity = self.quantity.sub(quantity);
    }
    
    function CreateItem(string name, uint price, uint quantity) internal pure returns(MarketItems){
        return MarketItems({name: name, price: price, quantity: quantity, exists: true});
    }
}

contract MarketPlace is Ownable {
    
    using SafeMath for uint;
    using MarketLib for MarketLib.MarketItems;
   
    //bytes32 is items Id  (key, value)-use mapping instead of arrays
    mapping(bytes32 => MarketLib.MarketItems) items;
    bytes32[] onlyIds;
    
    modifier checkAvailability(bytes32 Id) {
        require(items[Id].exists, "Item does not exist. ");
        _;
    }
    
    modifier checkQuantity(bytes32 Id,uint quantity) {
        require(items[Id].quantity >= quantity && quantity > 0, "Sorry, not enought quantity in the storage. ");
        _;
    }
    
    //define contract events
    event logItemBought(bytes32 indexed ID, address indexed buyer, uint totalAmount, uint quantity, uint amountSent);
    event logItemAdded(bytes32  ID, string name, uint price, uint quantity);
    event logItemUpdated(bytes32  ID, string name, uint quantity);
    
    //1. buy item by ID & quantity
    function buy(bytes32 id, uint quantity) public 
    checkAvailability(id) 
    checkQuantity(id,quantity)
    payable {
       
        uint currentPrice = getPrice(id);
        uint totalPrice = currentPrice.mul(quantity);
        require(totalPrice <= msg.value,"Amount sent is less then the total price.");
       
        items[id].removeQuantity(quantity);
        emit logItemBought(id, msg.sender, totalPrice, quantity, msg.value); 
    } 
    
    //2. update the stoch of an Item 
    function update(bytes32 Id, uint newQuantity) public 
    onlyOwner 
    checkAvailability(Id){
        
        items[Id].addQuantaty(newQuantity);
        emit logItemUpdated(Id, items[Id].name, items[Id].quantity);
    }
    
    //3. add new product 
    function newProduct(string name, uint price, uint quantity) public 
     onlyOwner returns(bytes32 Id) {
     
        Id = bytes32(keccak256(name));
        
        require(!items[Id].exists, "Item already exist. ");
       
        MarketLib.MarketItems memory item = MarketLib.CreateItem(name, price, quantity);
        items[Id] = item;
        onlyIds.push(Id); 
        
        emit logItemAdded(Id, name, price, quantity);
    }
   
    //4. Get the name, price & stock  by items ID 
    function getProduct(bytes32 Id) public view returns(string, uint, uint) {
        return(items[Id].name, items[Id].price, items[Id].quantity);
    }
    
    //5. return an array of all product Ids. 
    function getProducts() public view returns(bytes32[]){
        return onlyIds;
    }
    
    //9. price can increase as the stock lowers 
    function getPrice(bytes32 Id) public view returns (uint) {
        uint itemPrice = items[Id].price;
        
        if(items[Id].quantity > 10 && items[Id].quantity <= 20){
            uint increaseBy2 = (itemPrice * 2) / 100;
            itemPrice = itemPrice.add(increaseBy2);
        }
        
        if(items[Id].quantity <= 10){
            uint increaseBy4 = (itemPrice * 4) / 100;
            itemPrice = itemPrice.add(increaseBy4);
        }
        
        return itemPrice;
    }
    
    //10. withdrow the funds from the contract
    function withdraw() public payable onlyOwner returns (bool){
        require(address(this).balance > 0, "Not enought funds");
        msg.sender.transfer(address(this).balance);        
        return true;
    }
    
}