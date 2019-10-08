<template>
  <div v-if="showUpdateProject">
    <transition name="modal">
      <div class="modal modal-mask" style="display: block">
        <div class="modal-dialog" role="document">
          <div class="modal-content">
            <div class="modal-header">
              <h4 class="modal-title">Update</h4>
            </div>
            <div class="modal-body">
              <img v-if="ajaxWait" id="api-wait" src="./loading.gif" />
              <form>
                <div class="form-group row">
                  <label class="col-sm-4 col-form-label">Project Name</label>
                  <div class="col-sm-8">
                    <input type="text" class="form-control" placeholder="Name" v-model="project_name">
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
            <div class="modal-footer">
              <button class="btn btn-secondary" type="button" @click="validateFormAndSave($event)">Save</button>
              <button class="btn btn-secondary" type="button" @click="clearForm()">Close</button>
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
  width: 350px;
  margin-top: 114.5px;
}

.modal-body .cntry {
  text-align: left;
}
</style>

<script>
  export default {
    props: ["showUpdateProject", "projectData"],

    data: () => {
      return {
        project_name: "",
        project_id: "",
        project_exid: "",
        ajaxWait: false,
        errors: []
      }
    },

    watch: {
      projectData() {
        if (this.projectData != null) {
          this.project_name = this.projectData.name,
          this.project_id = this.projectData.id,
          this.project_exid = this.projectData.exid
        }
      }
    },

    methods: {
      validateFormAndSave(e) {

        this.errors = []

        if (this.project_name == "") {
          this.errors.push("Project name cannot be empty.")
        }

        if (Object.keys(this.errors).length === 0) {
          this.ajaxWait = true

          axios({
            method: 'patch',
            url: `/v1/projects`,
            data: {
              project_exid: this.project_exid, project_id: this.project_id, project_name: this.project_name
            }
          }).then(response => {
            if (response.status == 200) {

              this.showSuccessMsg({
                title: "Success",
                message: `${this.project_name} has been updated as a Project.`
              });

              this.$events.fire("hide-update-project", {
                project_name: this.project_name,
                project_id: this.project_id,
              })
              this.clearForm()

            } else {
              this.error.push(error.body.message)
            }
          })
        }
      },

      clearForm() {
        this.ajaxWait = false
        this.project_name = ""
        this.project_id = ""
        this.project_exid = ""
        this.errors = []
        this.$events.fire("hide-update-project", null)
      }
    }
  }
</script>