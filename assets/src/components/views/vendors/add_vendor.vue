<template>
  <div>
    <div class="add-modal"><button class="btn btn-secondary mb-1" type="button" data-toggle="modal" data-target="#addModel"><i class="fa fa-plus"></i> Add Vendor</button></div>
    <div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">
              Vendor
            </h4>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <div class="row">
                <div class="col-sm-8">
                  <form>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Vendor Id:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="Unique identifier for the vendor" v-model="exid">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Name:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="Name of the vendor" v-model="name">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Known Macs:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="Comma separated list of MAC's " v-model="known_macs">
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
                <div class="col-sm-4">
                  <div class="thumbnail-settings">
                    <div class="center-thumbnail">
                    <img src="" class="thumbnail-img" style="display: none;">
                    </div>
                  </div>
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
  width: 660px;
  max-width: 660px;
  margin-top: 114.5px;
}

.thumbnail-settings {
  background-color: white;
  overflow: hidden;
  width: 100%;
}

.center-thumbnail {
  height: 100%;
  min-height: 130px;
  text-align: center;
  background-image: url(./camera.svg);
  background-repeat: no-repeat;
  background-position: 50% 50%;
}

thumbnail-img {
  height: auto;
  width: 100%;
}
</style>

<script>
import jQuery from 'jquery'
import axios from 'axios'
  export default {
    props: ["vendorData"],
    data: () => {
      return {
        errors: [],
        exid: "",
        name: "",
        known_macs: ""
      }
    },

    watch: {
      vendorData() {
        this.updatePropsValue(this.vendorData)
        console.log("data updated")
      }
    },

    methods: {
      updatePropsValue(vendor) {
        this.exid =  vendor.exid,
        this.name = vendor.name,
        this.known_macs = this.getMacs(vendor.known_macs)
      },

      getMacs(macs) {
        if (macs == null) {
          return ""
        } else {
          let all_macs = ""
          macs.map((mac) => {
            if (all_macs === "") {
              all_macs += "" + mac +""
            } else {
              all_macs += "," + mac +""
            }
          });
          return all_macs;
        }
      },

      validateFormAndSave (e) {
        e.preventDefault()
        this.errors = []

        const idpattern = /^[-_a-z0-9]+$/

        if (this.exid == "") {
          this.errors.push("Vendor id cannot be empty.")
        }

        if (this.exid.match(idpattern) == null) {
          this.errors.push("Vendor id cannot contain capital letters, spaces and dots.")
        }

        if (this.name == "") {
          this.errors.push("Vendor name cannot be empty.")
        }

        if (Object.keys(this.errors).length === 0) {

          axios({
            method: 'post',
            url: "/v1/vendors",
            data: {
              exid: this.exid,
              name: this.name,
              known_macs: this.known_macs
            }
          }).then(response => {
            if (response.status == 200) {
              this.showSuccessMsg({
                title: "Success",
                message: "Vendor has been added!"
              });

              this.clearForm()
              jQuery('#addModel').modal('hide')
            } else {
              this.showErrorMsg({
                title: "Error",
                message: response.data.message
              });
            }
          })
        }
      },
      clearForm () {
        this.errors = [],
        this.exid = "",
        this.name = "",
        this.known_macs = "",
        this.$events.fire("vendor-added", {})
      }
    }
  }
</script>