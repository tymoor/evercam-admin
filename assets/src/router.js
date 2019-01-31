import Vue from 'vue'
import VueRouter from 'vue-router'
import VueResource from "vue-resource"
import VueEvents from "vue-events"
import Notifications from "vue-notification"

Vue.use(Notifications)
Vue.use(VueEvents)
Vue.use(VueResource)
Vue.use(VueRouter)

import Users from "./components/views/users/users";
import Cameras from "./components/views/cameras/cameras";
import Page404 from "./components/Page404";
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

import UserFilters from "./components/views/users/user_filters";
Vue.component("v-user-filters", UserFilters);

import UserShowHide from "./components/views/users/users_show_hide";
Vue.component("v-user-show-hide", UserShowHide);

import CameraFilters from "./components/views/cameras/camera_filters";
Vue.component("v-camera-filters", CameraFilters);

import CameraShowHide from "./components/views/cameras/cameras_show_hide";
Vue.component("v-camera-show-hide", CameraShowHide);

const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: "/", component: Users, name: "users", meta: { title: "Users"} },
    { path: "/cameras", component: Cameras, name: "cameras", meta: { title: "Cameras"} },
    { path: "/users", redirect: '/'},
    { path: "*", component: Page404, name: "notfound", meta: { title: "Not Found"}}
  ]
});

router.beforeEach((to, from, next) => {
  document.title = to.meta.title
  next()
});

export default router;
