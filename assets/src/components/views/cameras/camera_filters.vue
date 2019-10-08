<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="ID" id="camera-id" autocomplete="off" v-model="camera_exid" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Owner" id="camera-id" autocomplete="off" v-model="camera_owner" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Name" id="camera-id" autocomplete="off" v-model="camera_name" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="IP" id="camera-id" autocomplete="off" v-model="camera_ip" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Username" id="camera-id" autocomplete="off" v-model="username" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Password" id="camera-id" autocomplete="off" v-model="password" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Model" id="camera-id" autocomplete="off" v-model="model" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Vendor" id="camera-id" autocomplete="off" v-model="vendor" @keyup="cameraFilterGlobal">
        </div>
        <div class="col">
          <button type="button" @click="deleteCameras" class="btn btn-danger btn-right-margin">Delete Camera(s)</button>
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
import _ from "lodash";
import axios from "axios";

export default {
  props: ["selectedCameras"],
  data () {
    return {
      camera_exid: "",
      camera_name: "",
      camera_owner: "",
      camera_ip: "",
      model: "",
      vendor: "",
      username: "",
      password: "",
      allParams: {}
    }
  },
  methods: {
    cameraFilterGlobal () {
      this.allParams.username = this.username
      this.allParams.password = this.password
      this.allParams.camera_exid = this.camera_exid
      this.allParams.camera_name = this.camera_name
      this.allParams.camera_owner = this.camera_owner
      this.allParams.camera_ip = this.camera_ip
      this.allParams.model = this.model
      this.allParams.vendor = this.vendor

      let that = this;
      this.fireFilter(that);
    },

    fireFilter: _.debounce((self) => {
      self.$events.fire('camera-filter-set', self.allParams)
    }, 500),

    deleteCameras () {
      let self = this
      if (Object.keys(self.selectedCameras).length === 0) {
        this.showWarnMsg({
          title: "Warning",
          message: "At least select one Camera!"
        });
      } else {
        if (window.confirm("Are you sure you want to delete this event?")) {
          self.selectedCameras.forEach((camera) => {

            axios({
              method: 'delete',
              url: `${this.$root.api_url}/v2/cameras/${camera.exid}?api_id=${camera.api_id}&api_key=${camera.api_key}`,
              data: {
              }
            }).then(response => {
              console.log(response)
            })
          })
          this.showSuccessMsg({
            title: "Success",
            message: "Camera(s) has been deleted!"
          });
          this.$events.fire('cameras-deleted', {})
        }
      }
    }
  }
}
</script>