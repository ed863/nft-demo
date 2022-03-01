<template>
  <div>
    
    <button @click="approve()" style="display:block">初次出售NFT时请点此授权给合约</button>
    <ul>
      <li class="picLi" v-for="(item, index) in list" :key="index">
        <img :src="item.file" />
        <div class="belowImg">
          <p>作品名称：{{ item.name }}</p>
          <p>作品描述：{{ item.des }}</p>
          <button @click="show(index)">点击卖出</button>
        </div>
        <div class="sellDiv" v-if="whichToSell == index">
          <input type="text" placeholder="输入价格" v-model="price" />
          <button @click="sell(index)">确认</button>
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
    async getMyNfts() {
      const web3Modal = new Web3Modal();
      const connection = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(connection);
      const signer = provider.getSigner();
      this.myAddress = await signer.getAddress();
      console.log("this.myAddress");
      console.log(this.myAddress);
      /* next, create the item */
      let contract = new ethers.Contract(tmknftaddress, TMKNFT.abi, signer);
      let transaction = await contract.balanceOf(this.myAddress);
      this.ownedNumber = parseInt(transaction._hex, 16);
      console.log("this.ownedNumber");
      console.log(this.ownedNumber);
      for (let i = 0; i < this.ownedNumber; i++) {
        let tokenid = parseInt(
          await contract.tokenOfOwnerByIndex(this.myAddress, i),
          16
        );
        // console.log(i);
        console.log("tokenid");
        console.log(tokenid);
        let tokenUri = await contract.tokenURI(tokenid);
        console.log("tokenUri");
        console.log(tokenUri);
        const meta = await axios.get(tokenUri);
        const singeNft = {
          name: meta.data.name,
          des: meta.data.des,
          file: meta.data.file,
        };
        this.list.push(singeNft);
      }
      console.log("this.list");
      console.log(this.list);
      console.log("typeof(this.list)");
      console.log(typeof this.list);
      console.log(JSON.stringify(this.list));
    },
    async sell(index) {
      console.log("selling");
      const web3Modal = new Web3Modal();
      const connection = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(connection);
      const signer = provider.getSigner();
      this.myAddress = await signer.getAddress();
      console.log("this.myAddress");
      console.log(this.myAddress);
      let contract = new ethers.Contract(tmknftaddress, TMKNFT.abi, signer);
      let tokenid = parseInt(
        await contract.tokenOfOwnerByIndex(this.myAddress, index),
        16
      );
      console.log("tokenid");
      console.log(tokenid);
      let owner = await contract.ownerOf(tokenid);
      console.log("owner");
      console.log(owner);
      let tradecontract = new ethers.Contract(tradeaddress, Trade.abi, signer);
      console.log(tradecontract);
      let priceInWei = this.price * 1000000000000000000;
      let priceInWei2string = priceInWei.toString();
      let bigNumPrice = ethers.BigNumber.from(priceInWei2string);
      await tradecontract.transferToMarket(tokenid, bigNumPrice);
      this.$router.push({ path: "/" });
    },
    async approve() {
      console.log("approve");
      console.log("this.myAddress");
      console.log(this.myAddress);
      const web3Modal = new Web3Modal();
      const connection = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(connection);
      const signer = provider.getSigner();
      /* next, create the item */
      let contract = new ethers.Contract(tmknftaddress, TMKNFT.abi, signer);
      // let tradecontract = new ethers.Contract(tradeaddress, Trade.abi, signer);
      let transaction = await contract.setApprovalForAll(tradeaddress, true);
      console.log("transactionapprove");
      console.log(transaction);
    },
    show(index) {
      console.log("show");
      this.whichToSell = index;
    },
  },
  created() {},
  beforeMount() {
    this.getMyNfts();
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
  display: block;
}
.sellDiv {
  position: absolute;
  display: block;
  width: 200px;
  height: 200px;
  top: 0px;
  left: 0px;
  background-color: pink;
  opacity: 0.8;
}
.sellDiv input {
  margin-top: 20px;
  margin-left: 20px;
  display: block;
  width: 90px;
  height: 30px;
}
.sellDiv button {
  margin-top: 20px;
  margin-left: 20px;
  display: block;
  width: 90px;
  height: 30px;
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
.belowImg p:hover{
  overflow: auto;
  text-overflow: clip;
}
</style>
