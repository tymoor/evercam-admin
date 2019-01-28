<template>
  <div v-if="$route.name === 'notfound'">
    <router-view></router-view>
  </div>
  <v-layout v-else>
    <router-view></router-view>
  </v-layout>
</template>
