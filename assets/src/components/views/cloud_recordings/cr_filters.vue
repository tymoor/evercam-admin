<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Name" autocomplete="off" v-model="camera_name" @keyup="crFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Owner" autocomplete="off" v-model="owner" @keyup="crFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Status" autocomplete="off" v-model="status" @keyup="crFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Duration" id="camera-id" autocomplete="off" v-model="storage_duration" @keyup="crFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Interval" autocomplete="off" v-model="interval" @keyup="crFilterGlobal">
        </div>
      </div>
    </form>
  </div>
</template>

<style scoped>
.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.search-label {
  margin-top: 4px;
  margin-left: 15px;
}
</style>

<script>
export default {
  props: ["selectedCameras"],
  data () {
    return {
      camera_name: "",
      owner: "",
      status: "",
      storage_duration: "",
      interval: "",
      allParams: {}
    }
  },
  methods: {
    crFilterGlobal () {
      this.allParams.camera_name = this.camera_name
      this.allParams.owner = this.owner
      this.allParams.status = this.status
      this.allParams.storage_duration = this.storage_duration
      this.allParams.interval = this.interval
      this.$events.fire('cr-filter-set', this.allParams)
    }
  }
}
</script>