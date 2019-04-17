<template>
  <div>
    <div class="add-modal"><button class="btn btn-secondary mb-1" type="button" @click="onAddToProject()"><i class="fa fa-plus"></i> Add to Project</button></div>
    <div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Add to Project</h4>
            <button class="close" type="button" data-dismiss="modal" aria-label="Close" @click="clearForm()">
            <span aria-hidden="true">×</span>
          </button>
          </div>
          <div class="modal-body">
            <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
            <div class="form-group">
              <div class="row">
                <div class="col">
                  <form>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Project:</label>
                      <div class="col-sm-8">
                        <cool-select
                          v-model="selected"
                          :items="items"
                          :loading="loading"
                          item-text="name"
                          placeholder="Enter project name"
                          :event-emitter="selectEventEmitter"
                          :reset-search-on-blur="true"
                          disable-filtering-by-search
                          @search="onSearch"
                        >
                          <template slot="no-data">
                            {{
                              noData
                                ? "No information found by request."
                                : "We need at least 2 letters to search."
                            }}
                          </template>
                          <template slot="item" slot-scope="{ item }">
                            <div class="item">
                              <div>
                                <span class="item-email"> {{ item.name }} </span> <br />
                              </div>
                            </div>
                          </template>
                        </cool-select>
                      </div>
                    </div>
                  </form>
                  <p v-if="errors.length">
                    <b>Please correct the following error(s):</b>
                    <ul>
                      <li v-for="error in errors">{{ error }}</li>
                    </ul>
                  </p>
                </div>
              </div>
            </div>
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
  width: 360px;
  max-width: 360px;
  margin-top: 114.5px;
}

.modal-body {
  padding-top: 10px;
  padding-left: 10px;
  padding-right: 10px;
  padding-bottom: 0px;
}

</style>

<script>
  import { CoolSelect, EventEmitter } from "vue-cool-select";
  import jQuery from 'jquery'

  export default {
    props: ["selectedCameras"],
    components: {
      CoolSelect
    },
    data: () => {
      return {
        selectEventEmitter: new EventEmitter(),
        errors: [],
        selected: null,
        search: "",
        timeoutId: null,
        noData: false,
        ajaxWait: false,
        items: [],
        camera_exids: [],
        invalidate_urls: []
      }
    },
    methods: {

      async onSearch(search) {
        const lettersLimit = 2;

        this.noData = false;
        if (search.length < lettersLimit) {
          this.items = [];
          this.ajaxWait = false;
          return;
        }
        this.ajaxWait = true;

        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(async () => {
          const response = await fetch(
            `/v1/search_project?search=${search}`
          );

          this.items = await response.json();
          this.ajaxWait = false;

          if (!this.items.length) this.noData = true;

        }, 500);
      },

      onAddToProject () {
        let self = this
        if (self.selectedCameras == undefined || Object.keys(self.selectedCameras).length === 0) {
          this.showWarnMsg({
            title: "Warning",
            message: "At least select one Camera!"
          });
        } else {
          jQuery('#addModel').modal('show')
        }
      },

      validateFormAndSave (e) {
        e.preventDefault()
        let self = this
        this.errors = []
        
        if (this.selected == null) {
          this.errors.push("Please select project.")
        }

        if (Object.keys(this.errors).length === 0) {
          self.selectedCameras.forEach((camera) => {
            this.invalidate_urls.push(`/${camera.exid}/invalidate/cache?api_id=${camera.api_id}&api_key=${camera.api_key}`)
            this.camera_exids.push(camera.exid)
          });
          console.log(this.camera_exids.join(","))
          this.$http.post(`/v1/add_to_project`, {...{project_id: this.selected.id, camera_exids: this.camera_exids.join(","), invalidate_urls: this.invalidate_urls.join(",")}}).then(response => {

            this.showSuccessMsg({
              title: "Success",
              message: `Camera(s) added to Project ${this.selected.name}.`
            });

            this.$events.fire("hide-add-to-project", {})
            jQuery('#addModel').modal('hide')
            this.clearForm()
          }, error => {
            this.showErrorMsg({
              title: "Error",
              message: error.body.message
            });
          });
        }
      },
      clearForm () {
        this.errors = []
        this.camera_exids = []
        this.invalidate_urls = []
        this.selected = null
        this.selectEventEmitter.emit("hide-add-to-project", "")
      }
    }
  }
</script>