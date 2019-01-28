import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

import Users from "./components/views/users/Users";
import Login from "./components/Login"

import Gravatar from 'vue-gravatar';
Vue.component('v-gravatar', Gravatar);

import Header from "./components/shared/_header";
Vue.component("v-header", Header);

import CurrentUser from "./components/shared/_current_user";
Vue.component("v-current-user", CurrentUser);

import Sidebar from "./components/shared/_sidebar";
Vue.component("v-sidebar", Sidebar);

import Layout from "./components/shared/Layout";
Vue.component("v-layout", Layout);


const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: "/users/sign_in", component: Login, name: "login", meta: { title: "Login"}},
    { path: "/", component: Users, name: "users", meta: { title: "Users"} },
    { path: "/users", redirect: '/'}
  ]
});

router.beforeEach((to, from, next) => {
  document.title = to.meta.title
  next()
});

export default router;
