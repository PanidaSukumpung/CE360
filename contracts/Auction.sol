// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.8.0 < 0.9.0;

abstract contract Auction {
   //เจ้าของ
   address payable public owner ;
   //รายละเอียดสินค้า
   struct Product {
     string Brand;
     string SerialNumber;
   }
   //สถานะการประมูล
   enum AuctionState { STARTED , ENDED , CANCELLED }
    //client funtion

    //ยื่นประมูล | ส่งเงินมาด้วย
    function bid() virtual external payable ;
    //ดูรายยอดเงินที่ประมูลของตัวเองและผู้อื่น
    function getMyBid(address bidder) virtual external view returns(uint256);


    //owner function
    //จบการประมูล
    function endAuction()  virtual external ;

    //ยกเลิกการประมูล
    function cancelAuction() virtual external ;



    //ระบบกลาง | shared function
    //ถอนเงิน
    function withdraw() virtual external ;

    //ดูรายละเอียดสินค้า
    function getProductInfo()  virtual external view returns(string memory , string memory);

    
    
    //event
    //มีการยื่นประมูล (Bidevent)
    event BidEvent(address bidder , uint256 amount , uint256 timestamp ); //ผู้ประมูล , จำนวนเงิน , เวลาในblockchain
    //มีการสินสุดการประมูล (ended event)
    event EndEvent(string message , uint256 timestamp );
    //มีการยกเลิก
    event CancelEvent(string message , uint256 timestamp );
    //มีการถอนเงิน
    event WithdrawnEvent(address withdraw, uint256 amount , uint256 timestamp );
        
    
}