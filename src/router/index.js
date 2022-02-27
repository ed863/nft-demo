import Vue from "vue";
import Router from "vue-router";
Vue.use(Router);
const routes = [
  {
    path: "/",
    component: () => import("../components/home.vue"),
  },
  { path: "/create", component: () => import("../components/create.vue") },
  { path: "/assets", component: () => import("../components/assets.vue") },
  {
    path: "*",
    redirect: "/",
  },
];

const router = new Router({
  routes,
  mode: "hash",
});

export default router;
