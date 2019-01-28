<template>
  <v-layout>
    <router-view></router-view>
  </v-layout>
</template>

<script>
  export default {
    mounted() {
      console.log("mounted")
    }
  }
</script>