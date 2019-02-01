<template>
  <div class="row overlapping">
    <div class="form-camera-report">
      <div class="filter-naming">
        Search :
      </div>
      <div class="camera-inputs">
        <input type="text" class="first-inps" placeholder="ID" id="camera-id" autocomplete="off" v-model="camera_exid" @keyup="cameraFilterGlobal">
        <input type="text" class="first-inps" placeholder="Owner" id="owner" autocomplete="off" v-model="camera_owner" @keyup="cameraFilterGlobal">
        <input type="text" class="first-inps" placeholder="Camera Name" id="camera-name" autocomplete="off" v-model="camera_name" @keyup="cameraFilterGlobal">
        <input type="text" class="first-inps" placeholder="Camera IP" id="camera-ip" autocomplete="off" v-model="camera_ip" @keyup="cameraFilterGlobal">
        <input type="text" class="first-inps" placeholder="Username" id="username" autocomplete="off" v-model="username" @keyup="cameraFilterGlobal">
        <input type="text" class="first-inps" placeholder="Password" id="password" autocomplete="off" v-model="password" @keyup="cameraFilterGlobal">
        <input type="text" class="first-inps" placeholder="Model" id="model" autocomplete="off" v-model="model" @keyup="cameraFilterGlobal">
        <input type="text" class="first-inps" placeholder="Vendor" id="vendor" autocomplete="off" v-model="vendor" @keyup="cameraFilterGlobal">
        <div class="chk-postion hide"><label><div class="checker" id="uniform-exclude_construction"><span><input type="checkbox" id="exclude_construction"></span></div> Exclude Constructions</label></div>
        <button class="clear-btn-f" id="btn_delete_cameras" @click="deleteCameras">Delete Camera(s)</button>
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
  width: 954px;
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
      this.$events.fire('camera-filter-set', this.allParams)
    },
    deleteCameras () {
        let self = this
        if (Object.keys(self.selectedCameras).length === 0) {
          this.$notify({
            group: "admins",
            title: "Error",
            type: "error",
            text: "At least select one Camera!",
          });
        } else {
          if (window.confirm("Are you sure you want to delete this event?")) {
            console.log(self.selectedCameras)
            self.selectedCameras.forEach((camera) => {
              this.$http.delete(`${this.$root.api_url}/v1/cameras/${camera.exid}?api_id=${camera.api_id}&api_key=${camera.api_key}`).then(response => {
                console.log(response.body)
              }, error => {
                console.log(error)
              });
            });
            this.$router.go()
          }
        }
    }
  }
}
</script>