<template>
  <div class="sidebar">
    <nav class="sidebar-nav">
      <ul class="nav">
        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/'">
            <i class="nav-icon icon-drop fa fa-users"></i>
            Users
          </router-link>
        </li>
        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/admins'">
            <i class="nav-icon icon-drop fa fa-users"></i>
            Admins
          </router-link>
        </li>
        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/archives'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Archives
          </router-link>
        </li>
        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/cameras'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Cameras
          </router-link>
        </li>
        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/camera_shares'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Camera Shares
          </router-link>
        </li>
        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/camera_share_requests'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Camera Share Requests
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
            Vendor
          </router-link>
        </li>
        <li class="nav-item">
          <router-link class="nav-link" v-bind:to="'/cloud_recordings'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Cloud Recordings
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
      </ul>
    </nav>
    <button class="sidebar-minimizer brand-minimizer" type="button"></button>
  </div>
</template>
