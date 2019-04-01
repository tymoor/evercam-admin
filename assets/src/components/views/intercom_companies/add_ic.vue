<template>
  <div>
    <div class="add-modal"><button class="btn btn-secondary mb-1" type="button" data-toggle="modal" data-target="#addModel"><i class="fa fa-plus"></i> Add Company</button></div>
    <div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Add Company</h4>
            <button class="close" type="button" data-dismiss="modal" aria-label="Close" @click="clearForm()">
            <span aria-hidden="true">×</span>
          </button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <div class="row">
                <div class="col">
                  <form>
                    <div class="form-group row">
                      <label class="col-sm-5 col-form-label">Company ID:</label>
                      <div class="col">
                        <input type="text" class="form-control" placeholder="Company ID" v-model="company_id">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-5 col-form-label">Company Name:</label>
                      <div class="col">
                        <input type="text" class="form-control" placeholder="Company Name" v-model="company_name">
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
import jQuery from 'jquery'
  export default {
    data: () => {
      return {
        errors: [],
        company_name: "",
        company_id: ""
      }
    },
    methods: {
      validateFormAndSave (e) {
        e.preventDefault()
        this.errors = []

        if (this.company_name == "") {
          this.errors.push("Company Name cannot be empty.")
        }

        if (this.company_id == "") {
          this.errors.push("Company ID cannot be empty.")
        }

        if (Object.keys(this.errors).length === 0) {

          this.$http.post(`/v1/intercom_companies`, {...{company_id: this.company_id, company_name: this.company_name, add_users: true}}).then(response => {

            this.$notify({
              group: "admins",
              title: "Info",
              type: "success",
              text: `${this.company_name} has been added as a Company.`,
            });

            this.$events.fire("ic-added", {})
            this.clearForm()
            jQuery('#addModel').modal('hide')
          }, error => {
            this.$notify({
              group: "admins",
              title: "Error",
              type: "error",
              text: error.body.message,
            });
          });
        }
      },
      clearForm () {
        this.errors = [],
        this.company_name = "",
        this.company_id = ""
      }
    }
  }
</script>