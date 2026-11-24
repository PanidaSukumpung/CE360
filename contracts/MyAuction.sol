// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 < 0.9.0;

import "./Auction.sol";
contract MyAuction is Auction {
    Product public product;
    AuctionState public STATE;
    uint256 public endTime;
    uint256 public highestBid;
    address public highestBidder;
    address[] public bidders;

    mapping (address => uint256) public bids; //address ของผู้ประมูล(เป็นkey) => จำนวนเงินที่ประมูล

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

     modifier notAnOwner() {
        require(msg.sender != owner, "Owner cannot call this function");
        _;
    }
    modifier onGoingAuction() {
        require(STATE == AuctionState.STARTED, "Auction is not ongoing");
        _;
    }
    constructor (string memory _brand, string memory _serialNumber , uint256 _duration) {
        owner = payable(msg.sender);
        product = Product(_brand, _serialNumber);
        STATE = AuctionState.STARTED;
        endTime = block.timestamp + _duration * 1 seconds;
    }
    

   function bid()  external payable override notAnOwner onGoingAuction {
        //require(block.timestamp < endTime, "Auction has ended");
        require(msg.value + bids[msg.sender] > highestBid, "Bid amount must be higher than the current highest bid");
        require(msg.sender != highestBidder, "You are already the highest bidder");
        highestBidder = msg.sender;
        if(bids[msg.sender] ==0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender] += msg.value;
        highestBid = bids[msg.sender];
        emit BidEvent(msg.sender, bids[msg.sender], block.timestamp);
   }
    //ดูรายยอดเงินที่ประมูลของตัวเองและผู้อื่น
    function getMyBid(address bidder) external view  override returns(uint256) {
        return bids[bidder]; //bidsมาจากตาราง mapping (address => uint256) public bids;
    }


    //owner function
    //จบการประมูล
    function endAuction() external  override onlyOwner onGoingAuction{
        STATE = AuctionState.ENDED;
        emit EndEvent("Auction has ended", block.timestamp); //block เป็น global object ที่ทุก tx จะมี
    }

    //ยกเลิกการประมูล
    function cancelAuction()  external override onlyOwner onGoingAuction{
        STATE = AuctionState.CANCELLED;
        emit CancelEvent("Auction has been cancelled", block.timestamp);
    }

    //ระบบกลาง | shared function
    //ถอนเงิน
    // ถอนเงิน
function withdraw() external override {
    uint256 amount = 0;
    address payable withdrawer = payable(msg.sender);

    require(STATE != AuctionState.STARTED, "Auction is still ongoing");

    if (withdrawer == owner) { // Owner can withdraw the highest bid
        require(STATE == AuctionState.ENDED, "Owner can only withdraw after auction ended");
        require(bids[highestBidder] > 0, "No funds to withdraw for highest bidder");

        amount = highestBid;
        bids[highestBidder] = 0; // Reset the highest bidder's bid
    } else { // Other bidders can withdraw their bids
        bool allowed = ((STATE == AuctionState.ENDED && withdrawer != highestBidder) ||
            (STATE == AuctionState.CANCELLED)) &&
            bids[withdrawer] > 0;

        require(allowed, "You are not allowed to withdraw");

        amount = bids[withdrawer];
        bids[withdrawer] = 0;
    }

    (bool sent, ) = payable(withdrawer).call{value: amount}("");
    require(sent, "Failed to send Ether");

    emit WithdrawnEvent(withdrawer, amount, block.timestamp);
}

// ดูรายละเอียดสินค้า
function getProductInfo()
    external
    view
    override
    returns (string memory, string memory)
{
    return (product.Brand, product.SerialNumber);
}
}