<template>
  <div class="row overlapping">
    <div class="form-camera-report">
      <div class="filter-naming">
        Search :
      </div>
      <div class="camera-inputs">
        <input type="text" class="first-inps" placeholder="ID" id="camera-id" autocomplete="off" v-model="camera_exid" @keyup="cameraShareFilterGlobal">
        <input type="text" class="first-inps" placeholder="Sharer" id="camera-id" autocomplete="off" v-model="sharer_fullname" @keyup="cameraShareFilterGlobal">
        <input type="text" class="first-inps" placeholder="Sharee" id="camera-id" autocomplete="off" v-model="sharee_fullname" @keyup="cameraShareFilterGlobal">
      </div>
    </div>
  </div>
</template>

<style scoped>
.overlapping {
  margin-top: 4px;
  z-index: 1;
  position: relative;
  margin-left: -1px;
}

.form-camera-report {
  width: 80%;
  overflow: hidden;
  height: auto;
  float: left;
  text-align: center;
}

.filter-naming {
  width: 62px;
  padding: 9px 2px;
  height: auto;
  float: left;
  text-align: right;
  font-size: 13px;
}

.camera-inputs {
  float: left;
  height: auto;
  overflow: hidden;
  padding: 3px 1px;
}

.first-inps {
  background-color: #eee;
  width: 95px;
  padding: 7px;
  margin-left: 5px;
  border: 0;
  float: left;
}

.clear-btn-f {
  padding: 7px;
  display: inline-block;
  background-color: #428bca;
  float: left;
  color: white;
  border: 0;
  margin-left: 10px;
}

.form-camera-report .chk-postion {
  float: left;
}

.hide {
  display: none !important;
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