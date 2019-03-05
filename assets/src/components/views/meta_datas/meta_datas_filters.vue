<template>
  <div class="row cameras-filter_css">
    <form>
      <div class="form-row">
        <div class="col-0.5 search-label">
          <label class="control-label">Search :</label>
        </div>
        <div class="col">
          <input class="form-control" type="text" placeholder="Search" autocomplete="off" v-model="search" @keyup="metaDatasFilterGlobal">
        </div>
        <div class="col">
          <a href="http://media.evercam.io:9991/" target="_blank" class="statistics-link"><i class="fa fa-chart-bar"></i> RTMP Statistics</a>
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

.statistics-link {
  text-decoration: none;
  font-size: 16px;
  border: 1px solid #e5e5e5;
  padding: 6px;
  line-height: 30px;
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
    metaDatasFilterGlobal () {
      this.allParams.search = this.search
      this.$events.fire('meta-datas-filter-set', this.allParams)
    }
  }
}
</script>