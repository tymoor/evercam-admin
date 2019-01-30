<template>
  <div v-if="$route.name === 'notfound'">
    <router-view></router-view>
  </div>
  <v-layout v-else>
    <notifications group="admins" position="top center" />
    <router-view></router-view>
  </v-layout>
</template>
