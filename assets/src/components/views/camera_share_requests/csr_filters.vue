<template>
  <div class="row cameras-filter_css">
    <form>
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
        <div class="col-4">
          <div class="form-group">
            <label for="inputState" class="col-4 left-float st-top">Status :&nbsp;</label>
            <select id="inputState" v-model="status" @change="CSRFilterGlobal" class="form-control col-5 left-float">
              <option value="-1">Pending</option>
              <option value="-2">Cancelled</option>
              <option value="1">Used</option>
            </select>
          </div>
        </div>
      </div>
    </form>
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
  margin-left: 15px;
}
</style>

<script>
export default {
  data () {
    return {
      sharer: "",
      camera: "",
      sharee_email: "",
      rights: "",
      status: -1,
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
    }
  }
}
</script>