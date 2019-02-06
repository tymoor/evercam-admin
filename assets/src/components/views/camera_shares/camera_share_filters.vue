<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="ID" id="camera-id" autocomplete="off" v-model="camera_exid" @keyup="cameraShareFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Sharer" id="camera-id" autocomplete="off" v-model="sharer_fullname" @keyup="cameraShareFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Sharee" id="camera-id" autocomplete="off" v-model="sharee_fullname" @keyup="cameraShareFilterGlobal">
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
  data () {
    return {
      camera_exid: "",
      sharer_fullname: "",
      sharee_fullname: "",
      allParams: {}
    }
  },
  methods: {
    cameraShareFilterGlobal () {
      this.allParams.camera_exid = this.camera_exid
      this.allParams.sharer_fullname = this.sharer_fullname
      this.allParams.sharee_fullname = this.sharee_fullname

      this.$events.fire('camera-shares-filter-set', this.allParams)
    }
  }
}
</script>