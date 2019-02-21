<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="User" autocomplete="off" v-model="fullname" @keyup="snapmailFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Cameras" autocomplete="off" v-model="cameras" @keyup="snapmailFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Recipients" autocomplete="off" v-model="recipients" @keyup="snapmailFilterGlobal">
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Notify Time" autocomplete="off" v-model="notify_time" @keyup="snapmailFilterGlobal">
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

.search-label {
  margin-top: 4px;
  margin-left: 15px;
}
</style>

<script>
export default {
  data () {
    return {
      fullname: "",
      cameras: "",
      notify_time: "",
      timezone: "",
      recipients: "",
      allParams: {}
    }
  },
  methods: {
    snapmailFilterGlobal () {
      this.allParams.fullname = this.fullname
      this.allParams.cameras = this.cameras
      this.allParams.notify_time = this.notify_time
      this.allParams.timezone = this.timezone
      this.allParams.recipients = this.recipients
      this.$events.fire('snapmail-filter-set', this.allParams)
    }
  }
}
</script>