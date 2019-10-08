<template>
  <div>
    <div v-if="showModal">
      <transition name="modal">
       <div class="modal modal-mask" style="display: block;">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h3 class="modal-title">
                Duplicate Cameras
              </h3>
            </div>
            <div class="modal-body">
              <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
              <table v-if="duplicateCameras" class="table table-striped">
                <thead>
                  <tr>
                    <th scope="col">Name</th>
                    <th scope="col">Exid</th>
                    <th scope="col">Onine</th>
                    <th scope="col">Owner Name</th>
                    <th scope="col">Public</th>
                    <th scope="col">CR Status</th>
                    <th scope="col">Shared Count</th>
                    <th scope="col">Created At</th>
                    <th scope="col">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(field, idx) in duplicateCameras">
                    <td>{{ field.camera_name }}</td>
                    <td>{{ field.exid }}</td>
                    <td>{{ field.is_online }}</td>
                    <td v-html="field.camera_link" ></td>
                    <td>{{ field.is_public }}</td>
                    <td>{{ field.cr_status }}</td>
                    <td>{{ field.share_count }}</td>
                    <td>{{ field.created_at }}</td>
                    <td><input type="checkbox" :value="field" v-bind:camera="field.exid" v-bind:camera-api-id="field.api_id" v-bind:camera-api-key="field.api_key" v-model="forCameras"/></td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-primary" @click="mergeCameras()"> Merge </button>
              <button type="button" class="btn btn-danger" @click="deleteCameras()"> Delete </button>
              <button type="button" class="btn btn-primary" @click="hideDupCameraModal()"> Close </button>
            </div>
          </div>
        </div>
      </div>
      </transition>
    </div>
    <div>
      <div class="modal fade" id="mergeModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none; z-index: 99999999;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
        <div class="modal-dialog" role="document" style="width: 400px; margin-top: 150px">
          <div class="modal-content">
            <div class="modal-header">
              <h4 class="modal-title">
                Select Super Camera
              </h4>
            </div>
            <div class="modal-body">
              <div class="form-group row">
                <label class="col-md-4 col-form-label cntry">Super Camera</label>
                <div class="col-md-7">
                  <select class="form-control is-required" autocomplete="off" v-model="superCamera">
                    <option v-for="camera in forCameras" :value="camera">
                      {{ camera.camera_name }} Shares ({{camera.share_count}})
                    </option>
                  </select>
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-success" @click="mergeWithSuperCamera()"> Merge </button>
              <button type="button" class="btn btn-primary" @click="hideMergeModal()"> Close </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-mask {
   position: fixed;
   z-index: 9998;
   top: 0;
   left: 0;
   width: 100%;
   height: 100%;
   background-color: rgba(0, 0, 0, .5);
   display: table;
   transition: opacity .3s ease;
}

.modal-dialog {
  width: 95%;
  max-width: 100%;
  margin-top: 114.5px;
}

modal-dialog-1 {
  width: 200px;
  max-width: 100%;
  margin-top: 114.5px;
}

.modal-body .cntry {
  text-align: left;
}
</style>

<script>
import jQuery from 'jquery'
import axios from "axios";

  export default {
    props: ["duplicateCameras", "showModal"],
    data: () => {
      return {
        forCameras: [],
        ajaxWait: false,
        errors: [],
        superCamera: ""
      }
    },

    methods: {

      hideMergeModal() {
        jQuery('#mergeModal').modal('hide')
      },

      mergeCameras() {
        if (Object.keys(this.forCameras).length <= 1) {
          return;
        } else {
          jQuery('#mergeModal').modal('show')
        }

      },

      mergeWithSuperCamera() {
        console.log(this.superCamera)
        if (Object.keys(this.superCamera).length === 0) {
          return;
        } else {
          jQuery('#mergeModal').modal('hide')
          this.ajaxWait = true
          let params = {
            super_camera: this.superCamera,
            sharee_cameras: this.forCameras
          }

          axios({
            method: 'post',
            url: `/v1/camera_shares`,
            data: {
              super_camera: this.superCamera,
              sharee_cameras: this.forCameras
            }
          }).then(response => {
            if (response.status == 200) {
              this.ajaxWait = false;
              this.$events.fire("close-dup-cameras", false)
              this.superCamera = ""
              this.forCameras = []

              this.showSuccessMsg({
                title: "Success",
                message: "Cameras has been merged!"
              })
              this.$router.go()
            } else {
              this.ajaxWait = false;
              this.$events.fire("close-dup-cameras", false)
              this.showErrorMsg({
                title: "Error",
                message: "Something went wrong!"
              })
            }
          })
         // do merge operations
        }
      },

      hideDupCameraModal () {
        this.forCameras = []
        this.superCamera = ""
        this.$events.fire("close-dup-cameras", false)
      },

      deleteCameras() {
        if (Object.keys(this.forCameras).length === 0) {
          return;
        } else {
          if (window.confirm("Are you sure you want to delete this event?")) {
            this.ajaxWait = true;
            this.forCameras.forEach((camera) => {

              axios({
                method: 'post',
                url: `${this.$root.api_url}/v2/cameras/${camera.exid}?api_id=${camera.api_id}&api_key=${camera.api_key}`,
                data: {
                }
              }).then(response => {
                console.log(response)
              })
            })
            this.$events.fire("close-dup-cameras", false)
            this.$router.go()
          }
        }
      }
    }
  }
</script>