import Vue from 'vue'
import VueRouter from 'vue-router'
Vue.use(VueRouter)

import Login from "./Login"

const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: "/users/sign_in", component: Login, name: "login", meta: { title: "Login"}}
  ]
});

router.beforeEach((to, from, next) => {
  document.title = to.meta.title
  next()
});

export default router;
