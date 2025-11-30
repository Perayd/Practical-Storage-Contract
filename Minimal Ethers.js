import { ethers } from "ethers";
// provider & signer already configured
const factory = new ethers.ContractFactory(abi, bytecode, signer);
const contract = await factory.deploy();
await contract.deployed();
console.log("Deployed at:", contract.address);
const tx = await contract.connect(signer).setStoredValue(42);
await tx.wait(); // wait for miner confirmation
const v = await contract.storedValue();
console.log("storedValue", v.toString());
