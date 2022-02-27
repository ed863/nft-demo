<template>
  <div>
    <ul>
      <li class="picLi" v-for="(item, index) in list" :key="index">
        <img :src="item.file" />
        <p>作品名称：{{ item.name }}</p>
        <p>作品描述：{{ item.des }}</p>
        <button @click="sell(index)">sell</button>
      </li>
    </ul>

    <button @click="approve()">approve</button>
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
      await tradecontract.transferToMarket(tokenid, 1);
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
      let transaction = await contract.setApprovalForAll(tmknftaddress, true);
      console.log("transactionapprove");
      console.log(transaction);
    },
  },
  created() {
    console.log("fuckcreated");
    // this.getMyNfts();
  },
  beforeMount() {
    this.getMyNfts();
  },
  data() {
    return {
      list: [],
      ownedNumber: 0,
      myAddress: null,
    };
  },
};
</script>

<style scoped>
.picLi {
  display: inline-block;
  width: 200px;
  height: 200px;
  margin-right: 20px;
}
.picLi img {
  width: 200px;
  height: 200px;
}
</style>
