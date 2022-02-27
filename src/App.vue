<template>
  <div id="app">
    <div>宇宙第一NFT交易市场</div>
    <router-link class="guide" to="/" replace="">主页</router-link>
    <router-link class="guide" to="/create" replace="">创建nft</router-link>
    <router-link class="guide" to="/assets" replace="">自己拥有的nft</router-link>
    <!-- <router-link :to="{ name: 'c' }" replace="">跳转到cc</router-link> -->
    <router-view></router-view>
  </div>
</template>

<script>
export default {
  name: "App",
  components: {},
  methods: {},
  data() {
    return {};
  },
};
</script>

<style scoped>
.guide{
  display: inline-block;
  margin: 20px 20px 20px 0;
}

</style>
