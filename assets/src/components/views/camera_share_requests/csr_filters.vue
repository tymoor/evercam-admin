<template>
  <div class="row cameras-filter_css">
    <div class="col-sm-5 col-md-6">
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Sharer" autocomplete="off" v-model="sharer" @keyup="CSRFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Camera" autocomplete="off" v-model="camera" @keyup="CSRFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Sharee Email" autocomplete="off" v-model="sharee_email" @keyup="CSRFilterGlobal">
        </div>
        <div class="col">
          <select id="inputState" v-model="status" @change="CSRFilterGlobal" class="form-control">
            <option value="">Status</option>
            <option value="-1">Pending</option>
            <option value="-2">Cancelled</option>
            <option value="1">Used</option>
          </select>
        </div>
      </div>
    </div>
    <div class="col-sm-5 col-sm-offset-2 col-md-6 col-md-offset-0">
      <button type="button" @click="deleteCSRs" class="btn btn-danger btn-right-margin">Delete</button>
    </div>
  </div>
</template>

<style scoped>
.form-control {
  box-shadow: none;
  -moz-box-shadow: none;
  -webkit-box-shadow: none;
}

.left-float {
  float: left;
}

.st-top {
  margin-top: 4px;
}

.search-label {
  margin-top: 4px;
}
</style>

<script>
export default {
  props: ["selectedCSR"],
  data () {
    return {
      sharer: "",
      camera: "",
      sharee_email: "",
      rights: "",
      status: "",
      allParams: {}
    }
  },
  methods: {
    CSRFilterGlobal () {
      this.allParams.sharer = this.sharer
      this.allParams.camera = this.camera
      this.allParams.sharee_email = this.sharee_email
      this.allParams.rights = this.rights
      this.allParams.status = this.status
      this.$events.fire('csr-filter-set', this.allParams)
    },

    deleteCSRs () {
      let self = this
      if (Object.keys(self.selectedCSR).length === 0) {
        this.$notify({
          group: "admins",
          title: "Error",
          type: "error",
          text: "At least select one Share Request!",
        });
      } else {
        let ids = ""
        self.selectedCSR.map((csr) => {
          if (ids === "") {
            ids += "" + csr +""
          } else {
            ids += "," + csr +""
          }
        });
        if (window.confirm("Are you sure you want to delete this event?")) {
          this.$http.delete(`/v1/camera_share_requests`, {params: {ids: ids}}).then(response => {

            this.$notify({
              group: "admins",
              title: "Success",
              type: "success",
              text: "Camera Share Request(s) has been deleted!",
            });

            this.$events.fire("csr-deleted", {})
          }, error => {
            this.$notify({
              group: "admins",
              title: "Error",
              type: "error",
              text: "Something went wrong!",
            });
          });
        }
      }
    }
  }
}
</script>