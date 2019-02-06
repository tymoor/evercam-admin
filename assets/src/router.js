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
import CameraShares from "./components/views/camera_shares/camera_shares";
import VendorModels from "./components/views/vendor_models/vendor_models";
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

import UserShowHide from "./components/views/users/users_show_hide";
Vue.component("v-user-show-hide", UserShowHide);

import CameraFilters from "./components/views/cameras/camera_filters";
Vue.component("v-camera-filters", CameraFilters);

import CameraShowHide from "./components/views/cameras/cameras_show_hide";
Vue.component("v-camera-show-hide", CameraShowHide);

import CameraShareFilters from "./components/views/camera_shares/camera_share_filters";
Vue.component("v-camera-share-filters", CameraShareFilters);

import CameraShareShowHide from "./components/views/camera_shares/camera_shares_show_hide";
Vue.component("v-camera-share-show-hide", CameraShareShowHide);

import VendorModelFilters from "./components/views/vendor_models/vendor_model_filters";
Vue.component("v-vendor-model-filters", VendorModelFilters);

import VendorModelShowHide from "./components/views/vendor_models/vendor_model_show_hide";
Vue.component("v-vendor-model-show-hide", VendorModelShowHide);


const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: "/", component: Users, name: "users", meta: { title: "Users"} },
    { path: "/cameras", component: Cameras, name: "cameras", meta: { title: "Cameras"} },
    { path: "/camera_shares", component: CameraShares, name: "camera_shares", meta: { title: "Camera Shares"} },
    { path: "/vendor_models", component: VendorModels, name: "vendor_models", meta: { title: "Vendor Models"} },
    { path: "/users", redirect: '/'},
    { path: "*", component: Page404, name: "notfound", meta: { title: "Not Found"}}
  ],
  linkActiveClass: "exact-active",
  linkExactActiveClass: "active"
});

router.beforeEach((to, from, next) => {
  document.title = to.meta.title
  next()
});

export default router;
