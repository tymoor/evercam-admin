<template>
  <div>
    <div class="add-modal"><button class="btn btn-secondary mb-1" type="button" data-toggle="modal" data-target="#addExtractor"><i class="fa fa-plus"></i> Add Extractor</button></div>
    <div class="modal fade" id="addExtractor" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Extractor</h4>
          </div>
          <div class="modal-body">
            <form>
              <div class="form-group row">
                <label class="col-sm-4 col-form-label">Construction Camera</label>
                <div class="col-sm-8">
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" type="button" @click="validateFormAndSave($event)">Save</button>
            <button class="btn btn-secondary" type="button" data-dismiss="modal" @click="clearForm()">Close</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>

.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.add-modal {
  float: right;
  margin-top: -35px;
  margin-right: 51px;
}

.modal-dialog {
  width: 660px;
  max-width: 660px;
  margin-top: 114.5px;
}

</style>

<script>
import jQuery from 'jquery'
  export default {
    data: () => {
      return {
        cameras: [],
        camera: ""
      }
    },

    mounted() {
      this.getCameras()
    },
    methods: {
      getCameras () {
        this.$http.get("/v1/construction_cameras").then(response => {
          this.cameras = response.body.construction_cameras;
        }, error => {
          console.error(error);
        });
      },
      validateFormAndSave (e) {
        e.preventDefault()
        this.errors = []

        // if (this.model_exid == "") {
        //   this.errors.push("Model id cannot be empty.")
        // }

        if (Object.keys(this.errors).length === 0) {

          let params = {
          }
          this.$http.post("/v1/snapshot_extractors", {...params}).then(response => {

            this.$notify({
              group: "admins",
              title: "Info",
              type: "success",
              text: "Snapshot Extractor has been added!",
            });

            jQuery('#addExtractor').modal('hide')
            this.clearForm()
          }, error => {
            this.$notify({
              group: "admins",
              title: "Error",
              type: "error",
              text: "Something went wrong!",
            });
          });
        }
      },
      clearForm () {
        this.errors = []
      }
    }
  }
</script>