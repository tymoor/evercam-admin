<template>
  <div v-if="showModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
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
            <button type="button" class="btn btn-danger" @click="deleteCameras()"> Delete </button>
            <button type="button" class="btn btn-primary" @click="hideDupCameraModal()"> Close </button>
          </div>
        </div>
      </div>
    </div>
    </transition>
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

.modal-body .cntry {
  text-align: left;
}
</style>

<script>
  export default {
    props: ["duplicateCameras", "showModal"],
    data: () => {
      return {
        forCameras: [],
        ajaxWait: false,
        errors: []
      }
    },

    methods: {
      hideDupCameraModal () {
        this.$events.fire("close-dup-cameras", false)
      },

      deleteCameras() {

        if (window.confirm("Are you sure you want to delete this event?")) {
          this.ajaxWait = true;
          this.forCameras.forEach((camera) => {
            this.$http.delete(`${this.$root.api_url}/v2/cameras/${camera.exid}?api_id=${camera.api_id}&api_key=${camera.api_key}`).then(response => {
              console.log(response.body)
            }, error => {
              console.log(error)
            });
          });
          this.$events.fire("close-dup-cameras", false)
          
          // this.$router.go()
        }
      }
    }
  }
</script>