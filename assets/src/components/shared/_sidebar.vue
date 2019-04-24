<template>
  <div class="sidebar">
    <nav class="sidebar-nav">
      <ul class="nav">

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/'">
            <i class="nav-icon icon-drop fa fa-star"></i>
            Users
          </router-link>
        </li>

        <div class="dropdown-divider"></div>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/admins'">
            <i class="nav-icon icon-drop"></i>
            Admins
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/cameras'">
            <i class="nav-icon icon-drop"></i>
            Cameras
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/clips'">
            <i class="nav-icon icon-drop"></i>
            Clips
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/compares'">
            <i class="nav-icon icon-drop"></i>
            Compares
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/companies'">
            <i class="nav-icon icon-drop"></i>
            Companies
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/cloud_recordings'">
            <i class="nav-icon icon-drop"></i>
            Cloud Recordings
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/duplicate_cameras'">
            <i class="nav-icon icon-drop"></i>
            Duplicate Cameras
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/intercom_users'">
            <i class="nav-icon icon-drop"></i>
            Intercom Users
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/maps'">
            <i class="nav-icon icon-drop"></i>
            Maps
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/nvrs'">
            <i class="nav-icon icon-drop"></i>
            NVRs
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/nvr_vhs'">
            <i class="nav-icon icon-drop"></i>
            NVR VHs
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/onvif'">
            <i class="nav-icon icon-drop"></i>
            Onvif
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/projects'">
            <i class="nav-icon icon-drop"></i>
            Projects
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/shares'">
            <i class="nav-icon icon-drop"></i>
            Shares
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/share_requests'">
            <i class="nav-icon icon-drop"></i>
            Share Requests
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/storage'">
            <i class="nav-icon icon-drop"></i>
            Storage
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/snapmails'">
            <i class="nav-icon icon-drop"></i>
            Snapmails
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/snapmail_history'">
            <i class="nav-icon icon-drop"></i>
            Snapmail History
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/snapshot_extractors'">
            <i class="nav-icon icon-drop"></i>
            Snapshot Extractors
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/vendors'">
            <i class="nav-icon icon-drop"></i>
            Vendors
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/vendor_models'">
            <i class="nav-icon icon-drop"></i>
            Vendor Models
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/meta_datas'">
            <i class="nav-icon icon-drop"></i>
            Video Sessions
          </router-link>
        </li>

      </ul>
    </nav>
  </div>
</template>

<style scoped>
.dropdown-divider {
  border-top: 1px solid #3a4248;
}
</style>
