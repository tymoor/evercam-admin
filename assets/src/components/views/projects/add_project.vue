<template>
  <div>
    <div class="add-modal"><button class="btn btn-secondary mb-1" type="button" data-toggle="modal" data-target="#addModel"><i class="fa fa-plus"></i> Add Project</button></div>
    <div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Add Project</h4>
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
                      <label class="col-sm-4 col-form-label">Owner:</label>
                      <div class="col-sm-8">
                        <cool-select
                          v-model="selected"
                          :items="users"
                          :loading="loading"
                          item-text="email"
                          placeholder="Enter owner email"
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
                          <template slot="user" slot-scope="{ user }">
                            <div class="user">
                              <div>
                                <span class="user-email"> {{ user.email }} </span> <br />
                              </div>
                            </div>
                          </template>
                        </cool-select>
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Project Name:</label>
                      <div class="col">
                        <input type="text" class="form-control" placeholder="Project Name" v-model="project_name">
                      </div>
                    </div>
                  </form>
                  <p v-if="items.length">
                    <b>Few similar projects already exist.</b>
                    <ul>
                      <li v-for="owner in items">{{ owner.email }}</li>
                    </ul>
                  </p>
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
            <button class="btn btn-secondary" type="button" @click="validateFormAndSave($event)" :disabled="items.length >= 1">Save</button>
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
  margin-right: 13px;
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
    components: {
      CoolSelect
    },
    data: () => {
      return {
        selectEventEmitter: new EventEmitter(),
        errors: [],
        selected: null,
        project_name: "",
        search: "",
        timeoutId: null,
        noData: false,
        ajaxWait: false,
        items: [],
        users: []
      }
    },
    methods: {

      async onSearch(search) {
        const lettersLimit = 2;

        this.noData = false;
        if (search.length < lettersLimit) {
          this.users = [];
          this.ajaxWait = false;
          return;
        }
        this.ajaxWait = true;

        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(async () => {
          const response = await fetch(
            `/v1/projects/owner?search=${search}`
          );

          this.users = await response.json();
          this.ajaxWait = false;

          if (!this.users.length) this.noData = true;

        }, 500);
      },

      searchOwner() {
        // this.onSearch(this.owner_email)
      },

      validateFormAndSave (e) {
        e.preventDefault()
        this.errors = []

        if (this.selected == null) {
          this.errors.push("Please select project owner.")
        }

        if (this.project_name == "") {
          this.errors.push("Project Name cannot be empty.")
        }

        if (Object.keys(this.errors).length === 0) {

          axios({
            method: 'post',
            url: `/v1/projects`,
            data: {
              owner_id: this.selected.id, project_name: this.project_name
            }
          }).then(response => {
            if (response.status == 200) {
              this.showSuccessMsg({
                title: "Success",
                message: `${this.company_name} has been added as a Project.`
              });

              this.$events.fire("project-added", {})
              this.clearForm()
              jQuery('#addModel').modal('hide')
            } else {
              this.showErrorMsg({
                title: "Error",
                message: error.body.message
              })
            }
          })
        }
      },
      clearForm () {
        this.errors = [],
        this.project_name = "",
        this.selected = null
        this.selectEventEmitter.emit("set-search", "")
      }
    }
  }
</script>