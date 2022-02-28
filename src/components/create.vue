<template>
  <div>
    <p>请输入作品名称</p>
    <input type="text" v-model="name" />
    <p>请输入作品描述</p>
    <input type="text" v-model="des" />
    <div class="upload">
      <input type="file" class="fileinput" multiple @change="upload" />
    </div>
    <img v-if="picurl" class="pic" :src="this.picurl" />
    <button class="createButton" @click="create">创建此作品</button>
  </div>
</template>

<script>
import { ethers } from "ethers";
import { create as ipfsHttpClient } from "ipfs-http-client";
import Web3Modal from "web3modal";
import { tmknftaddress } from "../../config";
import TMKNFT from "../../artifacts/contracts/Market.sol/TMKNFT.json";

const client = ipfsHttpClient("https://ipfs.infura.io:5001/api/v0");
export default {
  name: "Create",
  components: {},
  methods: {
    async upload(e) {
      const file = e.target.files[0];
      try {
        const added = await client.add(file, {
          progress: (prog) => console.log(`received: ${prog}`),
        });
        const url = `https://ipfs.infura.io/ipfs/${added.path}`;
        console.log("url");
        console.log(url);
        this.picurl = url;
      } catch (error) {
        console.log("Error uploading file: ", error);
      }
    },
    async create() {
      if (!this.name || !this.des || !this.picurl) {
        console.log("信息不足，无法创建");
        return;
      } else {
        const fullData = JSON.stringify({
          name: this.name,
          des: this.des,
          file: this.picurl,
        });
        try {
          const added = await client.add(fullData);
          const fullUrl = `https://ipfs.infura.io/ipfs/${added.path}`;
          /* after file is uploaded to IPFS, pass the URL to save it on Polygon */
          const web3Modal = new Web3Modal();
          const connection = await web3Modal.connect();
          const provider = new ethers.providers.Web3Provider(connection);
          const signer = provider.getSigner();

          /* next, create the item */
          let contract = new ethers.Contract(tmknftaddress, TMKNFT.abi, signer);
          let transaction = await contract.userMint(fullUrl);
          let tx = await transaction.wait();
          console.log("tx");
          console.log(tx);
          console.log("tx.events");
          console.log(tx.events);
          console.log("tx.events[0],also event");
          console.log(tx.events[0]);
          let event = tx.events[0];
          let value = event.args[2];
          console.log("value");
          console.log(value);
          let tokenId = value.toNumber();
          this.lastTokenId = tokenId;
          console.log("lastTokenId");
          console.log(this.lastTokenId);
        } catch (error) {
          console.log("Error uploading file: ", error);
        }
      }
    },
  },
  computed: {
    res: function () {
      return this.name + this.des + this.picurl;
    },
  },
  created() {},

  data() {
    return {
      name: "",
      des: "",
      pic: "",
      picurl: "",
      lastTokenId: "",
    };
  },
};
</script>

<style scoped>
.fileinput {
  display: block;
  margin: 20px 0;
}
.pic {
  width: 500px;
  height: 300px;
}
.createButton {
  display: block;
}
</style>
