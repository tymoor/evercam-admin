<template>
  <div>
    <div class="overflow-forms">
      <v-onvif-filters />
    </div>

    <div> onvif</div>
</div>
</template>

<style scoped>
  .overflow-forms {
    overflow: hidden;
    width: 85%;
  }
</style>

<script>
import OnvifFilters from "./onvif_filters";

export default {
  components: {
    "v-onvif-filters": OnvifFilters
  }
}
</script>