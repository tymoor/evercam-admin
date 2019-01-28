<template>
  <div>
    <div v-if="this.$root.loggedIn === false">
      <router-view></router-view>
    </div>
    <div v-else="this.$root.loggedIn === true">
      <v-layout>
        <div>{{this.$root.loggedIn}}</div>
        <router-view></router-view>
      </v-layout>
    </div>
  </div>
</template>

<script>
  export default {
    mounted() {
      if (this.$root.loggedIn) {
        this.$router.push({name: "users"})
      } else if (this.$root.loggedIn === false) {
        this.$router.push({name: "login"})
      }
    }
  }
</script>