<template>
  <div>
    <el-row>
      <el-col :span="12"
        ><div class="grid-content bg-purple" v-if="this.list == []">
          无NFT正在出售，此页暂无内容显示
        </div></el-col
      >
      <el-col :span="12"
        ><div class="grid-content bg-purple-light"></div
      ></el-col>
    </el-row>
    <ul>
      <li class="picLi" v-for="(item, index) in list" :key="index">
        <img :src="item.file" />
        <div class="belowImg">
          <p>name: {{ item.name }}</p>
          <p>description: {{ item.des }}</p>
          <p>id: {{ item.id }}</p>
          <p>price: {{ (item.pri / 1000000000000000000).toFixed(5) }}</p>
          <button @click="buy(item.id)">buy</button>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
import { ethers } from "ethers";
// import { create as ipfsHttpClient } from "ipfs-http-client";
import Web3Modal from "web3modal";
import { tmknftaddress, tradeaddress } from "../../config";
import TMKNFT from "../../artifacts/contracts/Market.sol/TMKNFT.json";
import Trade from "../../artifacts/contracts/Market.sol/Trade.json";
import axios from "axios";

export default {
  name: "App",
  components: {},
  methods: {
    async getMarketNfts() {
      const web3Modal = new Web3Modal();
      const connection = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(connection);
      const signer = provider.getSigner();
      this.myAddress = await signer.getAddress();
      console.log("this.myAddress");
      console.log(this.myAddress);
      /* next, create the item */
      let contract = new ethers.Contract(tmknftaddress, TMKNFT.abi, signer);
      let tradeContract = new ethers.Contract(tradeaddress, Trade.abi, signer);
      let price1 = await tradeContract.bidPrice(3);
      console.log("price1");
      console.log(parseInt(price1, 16));
      let transaction = await contract.balanceOf(tradeaddress);
      this.ownedNumber = parseInt(transaction._hex, 16);
      console.log("this.ownedNumber");
      console.log(this.ownedNumber);
      for (let i = 0; i < this.ownedNumber; i++) {
        let tokenid = parseInt(
          await contract.tokenOfOwnerByIndex(tradeaddress, i),
          16
        );
        let tokenUri = await contract.tokenURI(tokenid);
        let price = await tradeContract.bidPrice(tokenid);
        const meta = await axios.get(tokenUri);
        const singeNft = {
          name: meta.data.name,
          des: meta.data.des,
          file: meta.data.file,
          id: tokenid,
          pri: price,
        };
        this.list.push(singeNft);
      }
    },
    async buy(itemid) {
      console.log("buy");
      console.log("itemid");
      console.log(itemid);
      const web3Modal = new Web3Modal();
      const connection = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(connection);
      const signer = provider.getSigner();
      let tradeContract = new ethers.Contract(tradeaddress, Trade.abi, signer);
      let price = (await tradeContract.bidPrice(itemid)).toString();
      let result = await tradeContract.makedeal(itemid, { value: price });
      console.log("result");
      console.log(result);
    },
  },
  created() {},
  beforeMount() {
    this.getMarketNfts();
  },
  data() {
    return {
      list: [],
      ownedNumber: 0,
      myAddress: null,
      whichToSell: null,
      price: null,
    };
  },
};
</script>

<style scoped>
.picLi {
  display: inline-block;
  position: relative;
  width: 200px;
  height: 200px;
  margin-right: 20px;
}
.picLi img {
  width: 200px;
  height: 200px;
}

.belowImg {
  position: absolute;
  width: 200px;
}

.belowImg p {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.belowImg p:hover {
  overflow: auto;
  text-overflow: clip;
}
</style>
