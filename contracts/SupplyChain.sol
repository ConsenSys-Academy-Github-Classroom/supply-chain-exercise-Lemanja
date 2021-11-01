// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {
  // <owner>
  address public owner;

  // <skuCount>
  uint public skuCount;

  // <items mapping>
  mapping(uint => Item) public items;

  // <enum State: ForSale, Sold, Shipped, Received>
  enum State{ForSale, Sold, Shipped, Received}

  // <struct Item: name, sku, price, state, seller, and buyer>
  struct Item {
      string name;
      uint sku;
      uint price;
      State state;
      address payable seller;
      address payable buyer;

  }
  /* 
   * Events
   */

  // <LogForSale event: sku arg>
  event ForSale(uint sku, string name);
  // <LogSold event: sku arg>
  event Sold(uint sku);
  // <LogShipped event: sku arg>
  event Shipped(uint sku);
  // <LogReceived event: sku arg>
  event Received(uint sku);


  /* 
   * Modifiers
   */

  // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract
  modifier verifyOwner(){
    require(
        msg.sender == owner,
        "Only the owner can call this function"
        );
    _;
}
  // <modifier: isOwner

  modifier verifyCaller (address _address) { 
    // require (msg.sender == _address); 
    require (msg.sender == _address,
    "Only verified role players can call this function"
    );
    _;
  }

  modifier restrictCaller(address _address) {
    require(
      msg.sender != _address,
      "This caller cannot perform this function"
      );
  _;
  }

  modifier paidEnough(uint _price) { 
    // require(msg.value >= _price); 
    require(msg.value >= _price,
    "You dont have enough money to make this purchase"
    );
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    // uint _price = items[_sku].price;
    uint _price = items[_sku].price;
    // uint amountToRefund = msg.value - _price;
    uint amountToRefund = msg.value - _price;
    // items[_sku].buyer.transfer(amountToRefund);
    items[_sku].buyer.transfer(amountToRefund);
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?
  modifier checkItemState(uint _sku, State state){
    require(
        items[_sku].state == state,
        "This item is for sale."
        );
    _;
  }

  // modifier forSale
  // modifier sold(uint _sku) 
  // modifier shipped(uint _sku) 
  // modifier received(uint _sku) 

  constructor() public {
    // 1. Set the owner to the transaction sender
    // 2. Initialize the sku count to 0. Question, is this necessary?
      owner = msg.sender;
      skuCount = 0;
  }

  
  function addItem(string memory _name, uint _price) public returns(bool){
    items[skuCount] = Item(_name, skuCount, _price, State.ForSale, msg.sender, address(0));
    emit ForSale(skuCount, _name);
    skuCount = skuCount + 1;
    return true;
}

/* Add a keyword so the function can be paid. This function should transfer money
  to the seller, set the buyer as the person who called this transaction, and set the state
  to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
  if the buyer paid enough, and check the value after the function is called to make sure the buyer is
  refunded any excess ether sent. Remember to call the event associated with this function!*/

function buyItem(uint sku)
  public
  payable
  checkItemState(sku,State.ForSale)
  paidEnough(items[sku].price)
  restrictCaller(items[sku].seller)
  checkValue(sku)
{
    items[sku].state = State.Sold;
    /*The address that calls the function is assigned as the buyer*/
    items[sku].buyer = msg.sender;
    emit Sold(items[sku].sku);
    items[sku].seller.transfer(items[sku].price);
}

/* Add 2 modifiers to check if the item is sold already, and that the person calling this function
is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
function shipItem(uint sku)
  public
  checkItemState(sku,State.Sold)
  verifyCaller(items[sku].seller)
{
    items[sku].state = State.Shipped;
    emit Shipped(items[sku].sku);
}

/* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
function receiveItem(uint sku)
  public
  checkItemState(sku,State.Shipped)
  verifyCaller(items[sku].buyer)
{
    items[sku].state = State.Received;
    emit Received(items[sku].sku);
}

/* We have these functions completed so we can run tests, just ignore it :) */
function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
    }


}