const { ethers } = require("hardhat");
const fs = require("fs");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  const cryptoDevsTokenContract = await ethers.getContractFactory(
    "CryptoDevToken"
  );
  const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(
    CRYPTO_DEVS_NFT_CONTRACT_ADDRESS
  );
  await deployedCryptoDevsTokenContract.deployed();

  const data = {
    address: deployedCryptoDevsTokenContract.address,
    abi: JSON.parse(deployedCryptoDevsTokenContract.interface.format("json")),
  };

  //This writes the ABI and address to the abi.json
  fs.writeFile("../client/constants/abi.json", JSON.stringify(data), (err) => {
    if (err) console.log(err);
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
