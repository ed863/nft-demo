<template>
  <div id="app">
    <el-container>
      <el-header
      style="height:100px"  ><el-row>
          <el-col :span="24"
            ><div class="grid-content bg-purple-dark header">
              宇宙第一NFT交易市场
            </div></el-col
          >
        </el-row>

        <el-row>
          <el-col :span="4"
            ><div class="grid-content bg-purple router">
              <router-link class="guide" to="/" replace="" exact style="display:block;width:100%;color:black"
                >正在出售的</router-link
              >
            </div></el-col
          >
          <el-col :span="4"
            ><div class="grid-content bg-purple-light router">
              <router-link class="guide" to="/create" replace="" style="display:block;width:100%;color:black"
                >创建nft</router-link
              >
            </div></el-col
          >
          <el-col :span="4"
            ><div class="grid-content bg-purple router">
              <router-link class="guide" to="/assets" replace="" style="display:block;width:100%;color:black"
                >自己拥有的nft</router-link
              >
            </div></el-col
          >
        </el-row>
      </el-header>
      <el-main class="bg-purple-light" style="height:1000px"><router-view></router-view></el-main>
    </el-container>
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
.el-row {
  margin-bottom: 20px;
}
.el-col {
  border-radius: 4px;
}
.bg-purple-dark {
  background: #99a9bf;
}
.bg-purple {
  background: #d3dce6;
}
.bg-purple-light {
  background: #e5e9f2;
}
.grid-content {
  border-radius: 4px;
  min-height: 36px;
}
.row-bg {
  padding: 10px 0;
  background-color: #f9fafc;
}

.header {
  text-align: center;
  height: 30px;
  line-height: 35px;
}

.router {
  text-align: center;
  height: 30px;
  line-height: 35px;
  /* text-decoration: none; */
}


  a {
    text-decoration: none;
    /* color:black */
  }


  .router-link-active {
         background-color:#3498DB;
         color: white;
       }
</style>
