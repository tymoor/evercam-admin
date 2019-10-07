<template>
  <div>
    <div class="add-modal"><button class="btn btn-secondary mb-1" type="button" data-toggle="modal" data-target="#addModel"><i class="fa fa-plus"></i> Add Model</button></div>
    <div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Model</h4>
          </div>
          <div class="modal-body">
            <div class="form-group">
              <div class="row">
                <div class="col-sm-8">
                  <form>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Id:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="Unique identifier for the model" v-model="model_exid">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Vendor:</label>
                      <div class="col-sm-8">
                        <select id="vendor" name="vendor" class="form-control" v-model="vendor">
                          <option v-for="vendor in vendors" v-bind:value="vendor.id">{{ vendor.name }}</option>
                        </select>
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Channel:</label>
                      <div class="col-sm-8">
                        <select id="channel" name="channel" class="form-control" v-model="channel">
                          <option v-for="n in 30" :value="(n*100)+1">
                            {{n}}01
                          </option>
                        </select>
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Auth Type:</label>
                      <div class="col-sm-8">
                        <select id="auth_type" name="auth_type" class="form-control" v-model="auth_type">
                          <option value="basic">Basic</option>
                          <option value="digest">Digest</option>
                        </select>
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Name:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="Name of the model" v-model="name">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">JPG Url:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="jpg_url">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">MJPG Url:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="mjpg_url">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">MPEG4 Url:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="mpeg4_url">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Mobile Url:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="mobile_url">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">H264 Url:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="h264_url">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Low Res Url:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="lowres_url">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Audio Url:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="audio_url">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Default Username:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="username">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Default Password:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="password">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Resolution:</label>
                      <div class="col-sm-8">
                        <input type="text" class="form-control" placeholder="" v-model="resolution">
                      </div>
                    </div>
                    <div class="form-group row">
                      <label class="col-sm-4 col-form-label">Features:</label>
                      <div class="col-sm-8">
                        <div class="row">
                          <div class="col">
                            <div class="ui checkbox">
                              <input type="checkbox" v-model="poe" v-bind:checked="poe">
                              <label>Poe</label>
                            </div>
                          </div>
                          <div class="col">
                            <div class="ui checkbox">
                              <input type="checkbox" v-model="wifi" v-bind:checked="wifi">
                              <label>Wifi</label>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col">
                            <div class="ui checkbox">
                              <input type="checkbox" v-model="onvif" v-bind:checked="onvif">
                              <label>Onvif</label>
                            </div>
                          </div>
                          <div class="col">
                            <div class="ui checkbox" v-model="psia" v-bind:checked="pisa">
                              <input type="checkbox">
                              <label>Psia</label>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col">
                            <div class="ui checkbox" v-model="audio_io" v-bind:checked="audio_io">
                              <input type="checkbox">
                              <label>Audio_io</label>
                            </div>
                          </div>
                          <div class="col">
                            <div class="ui checkbox" v-model="ptz" v-bind:checked="ptz">
                              <input type="checkbox">
                              <label>Ptz</label>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col">
                            <div class="ui checkbox" v-model="infrared" v-bind:checked="infrared">
                              <input type="checkbox">
                              <label>Infrared</label>
                            </div>
                          </div>
                          <div class="col">
                            <div class="ui checkbox" v-model="varifocal" v-bind:checked="varifocal">
                              <input type="checkbox">
                              <label>Varifocal</label>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col">
                            <div class="ui checkbox">
                              <input type="checkbox" v-model="sd_card" v-bind:checked="sd_card">
                              <label>Sd_card</label>
                            </div>
                          </div>
                          <div class="col">
                            <div class="ui checkbox" v-model="upnp" v-bind:checked="upnp">
                              <input type="checkbox">
                              <label>Upnp</label>
                            </div>
                          </div>
                        </div>
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
  export default {
    props: ["vendorModelData"],
    data: () => {
      return {
        vendors: [],
        errors: [],
        model_exid: "",
        vendor: 32,
        channel: "",
        name: "",
        jpg_url: "",
        mjpg_url: "",
        mpeg4_url: "",
        mobile_url: "",
        h264_url: "",
        lowres_url: "",
        audio_url: "",
        username: "",
        password: "",
        resolution: "",
        poe: false,
        wifi: false,
        onvif: false,
        pisa: false,
        audio_io: false,
        ptz: false,
        infrared: false,
        varifocal: false,
        sd_card: false,
        upnp: false,
        auth_type: "basic"
      }
    },

    watch: {
      vendorModelData() {
        this.updatePropsValue(this.vendorModelData)
        console.log("data updated")
      }
    },

    mounted() {
      this.fetchVendors()
    },
    methods: {

      updatePropsValue(vendorModel) {
        this.model_exid = vendorModel.exid,
        this.vendor = vendorModel.vendor_id,
        this.channel = vendorModel.channel,
        this.name = vendorModel.name,
        this.jpg_url = vendorModel.jpg_url,
        this.mjpg_url = vendorModel.mjpg_url,
        this.mpeg4_url = vendorModel.mpeg4_url,
        this.mobile_url = vendorModel.mobile_url,
        this.h264_url = vendorModel.h264_url,
        this.lowres_url = vendorModel.lowres_url,
        this.audio_url = vendorModel.audio_url,
        this.username = vendorModel.username,
        this.password = vendorModel.password,
        this.resolution = vendorModel.resolution,
        this.poe = vendorModel.poe,
        this.wifi = vendorModel.wifi,
        this.onvif = vendorModel.onvif,
        this.pisa = vendorModel.pisa,
        this.audio_io = vendorModel.audio_io,
        this.ptz = vendorModel.ptz,
        this.infrared = vendorModel.infrared,
        this.varifocal = vendorModel.varifocal,
        this.sd_card = vendorModel.sd_card,
        this.upnp = vendorModel.upnp,
        this.auth_type = vendorModel.auth_type
      },

      fetchVendors () {
        this.$http.get("/v1/all_vendors").then(response => {
          this.vendors = response.body.vendors;
        }, error => {
          console.error(error);
        });
      },
      validateFormAndSave (e) {
        e.preventDefault()
        this.errors = []

        const idpattern = /^[-_a-z0-9]+$/

        if (this.model_exid == "") {
          this.errors.push("Model id cannot be empty.")
        }

        if (this.model_exid.match(idpattern) == null) {
          this.errors.push("Model id cannot contain capital letters, spaces and dots.")
        }

        if (this.name == "") {
          this.errors.push("Model name cannot be empty.")
        }

        if (this.jpg_url == "") {
          this.errors.push("JPG url cannot be empty.")
        }

        if (Object.keys(this.errors).length === 0) {
          console.log("hit me")

          let params = {
            model_exid: this.model_exid,
            vendor: this.vendor,
            channel: this.channel,
            name: this.name,
            jpg_url: this.jpg_url,
            mjpg_url: this.mjpg_ur,
            mpeg4_url: this.mpeg4_url,
            mobile_url: this.mobile_url,
            h264_url: this.h264_url,
            lowres_url: this.lowres_url,
            audio_url: this.audio_url,
            username: this.username,
            password: this.password,
            resolution: this.resolution,
            poe: this.poe,
            wifi: this.wifi,
            onvif: this.onvif,
            pisa: this.pisa,
            audio_io: this.audio_io,
            ptz: this.ptz,
            infrared: this.infrared,
            varifocal: this.varifocal,
            sd_card: this.sd_card,
            upnp: this.upnp,
            auth_type: this.auth_type
          }
          this.$http.post("/v1/vendor_models", {...params}).then(response => {

            this.showSuccessMsg({
              title: "Success",
              message: "Model has been added!"
            });

            jQuery('#addModel').modal('hide')
            this.clearForm()
          }, error => {
            this.showErrorMsg({
              title: "Error",
              message: "Something went wrong!"
            });
          });
        }
      },
      clearForm () {
        this.errors = [],
        this.model_exid = "",
        this.vendor = 32,
        this.channel = "",
        this.name = "",
        this.jpg_url = "",
        this.mjpg_url = "",
        this.mpeg4_url = "",
        this.mobile_url = "",
        this.h264_url = "",
        this.lowres_url = "",
        this.audio_url = "",
        this.username = "",
        this.password = "",
        this.resolution = "",
        this.poe = false,
        this.wifi = false,
        this.onvif = false,
        this.pisa = false,
        this.audio_io = false,
        this.ptz = false,
        this.infrared = false,
        this.varifocal = false,
        this.sd_card = false,
        this.upnp = false,
        this.auth_type = "basic",
        this.$events.fire("model-added", {})
      }
    }
  }
</script>