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
import Map from "./components/views/maps/map";
import MapGarda from "./components/views/maps/maps_garda";
import MapConstruction from "./components/views/maps/maps_construction";
import Compares from "./components/views/compares/compares";
import CameraShareRequests from "./components/views/camera_share_requests/camera_share_requests";
import SnapshotExtractors from "./components/views/snapshot_extractors/snapshot_extractors";
import MetaDatas from "./components/views/meta_datas/meta_datas";
import Onvif from "./components/views/onvif/onvif";
import ConstructionNvrs from "./components/views/nvrs/construction_nvrs/construction_nvrs";
import IntercomCompanies from "./components/views/intercom_companies/intercom_companies";
import DuplicateCameras from "./components/views/duplicate_cameras/duplicate_cameras";
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

import ComparesFilters from "./components/views/compares/compares_filters";
Vue.component("v-compares-filters", ComparesFilters);

import ComparesShowHide from "./components/views/compares/compares_show_hide";
Vue.component("v-compares-show-hide", ComparesShowHide);

import SEFilters from "./components/views/snapshot_extractors/se_filters";
Vue.component("v-se-filters", SEFilters);

import SEShowHide from "./components/views/snapshot_extractors/se_show_hide";
Vue.component("v-se-show-hide", SEShowHide);

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
    { path: "/compares", component: Compares, name: "compares", meta: { title: "Compares"} },
    { path: "/snapmails", component: Snapmails, name: "snapmails", meta: { title: "Snapmails"} },
    { path: "/snapmail_history", component: SnapmailHistory, name: "snapmail_history", meta: { title: "Snapmail History"} },
    { path: "/map", component: Map, name: "map", meta: { title: "Map"} },
    { path: "/maps_garda", component: MapGarda, name: "map_garda", meta: { title: "Maps Garda"} },
    { path: "/maps_construction", component: MapConstruction, name: "maps_construction", meta: { title: "Maps Construction"} },
    { path: "/snapshot_extractors", component: SnapshotExtractors, name: "snapshot_extractors", meta: { title: "Snapshot Extractors"} },
    { path: "/meta_datas", component: MetaDatas, name: "meta_datas", meta: { title: "Meta Datas"} },
    { path: "/onvif", component: Onvif, name: "onvif", meta: { title: "Onvif"} },
    { path: "/intercom_companies", component: IntercomCompanies, name: "intercom_companies", meta: { title: "Intercom Companies"} },
    { path: "/duplicate_cameras", component: DuplicateCameras, name: "duplicate_cameras", meta: { title: "Duplicate Cameras"} },
    { path: "/construction_nvrs", component: ConstructionNvrs, name: "construction_nvrs", meta: { title: "Construction Nvrs"} },
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
