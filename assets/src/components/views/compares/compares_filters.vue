<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Search" autocomplete="off" v-model="search" @keyup="comparesFilterGlobal">
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
      search: "",
      allParams: {}
    }
  },
  methods: {
    comparesFilterGlobal () {
      this.allParams.search = this.search
      this.$events.fire('compares-filter-set', this.allParams)
    }
  }
}
</script>