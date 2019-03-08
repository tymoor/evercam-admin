<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Search" autocomplete="off" v-model="search" @keyup="dcFilterGlobal">
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

.mx-shortcuts-wrapper {
  display: none;
}
</style>

<script>
export default {
  data () {
    return {
      search: "",
      allParams: {},
    }
  },
  methods: {
    dcFilterGlobal () {
      this.allParams.search = this.search
      this.$events.fire('dc-filter-set', this.allParams)
    }
  }
}
</script>
