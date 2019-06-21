import Vue from 'vue'
import VueRouter from 'vue-router'
import VueResource from "vue-resource"
import VueEvents from "vue-events"
import Notifications from "vue-notification"
import Tooltip from "vue-directive-tooltip"

Vue.use(Notifications)
Vue.use(VueEvents)
Vue.use(VueResource)
Vue.use(VueRouter)
Vue.use(Tooltip)

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
import Map from "./components/views/maps/map";
import Compares from "./components/views/compares/compares";
import CameraShareRequests from "./components/views/camera_share_requests/camera_share_requests";
import SnapshotExtractors from "./components/views/snapshot_extractors/snapshot_extractors";
import MetaDatas from "./components/views/meta_datas/meta_datas";
import Onvif from "./components/views/onvif/onvif";
import Projects from "./components/views/projects/projects";
import ConstructionNvrs from "./components/views/nvrs/construction_nvrs/construction_nvrs";
import ConstructionVHNvrs from "./components/views/nvrs/construction_nvrs_vh/construction_nvrs_vh";
import IntercomCompanies from "./components/views/intercom_companies/intercom_companies";
import IntercomUsers from "./components/views/intercom_users/intercom_users";
import DuplicateCameras from "./components/views/duplicate_cameras/duplicate_cameras";
import Storage from "./components/views/storage/storage";
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

import HorizontalScroll from "./components/shared/horizontal_scroll";
Vue.component("v-horizontal-scroll", HorizontalScroll);

const router = new VueRouter({
  mode: 'history',
  routes: [
    { path: "/", component: Users, name: "users", meta: { title: "Admin - Users"} },
    { path: "/cameras", component: Cameras, name: "cameras", meta: { title: "Admin - Cameras"} },
    { path: "/shares", component: CameraShares, name: "shares", meta: { title: "Admin - Shares"} },
    { path: "/share_requests", component: CameraShareRequests, name: "share_requests", meta: { title: "Admin - Share Requests"} },
    { path: "/vendor_models", component: VendorModels, name: "vendor_models", meta: { title: "Admin - Vendor Models"} },
    { path: "/vendors", component: Vendors, name: "vendors", meta: { title: "Admin - Vendors"} },
    { path: "/cloud_recordings", component: CloudRecordings, name: "cloud_recordings", meta: { title: "Admin - Cloud Recordings"} },
    { path: "/admins", component: Admins, name: "admins", meta: { title: "Admin - Admins"} },
    { path: "/clips", component: Archives, name: "clips", meta: { title: "Admin - Clips"} },
    { path: "/compares", component: Compares, name: "compares", meta: { title: "Admin - Compares"} },
    { path: "/snapmails", component: Snapmails, name: "snapmails", meta: { title: "Admin - Snapmails"} },
    { path: "/snapmail_history", component: SnapmailHistory, name: "snapmail_history", meta: { title: "Admin - Snapmail History"} },
    { path: "/maps", component: Map, name: "map", meta: { title: "Admin - Maps"} },
    { path: "/snapshot_extractors", component: SnapshotExtractors, name: "snapshot_extractors", meta: { title: "Admin - Snapshot Extractors"} },
    { path: "/meta_datas", component: MetaDatas, name: "meta_datas", meta: { title: "Admin - Meta Datas"} },
    { path: "/onvif", component: Onvif, name: "onvif", meta: { title: "Admin - Onvif"} },
    { path: "/projects", component: Projects, name: "projects", meta: { title: "Admin - Projects"} },
    { path: "/companies", component: IntercomCompanies, name: "companies", meta: { title: "Admin - Companies"} },
    { path: "/intercom_users", component: IntercomUsers, name: "intercom_users", meta: { title: "Admin - Intercom Users"} },
    { path: "/duplicate_cameras", component: DuplicateCameras, name: "duplicate_cameras", meta: { title: "Admin - Duplicate Cameras"} },
    { path: "/nvrs", component: ConstructionNvrs, name: "nvrs", meta: { title: "Admin - NVRs"} },
    { path: "/nvr_vhs", component: ConstructionVHNvrs, name: "nvrs_vh", meta: { title: "Admin - NVR VHs"} },
    { path: "/storage", component: Storage, name: "storage", meta: { title: "Admin - Storage"} },
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
