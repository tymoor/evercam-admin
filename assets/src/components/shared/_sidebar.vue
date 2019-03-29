<template>
  <div class="sidebar">
    <nav class="sidebar-nav">
      <ul class="nav">

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/admins'">
            <i class="nav-icon icon-drop fa fa-users"></i>
            Admins
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/meta_datas'">
            <i class="nav-icon icon-drop fa fa-file-video-o"></i>
            Active Video Sessions
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/cameras'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Cameras
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/clips'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Clips
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/compares'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Compares
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/companies'">
            <i class="nav-icon icon-drop fa fa-building"></i>
            Companies
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/cloud_recordings'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Cloud Recordings
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/duplicate_cameras'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Duplicate Cameras
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/maps'">
            <i class="nav-icon icon-drop fa fa-map"></i>
            Maps
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/nvrs'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            NVRs
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/nvr_vhs'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            NVR VHs
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/onvif'">
            <i class="nav-icon icon-drop fa fa-search"></i>
            Onvif
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/shares'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Shares
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/storage'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Storage
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/share_requests'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Share Requests
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/snapmails'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Snapmails
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/snapmail_history'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Snapmail History
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/snapshot_extractors'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Snapshot Extractors
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/'">
            <i class="nav-icon icon-drop fa fa-users"></i>
            Users
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/vendor_models'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Vendor Models
          </router-link>
        </li>

        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/vendors'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Vendors
          </router-link>
        </li>

      </ul>
    </nav>
    <button class="sidebar-minimizer brand-minimizer" type="button"></button>
  </div>
</template>
