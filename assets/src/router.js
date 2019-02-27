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
import Vendors from "./components/views/vendors/vendors";
import CloudRecordings from "./components/views/cloud_recordings/cloud_recordings";
import Snapmails from "./components/views/snapmails/snapmails";
import SnapmailHistory from "./components/views/snapmail_history/snapmail_history";
import Admins from "./components/views/admins/admins";
import Archives from "./components/views/archives/archives";
import CameraShareRequests from "./components/views/camera_share_requests/camera_share_requests";
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

import VendorFilters from "./components/views/vendors/vendor_filters";
Vue.component("v-vendor-filters", VendorFilters);

import VendorShowHide from "./components/views/vendors/vendor_show_hide";
Vue.component("v-vendor-show-hide", VendorShowHide);

import CRFilters from "./components/views/cloud_recordings/cr_filters";
Vue.component("v-cr-filters", CRFilters);

import CRShowHide from "./components/views/cloud_recordings/cr_show_hide";
Vue.component("v-cr-show-hide", CRShowHide);

import AdminFilters from "./components/views/admins/admin_filters";
Vue.component("v-admin-filters", AdminFilters);

import AdminShowHide from "./components/views/admins/admin_show_hide";
Vue.component("v-admin-show-hide", AdminShowHide);

import SnapmailFilters from "./components/views/snapmails/snapmail_filters";
Vue.component("v-snapmail-filters", SnapmailFilters);

import SnapmailShowHide from "./components/views/snapmails/snapmail_show_hide";
Vue.component("v-snapmail-show-hide", SnapmailShowHide);

import SnapmailHistoryShowHide from "./components/views/snapmail_history/snapmail_history_show_hide";
Vue.component("v-snapmail-history-show-hide", SnapmailHistoryShowHide);

import SnapmailHistoryFilters from "./components/views/snapmail_history/snapmail_history_filters";
Vue.component("v-snapmail-history-filters", SnapmailHistoryFilters);

import CSRFilters from "./components/views/camera_share_requests/csr_filters";
Vue.component("v-csr-filters", CSRFilters);

import CSRShowHide from "./components/views/camera_share_requests/csr_show_hide";
Vue.component("v-csr-show-hide", CSRShowHide);

import ArchivesFilters from "./components/views/archives/archives_filters";
Vue.component("v-archives-filters", ArchivesFilters);

import ArchivesShowHide from "./components/views/archives/archives_show_hide";
Vue.component("v-archives-show-hide", ArchivesShowHide);

import HorizontalScroll from "./components/shared/horizontal_scroll";
Vue.component("v-horizontal-scroll", HorizontalScroll);

const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: "/", component: Users, name: "users", meta: { title: "Users"} },
    { path: "/cameras", component: Cameras, name: "cameras", meta: { title: "Cameras"} },
    { path: "/camera_shares", component: CameraShares, name: "camera_shares", meta: { title: "Camera Shares"} },
    { path: "/camera_share_requests", component: CameraShareRequests, name: "camera_share_requests", meta: { title: "Camera Share Requests"} },
    { path: "/vendor_models", component: VendorModels, name: "vendor_models", meta: { title: "Vendor Models"} },
    { path: "/vendors", component: Vendors, name: "vendors", meta: { title: "Vendors"} },
    { path: "/cloud_recordings", component: CloudRecordings, name: "cloud_recordings", meta: { title: "Cloud Recordings"} },
    { path: "/admins", component: Admins, name: "admins", meta: { title: "Admins"} },
    { path: "/archives", component: Archives, name: "archives", meta: { title: "Archives"} },
    { path: "/snapmails", component: Snapmails, name: "snapmails", meta: { title: "Snapmails"} },
    { path: "/snapmail_history", component: SnapmailHistory, name: "snapmail_history", meta: { title: "Snapmail History"} },
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
