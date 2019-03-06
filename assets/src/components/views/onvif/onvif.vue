<template>
  <div class="explain-menu">
    <div>
      <v-onvif-filters />
    </div>

    <div class="json-viewer">
      <vue-json-pretty
        :path="'res'"
        v-bind:data="json"
      >
    </vue-json-pretty>
    </div>
</div>
</template>

<style scoped>
  .explain-menu {
    z-index: 999999999999999999;
    overflow: -webkit-paged-x;
  }

  .json-viewer {
    margin-left: 10px;
    padding: 10px;
    background: oldlace;
  }
</style>

<script>
import OnvifFilters from "./onvif_filters";
import VueJsonPretty from 'vue-json-pretty';

export default {
  components: {
    "v-onvif-filters": OnvifFilters,
    VueJsonPretty
  },
  data () {
    return {
      json: null
    }
  },
  mounted() {
    this.$events.$on('json-set', eventData => this.showJSON(eventData))
  },
  methods:{
    showJSON(data) {
      console.log(data)
      this.json = data
    }
  }
}
</script>