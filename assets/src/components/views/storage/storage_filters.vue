<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Year :</label>
        </div>
        <div class="col">
          <select v-model="year" @change="storageFilterGlobal" class="form-control">
            <option value="2016">2016</option>
            <option value="2017">2017</option>
            <option value="2018">2018</option>
            <option value="2019">2019</option>
          </select>
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
      year: "2016",
      allParams: {}
    }
  },
  methods: {
    storageFilterGlobal () {
      this.allParams.year = this.year
      this.$events.fire('storage-filter-set', this.allParams)
    }
  }
}
</script>