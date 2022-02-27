const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const TMKNFT = await hre.ethers.getContractFactory("TMKNFT");
  const tmknft = await TMKNFT.deploy();
  await tmknft.deployed();
  console.log("TMKNFT deployed to:", tmknft.address);

  const Trade = await hre.ethers.getContractFactory("Trade");
  const trade = await Trade.deploy(tmknft.address, 90);
  await trade.deployed();
  console.log("Trade deployed to:", trade.address);

  let config = `
  export const tmknftaddress = "${tmknft.address}"
  export const tradeaddress = "${trade.address}"
  `;

  let data = JSON.stringify(config);
  fs.writeFileSync("config.js", JSON.parse(data));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
