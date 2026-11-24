import { network } from "hardhat";
import product from "../ignition/modules/product.js";

// ใช้ network "default" (http://127.0.0.1:8545) — ต้องเปิด `npx hardhat node` ไว้ใน terminal อื่นก่อน
const { ethers } = await network.create();

console.log("Deploying MyAuction with product:", product);

const myAuction = await ethers.deployContract("MyAuction", [
  product.Brand,
  product.SerialNumber,
  BigInt(product.Duration),
]);

await myAuction.waitForDeployment();

console.log("MyAuction deployed to:", await myAuction.getAddress());
console.log("Product info:", await myAuction.getProductInfo());
console.log("Owner:", await myAuction.owner());
console.log("EndTime:", (await myAuction.endTime()).toString());
