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
          <router-link class="nav-link" v-bind:to="'/cameras'">
            <i class="nav-icon icon-drop fa fa-camera"></i>
            Cameras
          </router-link>
        </li>
      </ul>
    </nav>
    <button class="sidebar-minimizer brand-minimizer" type="button"></button>
  </div>
</template>
