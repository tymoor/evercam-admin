<template>
  <div>
    <div class="add-modal"><button class="btn btn-secondary mb-1" type="button" data-toggle="modal" data-target="#addModel"><i class="fa fa-plus"></i> Make New Admin</button></div>
    <div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Add Admin</h4>
            <button class="close" type="button" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">×</span>
          </button>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <div class="row">
                <div class="col">
                  <form>
                    <div class="form-group row">
                      <label class="col-sm-2 col-form-label">Email:</label>
                      <div class="col">
                        <input type="text" class="form-control" placeholder="Email" v-model="email">
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
import axios from "axios"

  export default {
    data: () => {
      return {
        errors: [],
        email: ""
      }
    },
    methods: {
      validateFormAndSave (e) {
        e.preventDefault()
        this.errors = []

        if (this.email == "") {
          this.errors.push("Email cannot be empty.")
        }

        if (Object.keys(this.errors).length === 0) {

          axios({
            method: 'patch',
            url: `/v1/admins/${this.email}`,
            data: {}
          }).then(response => {
            if (response.status == 200) {
              this.showInfoMsg({
                title: "Info",
                message: `${this.email} has been added as Admin.`
              });
              this.$events.fire("admin-added", {})
              jQuery('#addModel').modal('hide')
            } else {
              this.showErrorMsg({
                title: "Error",
                message: "Something went wrong."
              })
            }
          }).catch(err => {
            this.showErrorMsg({
              title: "Error",
              message: err.response.data.message
            })
          })
        }
      },
      clearForm () {
        this.errors = [],
        this.email = ""
      }
    }
  }
</script>
